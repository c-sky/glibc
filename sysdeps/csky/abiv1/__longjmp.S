/* longjmp for C-SKY ABIV1.
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

ENTRY (__longjmp)
	mov	a2, a0
	mov	a0, a1		/* Get the return value in place.  */
	cmpnei	a0, 0
	bt	have_return
	movi	a0, 1		/* Can't let setjmp() return zero! */
have_return:
#ifdef CHECK_SP
	ldw	r10, (a2, 0)	/* jmpbuf's sp */
#ifdef PTR_MANGLE
	PTR_DEMANGLE (r10, r10, a3)
#endif
	CHECK_SP (r10)
#endif
	ldw	sp, (a2, 0)
	ldw	lr, (a2, 4)
	ldw	r8, (a2, 8)
	ldw	r9, (a2, 12)
	ldw	r10, (a2, 16)
	ldw	r11, (a2, 20)
	ldw	r12, (a2, 24)
	ldw	r13, (a2, 28)
	ldw	r14, (a2, 32)
	addi	a2, 32
	addi	a2, 4

#ifdef PTR_MANGLE
	PTR_DEMANGLE (sp, sp, a3)
	PTR_DEMANGLE2 (lr, lr, a3)
#endif
	jmp	lr

END (__longjmp)
