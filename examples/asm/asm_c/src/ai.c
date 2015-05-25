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

#include "ai.h"
#include <cpctelera.h>

//
// Perform enemy AI (fake AI only prints name of the enemy at its position)
//
void do_enemy_ai_c(Person* enemy) {
   u8* pscr;

   // First, update animation
   update_animation(enemy);

   // Then print the enemy
   pscr = cpct_getScreenPtr((u8*)0xC000, enemy->x, enemy->y);
   cpct_drawStringM1(enemy->name, pscr, enemy->fc, enemy->bc);
}