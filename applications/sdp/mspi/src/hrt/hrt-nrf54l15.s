	.file	"hrt.c"
	.option nopic
	.attribute arch, "rv32e1p9_m2p0_c2p0_zicsr2p0"
	.attribute unaligned_access, 0
	.attribute stack_align, 4
	.text
	.section	.text.hrt_tx,"ax",@progbits
	.align	1
	.type	hrt_tx, @function
hrt_tx:
	addi	sp,sp,-24
	sw	ra,20(sp)
	sw	s0,16(sp)
	sw	s1,12(sp)
	lw	a4,4(a0)
	sw	a2,0(sp)
	sw	a3,4(sp)
	beq	a4,zero,.L1
	slli	a3,a1,12
	li	a4,126976
	and	a3,a3,a4
	li	a4,32
	div	a4,a4,a1
	mv	s0,a0
	addi	a4,a4,-1
	andi	a4,a4,63
	or	a4,a4,a3
	ori	a4,a4,1024
 #APP
	csrw 3019, a4
 #NO_APP
	li	s1,0
.L3:
	lw	a4,4(s0)
	bltu	s1,a4,.L9
.L1:
	lw	ra,20(sp)
	lw	s0,16(sp)
	lw	s1,12(sp)
	addi	sp,sp,24
	jr	ra
.L9:
	lw	a4,4(s0)
	li	a1,1
	sub	a4,a4,s1
	beq	a4,a1,.L4
	li	a1,2
	beq	a4,a1,.L5
.L6:
	lw	a1,16(s0)
	lw	a4,0(s0)
	slli	a0,s1,2
	sw	a3,8(sp)
	add	a4,a4,a0
	lw	a0,0(a4)
	jalr	a1
	j	.L12
.L4:
	lbu	a4,8(s0)
	sw	a3,8(sp)
	addi	a4,a4,-1
	andi	a4,a4,63
	or	a4,a4,a3
	ori	a4,a4,1024
 #APP
	csrw 3019, a4
 #NO_APP
	lw	a4,16(s0)
	lw	a0,12(s0)
	jalr	a4
.L12:
	lw	a3,8(sp)
	bne	s1,zero,.L8
	lw	a5,0(sp)
	lbu	a4,0(a5)
	bne	a4,zero,.L8
	lw	a5,4(sp)
 #APP
	csrw 2005, a5
 #NO_APP
	lw	a5,0(sp)
	li	a4,1
	sb	a4,0(a5)
.L8:
	addi	s1,s1,1
	j	.L3
.L5:
	lbu	a4,9(s0)
	addi	a4,a4,-1
	andi	a4,a4,63
	or	a4,a4,a3
	ori	a4,a4,1024
 #APP
	csrw 3019, a4
 #NO_APP
	j	.L6
	.size	hrt_tx, .-hrt_tx
	.section	.text.hrt_tx_rx.part.0.constprop.0,"ax",@progbits
	.align	1
	.type	hrt_tx_rx.part.0.constprop.0, @function
hrt_tx_rx.part.0.constprop.0:
	addi	sp,sp,-24
	sw	s0,16(sp)
	sw	ra,20(sp)
	sw	s1,12(sp)
	lw	a5,0(a0)
	li	a4,126976
	slli	a1,a1,12
	and	a1,a1,a4
	li	a4,2097152
	addi	a4,a4,1031
	mv	s0,a0
	lw	a5,0(a5)
	or	a1,a1,a4
 #APP
	csrw 3019, a1
 #NO_APP
	li	s1,0
.L14:
	lw	a4,4(s0)
	bltu	s1,a4,.L17
	lw	ra,20(sp)
	lw	s0,16(sp)
	lw	s1,12(sp)
	addi	sp,sp,24
	jr	ra
.L17:
	lw	a4,16(s0)
	li	a0,-16777216
	and	a0,a5,a0
	sw	a3,8(sp)
	sw	a2,4(sp)
	sw	a5,0(sp)
	jalr	a4
	lw	a5,0(sp)
	lw	a2,4(sp)
	lw	a3,8(sp)
	slli	a5,a5,8
	bne	s1,zero,.L15
	beq	a2,zero,.L15
	li	a4,65536
	add	a4,a3,a4
 #APP
	csrw 2002, a4
 #NO_APP
.L16:
	addi	s1,s1,1
	j	.L14
.L15:
 #APP
	csrr a4, 3018
 #NO_APP
	j	.L16
	.size	hrt_tx_rx.part.0.constprop.0, .-hrt_tx_rx.part.0.constprop.0
	.section	.text.hrt_write,"ax",@progbits
	.align	1
	.globl	hrt_write
	.type	hrt_write, @function
hrt_write:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	lhu	a5,82(a0)
	mv	s0,a0
	sb	zero,3(sp)
 #APP
	csrw 3009, a5
 #NO_APP
	lw	a5,4(a0)
	beq	a5,zero,.L23
	lbu	a3,72(a0)
	li	a5,0
.L24:
 #APP
	csrw 2000, 2
 #NO_APP
	lhu	a4,76(s0)
 #APP
	csrr a2, 2003
 #NO_APP
	li	a1,-65536
	and	a2,a2,a1
	or	a4,a4,a2
 #APP
	csrw 2003, a4
	csrw 3011, 0
 #NO_APP
	li	a2,2031616
	slli	a4,a3,16
	and	a4,a4,a2
	ori	a4,a4,4
 #APP
	csrw 3043, a4
 #NO_APP
	li	a4,24
	mul	a5,a5,a4
	li	a2,1
	add	a5,s0,a5
	lw	a4,4(a5)
	beq	a4,a2,.L26
	li	a2,2
	beq	a4,a2,.L27
	li	a5,32
	div	a5,a5,a3
	j	.L42
.L23:
	lw	a5,28(a0)
	beq	a5,zero,.L25
	lbu	a3,73(a0)
	li	a5,1
	j	.L24
.L25:
	lbu	a3,74(a0)
	li	a5,2
	j	.L24
.L26:
	lbu	a5,8(a5)
.L42:
 #APP
	csrw 3022, a5
 #NO_APP
	lbu	a4,78(s0)
	li	a5,1
	sll	a5,a5,a4
	lbu	a4,80(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L30
 #APP
	csrc 3008, a5
 #NO_APP
.L31:
	lhu	a3,76(s0)
	lbu	a1,72(s0)
	addi	a2,sp,3
	mv	a0,s0
	call	hrt_tx
	lhu	a3,76(s0)
	lbu	a1,73(s0)
	addi	a2,sp,3
	addi	a0,s0,24
	call	hrt_tx
	lhu	a3,76(s0)
	lbu	a1,74(s0)
	addi	a2,sp,3
	addi	a0,s0,48
	call	hrt_tx
	lbu	a5,81(s0)
	beq	a5,zero,.L32
.L33:
 #APP
	csrr a5, 3022
 #NO_APP
	andi	a5,a5,0xff
	bne	a5,zero,.L33
 #APP
	csrw 2010, 0
 #NO_APP
.L32:
	li	a5,16384
	addi	a5,a5,1
 #APP
	csrw 3019, a5
	csrw 3017, 0
	csrw 2000, 0
 #NO_APP
	lbu	a5,79(s0)
	bne	a5,zero,.L22
	lbu	a4,78(s0)
	li	a5,1
	sll	a5,a5,a4
	lbu	a4,80(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L35
 #APP
	csrs 3008, a5
 #NO_APP
.L22:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L27:
	lbu	a5,9(a5)
	j	.L42
.L30:
 #APP
	csrs 3008, a5
 #NO_APP
	j	.L31
.L35:
 #APP
	csrc 3008, a5
 #NO_APP
	j	.L22
	.size	hrt_write, .-hrt_write
	.section	.text.hrt_read,"ax",@progbits
	.align	1
	.globl	hrt_read
	.type	hrt_read, @function
hrt_read:
	addi	sp,sp,-12
	sw	s0,4(sp)
	sw	ra,8(sp)
	sw	s1,0(sp)
	mv	s0,a0
 #APP
	csrr a5, 3008
 #NO_APP
	lbu	a4,80(a0)
	lbu	a3,78(a0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L44
	li	a4,1
	sll	a4,a4,a3
	not	a4,a4
	and	a5,a5,a4
.L45:
 #APP
	csrw 3008, a5
 #NO_APP
	lhu	a5,82(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	andi	a5,a5,-5
	slli	a5,a5,16
	srli	a5,a5,16
	sh	a5,82(s0)
	lhu	a5,82(s0)
 #APP
	csrw 3009, a5
	csrw 3011, 2
 #NO_APP
	li	a5,65536
	addi	a5,a5,4
 #APP
	csrw 3043, a5
	csrw 3022, 8
	csrw 2000, 2
	csrw 2001, 2
 #NO_APP
	lhu	a5,76(s0)
	slli	a5,a5,16
	srli	a5,a5,16
 #APP
	csrr a4, 2003
 #NO_APP
	li	a3,-65536
	and	a4,a4,a3
	or	a5,a5,a4
 #APP
	csrw 2003, a5
 #NO_APP
	lhu	a5,76(s0)
	slli	a5,a5,16
	srli	a5,a5,16
 #APP
	csrr a4, 2003
 #NO_APP
	slli	a5,a5,1
	slli	a4,a4,16
	addi	a5,a5,1
	srli	a4,a4,16
	slli	a5,a5,16
	or	a5,a5,a4
 #APP
	csrw 2003, a5
 #NO_APP
	lbu	a1,72(s0)
	lhu	a3,76(s0)
	lw	a5,4(s0)
	andi	a1,a1,0xff
	slli	a3,a3,16
	srli	a3,a3,16
	beq	a5,zero,.L46
	li	a2,1
	mv	a0,s0
	call	hrt_tx_rx.part.0.constprop.0
.L46:
	lbu	a1,73(s0)
	lhu	a3,76(s0)
	lw	a5,28(s0)
	andi	a1,a1,0xff
	slli	a3,a3,16
	srli	a3,a3,16
	beq	a5,zero,.L47
	li	a2,0
	addi	a0,s0,24
	call	hrt_tx_rx.part.0.constprop.0
.L47:
	li	s1,0
.L48:
	lw	a5,52(s0)
	bltu	s1,a5,.L49
 #APP
	csrw 2000, 0
	csrw 2001, 0
	csrw 3019, 0
 #NO_APP
	lbu	a5,79(s0)
	bne	a5,zero,.L50
 #APP
	csrr a5, 3008
 #NO_APP
	lbu	a4,80(s0)
	lbu	a3,78(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L51
	li	a4,1
	sll	a4,a4,a3
	or	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
.L52:
 #APP
	csrw 3008, a5
 #NO_APP
.L50:
	lhu	a5,82(s0)
	ori	a5,a5,4
	sh	a5,82(s0)
	lhu	a5,82(s0)
 #APP
	csrw 3009, a5
 #NO_APP
	lw	ra,8(sp)
	lw	s0,4(sp)
	lw	s1,0(sp)
	addi	sp,sp,12
	jr	ra
.L44:
	li	a4,1
	sll	a4,a4,a3
	or	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L45
.L49:
	lw	a5,68(s0)
	jalr	a5
	lw	a5,48(s0)
	srli	a0,a0,24
	add	a5,a5,s1
	addi	s1,s1,1
	sb	a0,0(a5)
	andi	s1,s1,0xff
	j	.L48
.L51:
	li	a4,1
	sll	a4,a4,a3
	not	a4,a4
	and	a5,a5,a4
	j	.L52
	.size	hrt_read, .-hrt_read
