;;-----------------------------LICENSE NOTICE------------------------------------
;;  This file is part of CPCtelera: An Amstrad CPC Game Engine 
;;  Copyright (C) 2015 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
;;
;;  This program is free software: you can redistribute it and/or modify
;;  it under the terms of the GNU General Public License as published by
;;  the Free Software Foundation, either version 3 of the License, or
;;  (at your option) any later version.
;;
;;  This program is distributed in the hope that it will be useful,
;;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;  GNU General Public License for more details.
;;
;;  You should have received a copy of the GNU General Public License
;;  along with this program.  If not, see <http://www.gnu.org/licenses/>.
;;-------------------------------------------------------------------------------
.module cpct_random

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; Function: cpct_nextRandom_mxor_u32
;;
;;    Calculates next 32-bits pseudo-random number in Marsaglia's XOR-shift 
;; 8-9-23 sequence.
;;
;; C Definition:
;;    <u32> <cpct_nextRandom_mxor_u32> (<u32> *seed*) __z88dk_fastcall;
;;
;; Input Parameters (4 bytes):
;;    (4B DE:HL) *seed* - Number that the XOR-shift algorithm will use to calculate 
;; its pseudo-random follower on the sequence.
;;
;; Assembly call (Input parameter on DE:HL):
;;    > call cpct_nextRandom_mxor_u32_asm
;;
;; Parameter Restrictions:
;;    * *seed* could be any 32-bits number *except 0*. A 0 as input will always produce
;; another 0 as output.
;;
;; Known limitations:
;;    * Marsaglia's XOR-shift algorithm will never produce a 32-bits 0 value as output.
;; However, when used to produce 8/16-bits values, 0's will be generated.
;;
;; Important details:
;;    * This function calculates next value in a 32-bits sequence that goes over all 32-bits
;; possible values except 0. Therefore, it has a repeating period of (2^32)-1. The walk this 
;; function does has a high pseudo-random quality: it passes most <Diehard tests at
;; https://en.wikipedia.org/wiki/Diehard_tests>
;;
;; Details:
;;   This function implements a sequence of 32-bits values with period (2^32)-1. This means 
;; that it produces consecutive 32-bits values that do not repeat until 4.294.967.295 numbers
;; have been generated. To do this, the function receives a 32-bit value as parameter (that
;; should be different from 0) and returns the next 32-bit value in the sequence.
;;
;;   The sequence calculated by this function is based on <Marsaglia's XOR-shift generator at
;; http://www.jstatsoft.org/article/view/v008i14/xorshift.pdf> using the tuple (8, 9, 23) whose
;; implementation is fast on a Z80 (as <suggested by Z88DK developers at 
;; http://www.z88dk.org/forum/viewtopic.php?id=6730>). The algorithm performs these 3
;; consecutive operations on the given number (*seed*):
;; (start code)
;;   seed ^= seed << 8
;;   seed ^= seed >> 9
;;   seed ^= seed << 23
;; (end code)
;;
;;   This operations are performed in an optimized fashion. To better understand optimizations
;; performed and their meaning, it is important to visualize these 3 operations:
;; (start code)
;;                [  d   ][  e   ][  h   ][  l   ]
;;  1) XOR        [  e   ][  h   ][  l   ]          ==> Produces d', e', h'
;;  2) XOR                 [  d'  ][  e'  ][  h'  ] ==> Produces h'', l'' (Check notes on e'')
;;  3) XOR [  h'' ][  l'  ]                         ==> Produces d'', e''
;;  -----------------------------------------------
;;  Result        [  d'' ][  e'' ][  h'' ][  l'  ]
;; (end code)
;;
;;   It is important to notice that e'' is not calculated on operation 2. The implementation 
;; uses registers b and c as intermediate buffers and that lets us combine operations 2 & 3 
;; in a single operation to directly calculate final value for register e, that will be e''.
;;
;; Destroyed Register values: 
;;      AF, BC, DE, HL
;;
;; Required memory:
;;      35 bytes
;;
;; Time Measures:
;; (start code)
;;    Case     | microSecs (us) | CPU Cycles
;; -----------------------------------------
;;    Any      |      37        |    148
;; -----------------------------------------
;; (end code)
;;
;; Credits:
;;   * Original <XOR-shifting algorithm published by George Marsaglia at 
;; http://www.jstatsoft.org/article/view/v008i14/xorshift.pdf>
;;   * Some interesting ideas obtained from <Z88DK developers at
;; http://www.z88dk.org/forum/viewtopic.php?id=6730>
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

_cpct_nextRandom_mxor_u32_9_21_16::
cpct_nextRandom_mxor_u32_9_21_16_asm::

; 39
   ld    b, l  ; 1
   ld    c, h  ; 1
   ld    a, e  ; 1
   sll   b     ; 2
   rl    c     ; 2
   rla         ; 1
   xor   d     ; 1
   ld    d, a  ; 1 d' = d ^ [ 7bits(e) | 1bit(h) ]

   ld    a, e  ; 1
   xor   c     ; 1
   ld    e, a  ; 1 e' = e ^ [ 7bits(h) | 1bit(l) ]

   ld    c, d  ; 1
   rla         ; 1
   rr    c     ; 2
   rla         ; 1
   rr    c     ; 2
   rla         ; 1
   rr    c     ; 2
   rla         ; 1
   and   #0x07 ; 2
   xor   b     ; 1
   xor   h     ; 1
   ld    h, a  ; 1 h'' = h ^ [ 7bits(l) | 0 ] ^ [ 00000 | 3bits(d') ]

   xor   d     ; 1
   ld    d, a  ; 1 d'' = d' ^ h''

   ld    a, l  ; 1
   xor   c     ; 1
   ld    l, a  ; 1 l'  = l ^ [ 5bits(d') | 3bits (e') ]

   xor   e     ; 1
   ld    e, l  ; 1 e'' = e' ^ l' 

   ret         ; 3


;;_cpct_nextRandom_mxor_u32_16_21_9::
;;cpct_nextRandom_mxor_u32_16_21_9_asm::
;;   ld    a, e  ; 1
;;   xor   l     ; 1
;;   ld    e, a  ; 1 e' = e ^ l
;;
;;   ld    a, d  ; 1
;;   xor   h     ; 1
;;   ld    b, a  ; 1 b = d ^ h = d'
;;
;;   ld    a, h  ; 1 (MSb h = MSb h')
;;   rla         ; 1
;;   ld    a, e  ; 1
;;   rla         ; 1
;;   xor   b     ; 1
;;   ld    d, a  ; 1 d'' = d ^ h ^ [ 7bits(e') | 1bit(h') ]
;;
;;   ld    a, e  ; 1
;;   rla         ; 1
;;   rl    b     ; 2
;;   rla         ; 1
;;   rl    b     ; 2
;;   rla         ; 1
;;   rl    b     ; 2
;;   rla         ; 1
;;   and   #0x07 ; 2
;;   ld    c, a  ; 1
;;   ld    a, b  ; 1
;;   xor   l     ; 1
;;   ld    l, a  ; 1 l' = l ^ [ 5bits(d') | 3bits (e') ]
;;
;;   rla         ; 1
;;   xor   c     ; 1
;;   xor   h     ; 1
;;   ld    h, a  ; 1 h'' = h ^ ((d')) ^ ((l'))



