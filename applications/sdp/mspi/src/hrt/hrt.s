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
	.section	.text.hrt_write,"ax",@progbits
	.align	1
	.globl	hrt_write
	.type	hrt_write, @function
hrt_write:
	addi	sp,sp,-16
	sw	s0,8(sp)
	sw	ra,12(sp)
	lhu	a5,70(a0)
	mv	s0,a0
	sb	zero,3(sp)
 #APP
	csrw 3009, a5
 #NO_APP
	lw	a5,4(a0)
	beq	a5,zero,.L14
	lbu	a5,60(a0)
	li	a4,0
	andi	a5,a5,0xff
.L15:
 #APP
	csrw 2000, 2
 #NO_APP
	lhu	a3,64(s0)
	slli	a3,a3,16
	srli	a3,a3,16
 #APP
	csrr a2, 2003
 #NO_APP
	li	a1,-65536
	and	a2,a2,a1
	or	a3,a3,a2
 #APP
	csrw 2003, a3
	csrw 3011, 0
 #NO_APP
	li	a2,2031616
	slli	a3,a5,16
	and	a3,a3,a2
	ori	a3,a3,4
 #APP
	csrw 3043, a3
 #NO_APP
	li	a3,20
	mul	a4,a4,a3
	li	a2,1
	add	a4,s0,a4
	lw	a3,4(a4)
	beq	a3,a2,.L17
	li	a2,2
	beq	a3,a2,.L18
	li	a4,32
	div	a5,a4,a5
	j	.L34
.L14:
	lw	a5,24(a0)
	beq	a5,zero,.L16
	lbu	a5,61(a0)
	li	a4,1
	andi	a5,a5,0xff
	j	.L15
.L16:
	lw	a5,44(a0)
	lbu	a5,62(a0)
	li	a4,2
	andi	a5,a5,0xff
	j	.L15
.L17:
	lbu	a5,8(a4)
.L34:
 #APP
	csrw 3022, a5
	csrr a5, 3008
 #NO_APP
	lbu	a4,68(s0)
	lbu	a3,66(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L21
	li	a4,1
	sll	a4,a4,a3
	not	a4,a4
	and	a5,a5,a4
.L22:
 #APP
	csrw 3008, a5
 #NO_APP
	lbu	a1,60(s0)
	lhu	a3,64(s0)
	addi	a2,sp,3
	mv	a0,s0
	call	hrt_tx
	lbu	a1,61(s0)
	lhu	a3,64(s0)
	addi	a2,sp,3
	addi	a0,s0,20
	call	hrt_tx
	lbu	a1,62(s0)
	lhu	a3,64(s0)
	addi	a2,sp,3
	addi	a0,s0,40
	call	hrt_tx
	lbu	a5,69(s0)
	beq	a5,zero,.L23
.L24:
 #APP
	csrr a5, 3022
 #NO_APP
	andi	a5,a5,0xff
	bne	a5,zero,.L24
 #APP
	csrw 2010, 0
 #NO_APP
.L23:
	li	a5,16384
	addi	a5,a5,1
 #APP
	csrw 3019, a5
	csrw 3017, 0
	csrw 2000, 0
 #NO_APP
	lbu	a5,67(s0)
	bne	a5,zero,.L13
 #APP
	csrr a5, 3008
 #NO_APP
	lbu	a4,68(s0)
	lbu	a3,66(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L26
	li	a4,1
	sll	a4,a4,a3
	or	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
.L27:
 #APP
	csrw 3008, a5
 #NO_APP
<<<<<<< HEAD
=======
.L21:
 #APP
	csrw 2000, 0
 #NO_APP
	ret
.L2:
	lbu	a5,21(a0)
	li	a4,1
	lbu	a2,21(a0)
	sll	a5,a4,a5
	not	a5,a5
	and	a5,a5,a3
	sll	a4,a4,a2
	or	a5,a5,a4
	j	.L26
.L17:
	lw	a3,8(a0)
	sub	a3,a3,a5
	beq	a3,a2,.L5
	beq	a3,a1,.L6
.L7:
	lbu	t1,20(a0)
	andi	a3,t1,0xff
	beq	t1,a2,.L12
	beq	a3,a1,.L13
	bne	a3,zero,.L11
	lw	a3,4(a0)
	add	a3,a3,a4
	lw	a3,0(a3)
	j	.L27
.L5:
	lbu	a3,12(a0)
	addi	a3,a3,-1
	andi	a3,a3,0xff
 #APP
	csrw 3023, a3
 #NO_APP
	lbu	t1,20(a0)
	andi	a3,t1,0xff
	beq	t1,a2,.L8
	beq	a3,a1,.L9
	bne	a3,zero,.L11
	lw	a3,16(a0)
.L27:
 #APP
	csrw 3012, a3
 #NO_APP
.L11:
	bne	a5,zero,.L15
	lhu	a3,0(a0)
 #APP
	csrw 2005, a3
	csrr t1, 3022
 #NO_APP
	andi	t1,t1,0xff
.L16:
 #APP
	csrr a3, 3022
 #NO_APP
	andi	a3,a3,0xff
	beq	t1,a3,.L16
.L15:
	addi	a5,a5,1
	addi	a4,a4,4
	j	.L4
.L8:
	lw	a3,16(a0)
.L29:
 #APP
	csrw 3016, a3
 #NO_APP
	j	.L11
<<<<<<< HEAD
.L9:
	lw	a3,16(a0)
.L28:
 #APP
	csrw 3017, a3
 #NO_APP
	j	.L11
.L6:
	lbu	a3,13(a0)
	addi	a3,a3,-1
	andi	a3,a3,0xff
 #APP
	csrw 3023, a3
 #NO_APP
	j	.L7
.L12:
	lw	a3,4(a0)
	add	a3,a3,a4
	lw	a3,0(a3)
	j	.L29
.L13:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L18:
	lbu	a5,9(a4)
	j	.L34
.L21:
	li	a4,1
	sll	a4,a4,a3
	or	a5,a5,a4
	slli	a5,a5,16
	srli	a5,a5,16
	j	.L22
.L26:
	li	a4,1
	sll	a4,a4,a3
	not	a4,a4
	and	a5,a5,a4
	j	.L27
	.size	hrt_write, .-hrt_write
