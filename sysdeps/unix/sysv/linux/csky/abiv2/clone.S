/* Wrapper around clone system call.  C-SKY ABIV2 version.
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

/* clone() is even more special than fork() as it mucks with stacks
   and invokes a function in the right context after its all over.  */

#include <sysdep.h>
#define _ERRNO_H	1
#include <bits/errno.h>

/* int clone (int (*fn) (void *arg), void *child_stack, int flags, void *arg,
	      pid_t *ptid, struct user_desc *tls, pid_t *ctid); */

        .text
ENTRY (__clone)
	/* Sanity check arguments.  */
	cmpnei	a0, 0		/* no NULL function pointers */
	bf	__error_arg
	cmpnei	a1, 0		/* no NULL stack pointers */
	bf	__error_arg

	subi	a1, 8
	stw	a0, (a1, 0)	/* insert the function into the new stack */
	stw	a3, (a1, 4)	/* insert the args into the new stack */

	mov	t1, r7		/* save r7 */
	mov	t2, r4		/* save r4 */

	mov	a0, a2		/* arg1 = flags */
	ldw	a2, (sp, 0)	/* arg3 = ptid */
	ldw	a3, (sp, 8)	/* arg4 = ctid */
	ldw	r4, (sp, 4)	/* arg5 = tls */
	lrw	r7, __NR_clone
	trap	0

	mov	r7, t1		/* restore r7 */
	mov	r4, t2		/* restore r4 */
	btsti	a0, 31		/* is a0 less than zero? */
	bt	__do_syscall_error
	cmpnei	a0, 0
	bf	__thread_start
	rts

__error_arg:
	lrw	a0, -EINVAL

__do_syscall_error:
#ifdef __PIC__
	subi	sp, 8
	stw	gb, (sp, 0)
	stw	r15, (sp, 4)
	grs	gb, .Lgetpc
.Lgetpc:
	lrw	t0, .Lgetpc@GOTPC
	addu	gb, gb, t0
	lrw	t0, __syscall_error@PLT
	ldr.w	t0, (gb, t0 << 0)
	jsr	t0
	ldw	gb, (sp, 0)
	ldw	r15, (sp, 4)
	addi	sp, 8
#else
	jmpi	__syscall_error
#endif /* __PIC__ */
	rts
PSEUDO_END (__clone)

ENTRY (__thread_start)
	.cfi_label .Ldummy
	cfi_undefined (lr)
	ldw	a0, (sp, 4)	/* restore args from new sp */
	ldw	a1, (sp, 0)	/* restore function from new sp */
	addi	sp, 8
	jsr	a1

	/* exit */
	lrw	r7, __NR_exit
	trap	0
END (__thread_start)

libc_hidden_def (__clone)
weak_alias (__clone, clone)
