/* longjmp with sp check for C-SKY ABIV1
   Copyright (C) 2018 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library.  If not, see
   <http://www.gnu.org/licenses/>.  */

#include <sysdep.h>

	.section .rodata.str1.8,"aMS",@progbits,1
	.align  2
	.type   longjmp_msg,@object
longjmp_msg:
	.string "longjmp causes uninitialized stack frame"
	.size   longjmp_msg, .-longjmp_msg
	.text

#define __longjmp ____longjmp_chk

#ifdef	__PIC__
# define CALL_FAIL	\
	subi	sp, 8;						\
	stw	gb, (sp);					\
	stw	r15, (sp, 4);					\
	bsr	.Lgetpc2;					\
.Lgetpc2:							\
	lrw	gb, .Lgetpc2@GOTPC;				\
	add	gb, r15;					\
	lrw	a0, longjmp_msg@GOTOFF;				\
	addu	a0, gb;						\
	lrw	r7, (HIDDEN_JUMPTARGET (__fortify_fail))@PLT;	\
	add	r7, gb;						\
	ldw	r7, (r7);					\
	jsr	r7;						\
	ldw	gb, (sp, 0);					\
	ldw	r15,(sp, 4);					\
	addi	sp, 8;
#else /* __PIC__ */
# define CALL_FAIL	\
	lrw	a0, longjmp_msg;				\
	jsri	HIDDEN_JUMPTARGET (__fortify_fail);
#endif/* __PIC__ */

# define  CHECK_SP(reg)	\
	cmplt	sp, reg;					\
	bt	.Lok1;						\
	mov	r9, a0;						\
	lrw	r1, __NR_sigaltstack;				\
	movi	a0, 0;						\
	subi	sp, 12;	/* sizeof (stack_t) */			\
	mov	a1, sp;						\
	trap	0;						\
	cmpnei	a0, 0;						\
	bt	.Lok;						\
	ldw	a1, (sp, 4);					\
	btsti	a1, 1;						\
	bt	.Lfail;						\
	ldw	a1, (sp, 0);					\
	ldw	a3, (sp, 8);					\
	add	a1, a3;						\
	sub	a1, reg;					\
	cmphs	a1, a3;						\
	bt	.Lok;						\
.Lfail:								\
	addi	sp, 12;						\
	CALL_FAIL						\
.Lok:								\
	mov	a0, r9;						\
.Lok1:

#include <__longjmp.S>
