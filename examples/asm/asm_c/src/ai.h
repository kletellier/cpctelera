//-----------------------------LICENSE NOTICE------------------------------------
//  This file is part of CPCtelera: An Amstrad CPC Game Engine 
//  Copyright (C) 2015 ronaldo / Fremos / Cheesetea / ByteRealms (@FranGallegoBR)
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.
//-------------------------------------------------------------------------------

#include <types.h>

//
// Define enemy AI structure
//
typedef struct {
   u8 name[6];    // Name (5 chars + 0)
   u8  x, y;      // x, y position on bytes
   u8 fc, bc;     // Foreground and background colours (PENs)
} Person;

//
// Function definitions
//
       void do_enemy_ai_c(Person* enemy); // Implemented in C    (in ai.c)
extern void update_animation(Person* p);  // Implemented in ASM  (in anim.s) 