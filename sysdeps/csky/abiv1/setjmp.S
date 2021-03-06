/* setjmp for C-SKY ABIV1.
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

ENTRY (setjmp)
	movi	a1, 1
	br	__sigsetjmp
END (setjmp)

ENTRY (_setjmp)
	movi	a1, 0
	br	__sigsetjmp
END (_setjmp)

libc_hidden_def (_setjmp)

ENTRY (__sigsetjmp)
	mov	a2, a0
	/* Save registers.  */

#ifdef PTR_MANGLE
	mov	r6, sp
	PTR_MANGLE (r6, r6, a3)
	stw	r6, (a2, 0)
	mov	r6, lr
	PTR_MANGLE2 (r6, r6, a3)
	stw	r6, (a2, 4)
#else
	stw	sp, (a2, 0)
	stw	lr, (a2, 4)
#endif
	stw	r8, (a2, 8)
	stw	r9, (a2, 12)
	stw	r10, (a2, 16)
	stw	r11, (a2, 20)
	stw	r12, (a2, 24)
	stw	r13, (a2, 28)
	stw	r14, (a2, 32)
	addi	a2, 32
	addi	a2, 4

#ifdef __PIC__
	mov	a3, lr
	bsr	.Lgetpc
.Lgetpc:
	lrw	r7, .Lgetpc@GOTPC
	addu	r7, lr
	lrw	a2, __sigjmp_save@PLT
	addu	r7, a2
	ldw	r7, (r7)
	mov	lr, a3
	jmp	r7
#else
	jmpi	__sigjmp_save
#endif /* !__PIC__ */

END (__sigsetjmp)

hidden_def (__sigsetjmp)
