/* FPU control word bits.  C-SKY version.
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

#ifndef _FPU_CONTROL_H
#define _FPU_CONTROL_H

/* C-SKY FPU floating point control register bits.
  
   31-28  -> reserved (read as 0, write with 0)
   27     -> 0: flush denormalized results to zero
             1: flush denormalized results to signed minimal normal number.
   26     -> reserved (read as 0, write with 0)
   25-24  -> rounding control
   23-6   -> reserved (read as 0, write with 0)
    5     -> enable exception for input denormalized exception
    4     -> enable exception for inexact exception
    3     -> enable exception for underflow exception
    2     -> enable exception for overflow exception
    1     -> enable exception for division by zero exception
    0     -> enable exception for invalid operation exception
  
   Rounding Control:
   00 - rounding to nearest (RN)
   01 - rounding toward zero (RZ)
   10 - rounding (up) toward plus infinity (RP)
   11 - rounding (down)toward minus infinity (RM)
  
   C-SKY FPU floating point exception status register bits.
  
   15     -> accumulate bit for any exception
   14     -> reserved (read as 0, write with 0)
   13     -> cause bit for input denormalized exception
   12     -> cause bit for inexact exception
   11     -> cause bit for underflow exception
   10     -> cause bit for overflow exception
    9     -> cause bit for division by zero exception
    8     -> cause bit for invalid operation exception
    7     -> flag bit for any exception
    6     -> reserved (read as 0, write with 0)
    5     -> flag exception for input denormalized exception
    4     -> flag exception for inexact exception
    3     -> flag exception for underflow exception
    2     -> flag exception for overflow exception
    1     -> flag exception for division by zero exception
    0     -> flag exception for invalid operation exception  */

#include <features.h>

/* masking of interrupts */
#define _FPU_MASK_IDE     (1 << 5)  /* input denormalized exception */
#define _FPU_MASK_IXE     (1 << 4)  /* inexact exception            */
#define _FPU_MASK_UFE     (1 << 3)  /* underflow exception          */
#define _FPU_MASK_OFE     (1 << 2)  /* overflow exception           */
#define _FPU_MASK_DZE     (1 << 1)  /* division by zero exception   */
#define _FPU_MASK_IOE     (1 << 0)  /* invalid operation exception  */

#define _FPU_MASK_FEA     (1 << 15) /* case for any exception */
#define _FPU_MASK_FEC     (1 << 7)  /* flag for any exception */

/* flush denormalized numbers to zero */
#define _FPU_FLUSH_TZ   0x8000000

/* rounding control */
#define _FPU_RC_NEAREST (0x0 << 24)     /* RECOMMENDED */
#define _FPU_RC_ZERO    (0x1 << 24)
#define _FPU_RC_UP      (0x2 << 24)
#define _FPU_RC_DOWN    (0x3 << 24)

#define _FPU_RESERVED      0xf460ffc0  /* Reserved bits in cw */
#define _FPU_FPSR_RESERVED 0xffff4040

/* The fdlibm code requires strict IEEE double precision arithmetic,
   and no interrupts for exceptions, rounding to nearest.  */

#define _FPU_DEFAULT        0x00000000
#define _FPU_FPSR_DEFAULT   0x00000000

/* IEEE:  same as above, but exceptions */
#define _FPU_FPCR_IEEE     0x0000001F
#define _FPU_FPSR_IEEE     0x00000000

/* Type of the control word.  */
typedef unsigned int fpu_control_t;

/* Macros for accessing the hardware control word.  */
#if (__CSKY__ == 2)
# define _FPU_GETCW(cw) __asm__ volatile ("mfcr %0, cr<1, 2>" : "=a" (cw))
# define _FPU_SETCW(cw) __asm__ volatile ("mtcr %0, cr<1, 2>" : : "a" (cw))
# define _FPU_GETFPSR(cw) __asm__ volatile ("mfcr %0, cr<2, 2>" : "=a" (cw))
# define _FPU_SETFPSR(cw) __asm__ volatile ("mtcr %0, cr<2, 2>" : : "a" (cw))
#else
# define _FPU_GETCW(cw) __asm__ volatile ("1: cprcr  %0, cpcr2 \n"          \
                                         "   btsti  %0, 31    \n"           \
                                         "   bt     1b        \n"           \
                                         "   cprcr  %0, cpcr1\n" : "=b" (cw))

# define _FPU_SETCW(cw) __asm__ volatile ("1: cprcr  r7, cpcr2 \n"          \
                                         "   btsti  r7, 31    \n"           \
                                         "   bt     1b        \n"           \
                                         "   cpwcr  %0, cpcr1 \n"           \
                                         : : "b" (cw) : "r7")

# define _FPU_GETFPSR(cw) __asm__ volatile ("1: cprcr  %0, cpcr2 \n"        \
                                           "   btsti  %0, 31    \n"         \
                                           "   bt     1b        \n"         \
                                           "   cprcr  %0, cpcr4\n" : "=b" (cw))

# define _FPU_SETFPSR(cw) __asm__ volatile ("1: cprcr  r7, cpcr2 \n"        \
                                           "   btsti  r7, 31    \n"         \
                                           "   bt     1b        \n"         \
                                           "   cpwcr %0, cpcr4  \n"         \
                                           : : "b" (cw) : "r7")
#endif /* __CSKY__ != 2 */

/* Default control word set at startup.  */
extern fpu_control_t __fpu_control;

#endif /* fpu_control.h */
