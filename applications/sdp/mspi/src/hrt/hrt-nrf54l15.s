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
	lw	a4,8(a0)
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
	lw	a4,8(s0)
	bltu	s1,a4,.L9
.L1:
	lw	ra,20(sp)
	lw	s0,16(sp)
	lw	s1,12(sp)
	addi	sp,sp,24
	jr	ra
.L9:
	lw	a4,8(s0)
	li	a1,1
	sub	a4,a4,s1
	beq	a4,a1,.L4
	li	a1,2
	beq	a4,a1,.L5
.L6:
	lw	a1,20(s0)
	lw	a4,0(s0)
	slli	a0,s1,2
	sw	a3,8(sp)
	add	a4,a4,a0
	lw	a0,0(a4)
	jalr	a1
	j	.L12
.L4:
	lbu	a4,12(s0)
	sw	a3,8(sp)
	addi	a4,a4,-1
	andi	a4,a4,63
	or	a4,a4,a3
	ori	a4,a4,1024
 #APP
	csrw 3019, a4
 #NO_APP
	lw	a4,20(s0)
	lw	a0,16(s0)
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
	lbu	a4,13(s0)
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
	lhu	a5,94(a0)
	mv	s0,a0
	sb	zero,3(sp)
 #APP
	csrw 3009, a5
 #NO_APP
	lw	a5,8(a0)
	beq	a5,zero,.L14
	lbu	a3,84(a0)
	li	a5,0
.L15:
 #APP
	csrw 2000, 2
 #NO_APP
	lhu	a4,88(s0)
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
	li	a4,28
	mul	a5,a5,a4
	li	a2,1
	add	a5,s0,a5
	lw	a4,8(a5)
	beq	a4,a2,.L17
	li	a2,2
	beq	a4,a2,.L18
	li	a5,32
	div	a5,a5,a3
	j	.L33
.L14:
	lw	a5,36(a0)
	beq	a5,zero,.L16
	lbu	a3,85(a0)
	li	a5,1
	j	.L15
.L16:
	lbu	a3,86(a0)
	li	a5,2
	j	.L15
.L17:
	lbu	a5,12(a5)
.L33:
 #APP
	csrw 3022, a5
 #NO_APP
	lbu	a4,90(s0)
	li	a5,1
	sll	a5,a5,a4
	lbu	a4,92(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L21
 #APP
	csrc 3008, a5
 #NO_APP
.L22:
	lhu	a3,88(s0)
	lbu	a1,84(s0)
	addi	a2,sp,3
	mv	a0,s0
	call	hrt_tx
	lhu	a3,88(s0)
	lbu	a1,85(s0)
	addi	a2,sp,3
	addi	a0,s0,28
	call	hrt_tx
	lhu	a3,88(s0)
	lbu	a1,86(s0)
	addi	a2,sp,3
	addi	a0,s0,56
	call	hrt_tx
	lbu	a5,93(s0)
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
	lbu	a5,91(s0)
	bne	a5,zero,.L13
	lbu	a4,90(s0)
	li	a5,1
	sll	a5,a5,a4
	lbu	a4,92(s0)
	slli	a5,a5,16
	srli	a5,a5,16
	bne	a4,zero,.L26
 #APP
	csrs 3008, a5
 #NO_APP
.L13:
	lw	ra,12(sp)
	lw	s0,8(sp)
	addi	sp,sp,16
	jr	ra
.L18:
	lbu	a5,13(a5)
	j	.L33
.L21:
 #APP
	csrs 3008, a5
 #NO_APP
	j	.L22
.L26:
 #APP
	csrc 3008, a5
 #NO_APP
	j	.L13
	.size	hrt_write, .-hrt_write
	.section	.text.hrt_read,"ax",@progbits
	.align	1
	.globl	hrt_read
	.type	hrt_read, @function
hrt_read:
	addi	sp,sp,-28
	sw	s1,16(sp)
	sw	ra,24(sp)
	sw	s0,20(sp)
	mv	s1,a0
 #APP
	csrr a4, 3008
 #NO_APP
	lbu	a3,92(a0)
	lbu	a2,90(a0)
	slli	a4,a4,16
	srli	a4,a4,16
	bne	a3,zero,.L35
	li	a3,1
	sll	a3,a3,a2
	not	a3,a3
	and	a4,a4,a3
.L36:
 #APP
	csrw 3008, a4
 #NO_APP
	lhu	a4,94(s1)
	slli	a4,a4,16
	srli	a4,a4,16
	andi	a4,a4,-5
	slli	a4,a4,16
	srli	a4,a4,16
	sh	a4,94(s1)
	lhu	a4,94(s1)
 #APP
	csrw 3009, a4
	csrw 3011, 2
 #NO_APP
	li	a4,65536
	addi	a4,a4,4
 #APP
	csrw 3043, a4
 #NO_APP
	lw	a4,8(s1)
	slli	a4,a4,3
	andi	a4,a4,0xff
 #APP
	csrw 3022, a4
	csrw 2000, 2
	csrw 2001, 2
 #NO_APP
	lhu	a4,88(s1)
	slli	a4,a4,16
	srli	a4,a4,16
 #APP
	csrr a3, 2003
 #NO_APP
	li	a2,-65536
	and	a3,a3,a2
	or	a4,a4,a3
 #APP
	csrw 2003, a4
 #NO_APP
	lhu	a4,88(s1)
	slli	a4,a4,16
	srli	a4,a4,16
 #APP
	csrr a3, 2003
 #NO_APP
	slli	a4,a4,1
	slli	a3,a3,16
	addi	a4,a4,1
	srli	a3,a3,16
	slli	a4,a4,16
	or	a4,a4,a3
 #APP
	csrw 2003, a4
 #NO_APP
	lbu	s0,84(s1)
	lhu	a4,88(s1)
	andi	s0,s0,0xff
	slli	a5,a4,16
	lw	a4,8(s1)
	srli	a5,a5,16
	sw	a5,12(sp)
	beq	a4,zero,.L37
	slli	s0,s0,12
	li	a4,126976
	and	a5,s0,a4
	sw	a5,4(sp)
	li	a5,7
	sw	zero,8(sp)
	sw	a5,0(sp)
	li	s0,0
.L38:
	lw	a4,8(s1)
	bltu	s0,a4,.L47
.L37:
	li	s0,0
.L39:
	lw	a4,64(s1)
	bltu	s0,a4,.L48
 #APP
	csrw 3019, 0
	csrw 3017, 0
	csrw 2000, 0
	csrw 2001, 0
 #NO_APP
	lbu	a4,91(s1)
	bne	a4,zero,.L49
 #APP
	csrr a4, 3008
 #NO_APP
	lbu	a3,92(s1)
	lbu	a2,90(s1)
	slli	a4,a4,16
	srli	a4,a4,16
	bne	a3,zero,.L50
	li	a3,1
	sll	a3,a3,a2
	or	a4,a4,a3
	slli	a4,a4,16
	srli	a4,a4,16
.L51:
 #APP
	csrw 3008, a4
 #NO_APP
.L49:
	lhu	a4,94(s1)
	ori	a4,a4,4
	sh	a4,94(s1)
	lhu	a5,94(s1)
 #APP
	csrw 3009, a5
 #NO_APP
	lw	ra,24(sp)
	lw	s0,20(sp)
	lw	s1,16(sp)
	addi	sp,sp,28
	jr	ra
.L35:
	li	a3,1
	sll	a3,a3,a2
	or	a4,a4,a3
	slli	a4,a4,16
	srli	a4,a4,16
	j	.L36
.L47:
	lw	a4,8(s1)
	li	a2,1
	sub	a4,a4,s0
	beq	a4,a2,.L40
	li	a1,2
	slli	a2,s0,2
	beq	a4,a1,.L41
	lw	a5,0(sp)
	andi	a4,a5,63
	j	.L57
.L40:
	lbu	a4,12(s1)
	li	a2,2097152
	addi	a2,a2,1024
	addi	a4,a4,-1
	andi	a5,a4,0xff
	sw	a5,0(sp)
	lw	a5,4(sp)
	andi	a4,a4,63
	or	a4,a4,a5
	or	a4,a4,a2
 #APP
	csrw 3019, a4
 #NO_APP
	lw	a4,20(s1)
	lw	a0,16(s1)
	jalr	a4
.L43:
	bne	s0,zero,.L44
	lw	a5,8(sp)
	beq	a5,zero,.L45
.L46:
	li	a5,1
	sw	a5,8(sp)
.L44:
	addi	s0,s0,1
	j	.L38
.L41:
	lbu	a4,13(s1)
	addi	a4,a4,-1
	andi	a5,a4,0xff
	sw	a5,0(sp)
	andi	a4,a4,63
.L57:
	lw	a5,4(sp)
	li	a1,2097152
	addi	a1,a1,1024
	or	a4,a4,a5
	or	a4,a4,a1
 #APP
	csrw 3019, a4
 #NO_APP
	lw	a1,20(s1)
	lw	a4,0(s1)
	add	a4,a4,a2
	lw	a0,0(a4)
	jalr	a1
	j	.L43
.L45:
	lw	a5,12(sp)
	li	a4,65536
	add	a4,a5,a4
 #APP
	csrw 2002, a4
 #NO_APP
	j	.L46
.L48:
	lw	a4,80(s1)
	jalr	a4
	lw	a4,60(s1)
	srli	a0,a0,24
	add	a4,a4,s0
	addi	s0,s0,1
	sb	a0,0(a4)
	andi	s0,s0,0xff
	j	.L39
.L50:
	li	a3,1
	sll	a3,a3,a2
	not	a3,a3
	and	a4,a4,a3
	j	.L51
	.size	hrt_read, .-hrt_read
