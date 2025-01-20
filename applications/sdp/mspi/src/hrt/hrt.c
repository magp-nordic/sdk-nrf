/*
 * Copyright (c) 2024 Nordic Semiconductor ASA
 *
 * SPDX-License-Identifier: LicenseRef-Nordic-5-Clause
 */
#include "hrt.h"
#include <hal/nrf_vpr_csr_vio.h>
#include <hal/nrf_vpr_csr_vtim.h>
#include <drivers/mspi/nrfe_mspi.h>
#include <zephyr/drivers/mspi.h>
#include <stdio.h>

/** @brief Shift control configuration. */
typedef struct
{
    uint8_t shift_count;
    nrf_vpr_csr_vio_shift_t out_mode;
    uint8_t frame_width;
    nrf_vpr_csr_vio_mode_in_t in_mode;
} nrf_vpr_csr_vio_shift_ctrl_t;

NRF_STATIC_INLINE void nrf_vpr_csr_vio_shift_ctrl_buffered_set(nrf_vpr_csr_vio_shift_ctrl_t const * p_shift_ctrl)
{	
	uint32_t reg = ((p_shift_ctrl->shift_count<<VPRCSR_NORDIC_SHIFTCTRLB_SHIFTCNTB_VALUE_Pos)&VPRCSR_NORDIC_SHIFTCTRLB_SHIFTCNTB_VALUE_Msk) | 
			((p_shift_ctrl->out_mode<<VPRCSR_NORDIC_SHIFTCTRLB_OUTMODEB_MODE_Pos)&VPRCSR_NORDIC_SHIFTCTRLB_OUTMODEB_MODE_Msk) | 
			((p_shift_ctrl->frame_width<<VPRCSR_NORDIC_SHIFTCTRLB_OUTMODEB_FRAMEWIDTH_Pos)&VPRCSR_NORDIC_SHIFTCTRLB_OUTMODEB_FRAMEWIDTH_Msk) |
			((p_shift_ctrl->in_mode<<VPRCSR_NORDIC_SHIFTCTRLB_INMODEB_MODE_Pos)&VPRCSR_NORDIC_SHIFTCTRLB_INMODEB_MODE_Msk);

	nrf_csr_write(VPRCSR_NORDIC_SHIFTCTRLB, reg);
}

static void hrt_tx(volatile hrt_xfer_data_t *xfer_data, uint8_t frame_width, bool *counter_running, uint16_t counter0_value, uint16_t cnt1_val)
{
	// if(xfer_data->words == 0)
	// {
	// 	return;
	// }

	nrf_vpr_csr_vio_shift_ctrl_t shift_ctrl = {
		.shift_count = BITS_IN_WORD / frame_width - 1,
		.out_mode = NRF_VPR_CSR_VIO_SHIFT_OUTB_TOGGLE,
		.frame_width = frame_width,
		.in_mode = NRF_VPR_CSR_VIO_MODE_IN_SHIFT,
	};

	nrf_vpr_csr_vio_shift_ctrl_buffered_set(&shift_ctrl);

	for (uint32_t i = 0; i < xfer_data->words; i++) {

		xfer_data->vio_out_set(((uint32_t *)xfer_data->data)[i]);

		if ((i == 0) && (!*counter_running)) {
			/* Start counter */
			if (cnt1_val != 0)
			{
				/* Start both counters */
				nrf_vpr_csr_vtim_combined_counter_set(
					(counter0_value << VPRCSR_NORDIC_CNT_CNT0_Pos) +
					(cnt1_val << VPRCSR_NORDIC_CNT_CNT1_Pos));
			}
			else {
				/* Start counter */
				nrf_vpr_csr_vtim_simple_counter_set(0, counter0_value);
			}
			*counter_running = true;
		}
	}
}

void hrt_write(volatile hrt_xfer_t *hrt_xfer_params)
{
	uint16_t out;
	hrt_frame_element_t first_element = HRT_FE_DATA;
	bool counter_running = false;
	nrf_vpr_csr_vio_shift_ctrl_t shift_ctrl = {
		.shift_count = 1,
		.out_mode = NRF_VPR_CSR_VIO_SHIFT_NONE,
		.frame_width = 4,
		.in_mode = NRF_VPR_CSR_VIO_MODE_IN_CONTINUOUS,
	};
	
	nrf_vpr_csr_vio_mode_out_t out_mode = {
		.mode = NRF_VPR_CSR_VIO_SHIFT_OUTB_TOGGLE
	};

	/* Configure clock and pins */
	nrf_vpr_csr_vio_dir_set(hrt_xfer_params->tx_direction_mask);

	for(uint8_t i=0; i<HRT_FE_MAX; i++) {

		if(hrt_xfer_params->xfer_data[i].words != 0)
		{
			first_element = i;
			break;
		}	
	}

	switch(first_element) {
	case HRT_FE_COMMAND:
		out_mode.frame_width = hrt_xfer_params->io_mode.command;
		break;
	case HRT_FE_ADDRESS:
		out_mode.frame_width = hrt_xfer_params->io_mode.address;
		break;
	case HRT_FE_DATA:
		out_mode.frame_width = hrt_xfer_params->io_mode.data;
		break;
	default:
		break;
	}

	nrf_vpr_csr_vtim_count_mode_set(0, NRF_VPR_CSR_VTIM_COUNT_RELOAD);
	nrf_vpr_csr_vtim_simple_counter_top_set(0, hrt_xfer_params->counter_value);
	nrf_vpr_csr_vio_mode_in_set(NRF_VPR_CSR_VIO_MODE_IN_CONTINUOUS);

	nrf_vpr_csr_vio_mode_out_set(&out_mode);
		
	switch(hrt_xfer_params->xfer_data[first_element].words) {
	case 1:
		nrf_vpr_csr_vio_shift_cnt_out_set(hrt_xfer_params->xfer_data[first_element].last_word_clocks);
		break;
	case 2:
		nrf_vpr_csr_vio_shift_cnt_out_set(hrt_xfer_params->xfer_data[first_element].penultimate_word_clocks);
		break;
	default:
		nrf_vpr_csr_vio_shift_cnt_out_set(BITS_IN_WORD / out_mode.frame_width);
	}

	/* Enable CS */
	out = nrf_vpr_csr_vio_out_get();

	if (hrt_xfer_params->ce_polarity == MSPI_CE_ACTIVE_LOW) {
		WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_LOW);
	} else {
		WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_HIGH);
	}
	nrf_vpr_csr_vio_out_set(out);

	/* Transfer command */
	hrt_tx(&hrt_xfer_params->xfer_data[HRT_FE_COMMAND], hrt_xfer_params->io_mode.command, &counter_running, hrt_xfer_params->counter_value, 0);
	/* Transfer address */
	hrt_tx(&hrt_xfer_params->xfer_data[HRT_FE_ADDRESS], hrt_xfer_params->io_mode.address, &counter_running, hrt_xfer_params->counter_value, 0);
	/* Transfer data */
	hrt_tx(&hrt_xfer_params->xfer_data[HRT_FE_DATA], hrt_xfer_params->io_mode.data, &counter_running, hrt_xfer_params->counter_value, 0);

	if (hrt_xfer_params->eliminate_last_pulse) {

		/* Wait until the last word is sent */
		while(nrf_vpr_csr_vio_shift_cnt_out_get() != 0){}

		/* This is a partial solution to surplus clock edge problem in modes 1 and 3.
		 * This solution works only for counter values above 20.
		 */
		nrf_vpr_csr_vtim_simple_wait_set(0, false, 0);
	}

	/* Final configuration */
	nrf_vpr_csr_vio_shift_ctrl_buffered_set(&shift_ctrl);
	nrf_vpr_csr_vio_out_buffered_reversed_word_set(0x00);

	/* Stop counter */
	nrf_vpr_csr_vtim_count_mode_set(0, NRF_VPR_CSR_VTIM_COUNT_STOP);

	/* Disable CS */
	if (!hrt_xfer_params->ce_hold) {

		out = nrf_vpr_csr_vio_out_get();

		if (hrt_xfer_params->ce_polarity == MSPI_CE_ACTIVE_LOW) {
			WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_HIGH);
		} else {
			WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_LOW);
		}
		nrf_vpr_csr_vio_out_set(out);
	}
}

void hrt_read(volatile hrt_xfer_t *hrt_xfer_params)
{
	uint16_t out;
	bool counter_running = false;
	nrf_vpr_csr_vio_shift_ctrl_t shift_ctrl = {
		.shift_count = 1,
		.out_mode = NRF_VPR_CSR_VIO_SHIFT_NONE,
		.frame_width = 4,
		.in_mode = NRF_VPR_CSR_VIO_MODE_IN_CONTINUOUS,
	};
	nrf_vpr_csr_vio_mode_out_t out_mode = {
		.mode = NRF_VPR_CSR_VIO_SHIFT_OUTB_TOGGLE,
		.frame_width = 1,
	};

	/* Enable CS */
	out = nrf_vpr_csr_vio_out_get();
	if (hrt_xfer_params->ce_polarity == MSPI_CE_ACTIVE_LOW) {
		WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_LOW);
	} else {
		WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_HIGH);
	}
	nrf_vpr_csr_vio_out_set(out);

	/* Configure clock and pins */
	// Set DQ1 as input
	WRITE_BIT(hrt_xfer_params->tx_direction_mask, 2, VPRCSR_NORDIC_DIR_INPUT);
	nrf_vpr_csr_vio_dir_set(hrt_xfer_params->tx_direction_mask);

	/* Initial configuration */
	nrf_vpr_csr_vio_mode_in_set(NRF_VPR_CSR_VIO_MODE_IN_SHIFT);
	nrf_vpr_csr_vio_mode_out_set(&out_mode);
	nrf_vpr_csr_vio_shift_cnt_out_set(BITS_IN_WORD / out_mode.frame_width);

	/* Counter settings */
	nrf_vpr_csr_vtim_count_mode_set(0, NRF_VPR_CSR_VTIM_COUNT_RELOAD);
	nrf_vpr_csr_vtim_count_mode_set(1, NRF_VPR_CSR_VTIM_COUNT_RELOAD);
	/* Set top counters value. Trigger data capture every two clock cycles */
	// nrf_vpr_csr_vtim_combined_counter_top_set(hrt_xfer_params->counter_value << VPRCSR_NORDIC_CNTTOP_CNT0RELOAD_Pos |
	// 											(2 * (hrt_xfer_params->counter_value + 1) - 1) << VPRCSR_NORDIC_CNTTOP_CNT1RELOAD_Pos);
	nrf_vpr_csr_vtim_simple_counter_top_set(0, hrt_xfer_params->counter_value);
	nrf_vpr_csr_vtim_simple_counter_top_set(1, 2 * (hrt_xfer_params->counter_value + 1) - 1);

	/* Transfer command */
	hrt_tx(&hrt_xfer_params->xfer_data[HRT_FE_COMMAND], hrt_xfer_params->io_mode.command, &counter_running, hrt_xfer_params->counter_value,
			1);

	// hrt_tx(&hrt_xfer_params->xfer_data[HRT_FE_COMMAND], hrt_xfer_params->io_mode.command, &counter_running, 16,
	// 		16 + 1);

	// nrf_vpr_csr_vtim_simple_wait_set(0, false, 0);

	for (uint8_t i = 0; i < hrt_xfer_params->xfer_data[HRT_FE_DATA].words; i++)
	{
		hrt_xfer_params->xfer_data[HRT_FE_DATA].rx_data[i] = hrt_xfer_params->xfer_data[HRT_FE_DATA].vio_inb_get();
	}

	/* Final configuration */
	nrf_vpr_csr_vio_shift_ctrl_buffered_set(&shift_ctrl);
	nrf_vpr_csr_vio_out_buffered_reversed_word_set(0);

	/* Stop counters */
	nrf_vpr_csr_vtim_count_mode_set(0, NRF_VPR_CSR_VTIM_COUNT_STOP);
	nrf_vpr_csr_vtim_count_mode_set(1, NRF_VPR_CSR_VTIM_COUNT_STOP);

	/* Disable CS */
	if (!hrt_xfer_params->ce_hold) {
		out = nrf_vpr_csr_vio_out_get();

		if (hrt_xfer_params->ce_polarity == MSPI_CE_ACTIVE_LOW) {
			WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_HIGH);
		} else {
			WRITE_BIT(out, hrt_xfer_params->ce_vio, VPRCSR_NORDIC_OUT_LOW);
		}
		nrf_vpr_csr_vio_out_set(out);
	}
}
