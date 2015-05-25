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
;; Function to update animations 
;;   It moves an enemy to the right 1 byte
;;
_update_animation::
   ;; Get parameters from stack
   pop  af        ;; AF = Return address
   pop  hl        ;; HL = Pointer to Person structure
   push hl        ;; Restore stack
   push af        ;;

   ld  bc, #6     ;; HL += 6 (Point to Person.x)
   add hl, bc     ;;

   inc (hl)       ;; Move person to the right (without even checking)

   ret            ;; Return to coller
