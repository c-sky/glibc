/* The assembly function for string compare.  C-SKY ABIV1 version.
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

ENTRY (strcmp)
	mov	r6, r2
	or	r2, r3
	andi	r2, 0x3
	cmpnei	r2, 0x0	/* d or s is aligned? */
	bt	4f	/* If not aligned, goto 4f.  */
1:	/* If aligned, load word each time.  */
	ldw	r2, (r6, 0)
	ldw	r7, (r3, 0)
	cmpne	r2, r7
	bt	1f	/* If d[i] != s[i], goto 1f.  */
	tstnbz	r2	/* If d[i] == s[i], check if d or s is at the end.  */
	bf	3f	/* If at the end, goto 3f (finish comparing).  */

	ldw	r2, (r6, 4)
	ldw	r7, (r3, 4)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 8)
	ldw	r7, (r3, 8)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 12)
	ldw	r7, (r3, 12)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 16)
	ldw	r7, (r3, 16)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 20)
	ldw	r7, (r3, 20)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 24)
	ldw	r7, (r3, 24)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	ldw	r2, (r6, 28)
	ldw	r7, (r3, 28)
	cmpne	r2, r7
	bt	1f
	tstnbz	r2
	bf	3f

	addi	r6, 32
	addi	r3, 32
	br	1b

#ifdef __CSKYBE__
	/* d[i] != s[i] in word, so we check byte 0.  */
1:
	xtrb0	r1, r2
	mov	r4, r1
	xtrb0	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 1 */
	xtrb1	r1, r2
	mov	r4, r1
	xtrb1	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 2 */
	xtrb2	r1, r2
	mov	r4, r1
	xtrb2	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 3 */
	xtrb3	r1, r2
	mov	r4, r1
	xtrb3	r1, r7

#else /* little endian */
	/* d[i] != s[i] in word, so we check byte 3.  */
1:
	xtrb3	r1, r2
	mov	r4, r1
	xtrb3	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 2 */
	xtrb2	r1, r2
	mov	r4, r1
	xtrb2	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 1 */
	xtrb1	r1, r2
	mov	r4, r1
	xtrb1	r1, r7
	cmpne	r4, r1
	bt	2f
	cmpnei	r4, 0
	bf	2f

	/* check byte 0 */
	xtrb0	r1, r2
	mov	r4, r1
	xtrb0	r1, r7

#endif
	/* Get the result when d[i] != s[i].  */
2:
	subu	r4, r1
	mov	r2, r4
	jmp	r15

	/* Return when d[i] == s[i].  */
3:
	subu	r2, r7
	jmp	r15

	/* cmp when d or s is not aligned.  */
4:
	ldb	r2, (r6, 0)
	ldb	r7, (r3, 0)
	cmpne	r2, r7
	bt	3b
	addi	r3, 1
	addi	r6, 1
	cmpnei	r2, 0
	bt	4b
	jmp	r15
END (strcmp)

libc_hidden_def (strcmp)
.weak strcmp
