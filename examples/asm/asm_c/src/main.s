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

;;
;; Start of _DATA area
;;    (SDCC requires at least _DATA and _CODE areas to be declared. )
;;
.area _DATA

;; Include all CPCtelera keyboard constant definitions and variables
;; (Beware not to include this in code area, or variables will be 
;; treated as code and executed!)
.include "keyboard/keyboard.s"

;; String to be written
str_press: .asciz "This is assembler main!";

;; Person structure, for the AI
ai_person_1: 
   .asciz "Willy"       ;; Person.name[6]
   .db    0x14, 0x30    ;; Person.x, Person.y
   .db    0x03, 0x00    ;; Person.fg, Person.bg

ai_person_2: 
   .asciz "Bill"        ;; | Person.name[6]
   .db    0x00          ;; | 
   .db    0x1E, 0x60    ;; Person.x, Person.y
   .db    0x02, 0x03    ;; Person.fg, Person.bg

;;
;; Start of _CODE area
;; 
.area _CODE

;; 
;; Declare all function entry points as global symbols for the compiler
;; (The linker will know what to do with them)

;; CPCtelera functions
.globl cpct_isKeyPressed_asm  
.globl cpct_scanKeyboard_f_asm 
.globl cpct_drawStringM1_f_asm
.globl cpct_disableFirmware_asm

;; Other C functions defined in other files
.globl _do_enemy_ai_c


;;
;; MAIN function. This is the entry point of the application.
;;    _main:: global symbol is required for correctly compiling and linking
;;
_main::
   ;; Disable firmware to prevent it from interfering with string drawing
   call cpct_disableFirmware_asm

   ;; Print a string to ask the user for pressing Space
   ld   de, #0xC000    ;; DE = Pointer to pixel 0,0 at the screen video memory 
   ld   hl, #str_press ;; HL = Pointer to the string 
   ld   bc, #0x0300    ;; B  = Background PEN (3), C = Foreground PEN (0)

   call cpct_drawStringM1_f_asm  ;; Draw the string

   ;;
   ;; MAIN Loop
   ;;
loop:
   ;; Wait for the user to press Space Key
   call cpct_scanKeyboard_f_asm  ;; Scan the keyboard

   ld   bc, #Key_Space           ;; BC = Space KeyID
   call cpct_isKeyPressed_asm    ;; Check for Space being pressed or not
   or   a                        ;; If Space is presses, A != 0
   jp   z, loop                  ;; When A=0, Space not pressed, Loop again

   ;; Call the AI written in C for enemies
   ld   hl, #ai_person_1         ;; HL = Pointer to the structure for the first AI enemy
   push hl                       ;; Push it to the stack (as C requires it there)
   call _do_enemy_ai_c           ;; Call AI C function
   pop  hl                       ;; Restore stack to previous state

   ld   hl, #ai_person_2         ;; HL = Pointer to the structure for the first AI enemy
   push hl                       ;; Push it to the stack (as C requires it there)
   call _do_enemy_ai_c           ;; Call AI C function
   pop  hl                       ;; Restore stack to previous state

   jp loop        ;; Repeat main loop infinitely
