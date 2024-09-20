/*
 * Copyright (c) 2016 Intel Corporation
 * Copyright (c) 2020 Nordic Semiconductor ASA
 *
 * SPDX-License-Identifier: Apache-2.0
 */

/**
 * @file Sample app to demonstrate PWM.
 */

#include <zephyr/kernel.h>
#include <zephyr/sys/printk.h>
#include <zephyr/device.h>
#include <zephyr/drivers/pwm.h>

static const struct pwm_dt_spec pwm_led0 = PWM_DT_SPEC_GET(DT_ALIAS(pwm_led0));

int main(void)
{
	uint32_t period;
	int ret;

	printk("Hello from vpr core\n");

	period = PWM_MSEC(250U);

	ret = pwm_set_dt(&pwm_led0, period, period / 2U);
	if (ret) {
		printk("Error %d: failed to set pulse width\n", ret);
		return 0;
	}

	while (1) {
		k_sleep(K_SECONDS(1U));
	}
	return 0;
}
