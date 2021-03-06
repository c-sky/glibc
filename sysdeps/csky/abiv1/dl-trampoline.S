/* PLT trampolines.  C-SKY ABIV1 version.
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

/* This function is not called directly.  It is jumped when attempting
   to use a symbol that has not yet been resolved.

   .plt*:
     subi r0, 32
     stw r2, (r0, 0)
     stw r3, (r0, 4)
     lrw r3, #offset
     ldw r2, (gb, 8)
     jmp r2
 */

#include <sysdep.h>

.text
ENTRY (_dl_runtime_resolve)
	stw	r4, (r0, 8)
	stw	r5, (r0, 12)
	stw	r6, (r0, 16)
	stw	r7, (r0, 20)
	stw	r15, (r0, 24)
	/* Load the ID of this module.  */
	ldw	r2, (gb, 4)
	mov	r6, r3
	addu	r6, r6
	addu	r3, r6
	lsli	r3, 2
	/* r2 = id, r3 = offset(do it in plt*) */
	/* Get global offset table address.  */
	bsr	.L2
.L2:
	lrw	r7, .L2@GOTPC
	add	r7, r15
	/* Get the address of function (_dl_fixup) in got table.  */
	lrw	r6, _dl_fixup@GOT
	add	r6, r7
	ldw	r5, (r6, 0)
	jsr	r5
	/* Return from _dl_fixup, the address of function is in r2.  */
	mov	r1, r2
	/* Restore the registers.  */
	ldw	r2, (r0, 0)
	ldw	r3, (r0, 4)
	ldw	r4, (r0, 8)
	ldw	r5, (r0, 12)
	ldw	r6, (r0, 16)
	ldw	r7, (r0, 20)
	ldw	r15, (r0, 24)
	/* Restore the r0, because r0 is subtracted in PLT table.  */
	addi	r0, 32
	/* The address of function is in r1, call the function
	   without saving pc.  */
	jmp	r1
END (_dl_runtime_resolve)
