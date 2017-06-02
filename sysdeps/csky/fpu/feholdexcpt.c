/* Store current floating-point environment and clear exceptions.
   Copyright (C) 2000 Free Software Foundation, Inc.
   This file is part of the GNU C Library.
   Contributed by Andreas Jaeger <aj@suse.de>, 2000.

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

#include <fenv.h>
#include <fpu_control.h>
#include <fenv_libc.h>

int
__feholdexcept (fenv_t *envp)
{
#ifdef __csky_hard_float__
  unsigned int fpsr;
  unsigned int fpcr;

  _FPU_GETCW (fpcr);
  envp->__fpcr = fpcr;

  _FPU_GETFPSR (fpsr);
  envp->__fpsr = fpsr;

  /* Now set all exceptions to non-stop.  */
  fpcr &= ~FE_ALL_EXCEPT;

  /* And clear all exception flags.  */
  fpsr &= ~(FE_ALL_EXCEPT << CAUSE_SHIFT);

  _FPU_SETFPSR (fpsr);

  _FPU_SETCW (fpcr);

  return 0;
#else
  /* Unsupported, so fail.  */
  return 1;
#endif
}
libm_hidden_def (__feholdexcept)
weak_alias (__feholdexcept, feholdexcept)
libm_hidden_weak (feholdexcept)

