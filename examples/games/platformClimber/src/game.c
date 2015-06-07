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
//------------------------------------------------------------------------------

#include <stdio.h>
#include <cpctelera.h>
#include "entities/entities.h"
#include "sprites/sprites.h"
#include "sprites/frame.h"
#include "random/random.h"

////////////////////////////////////////////////////////////////////////////////
// Initializes elements of the screen on the initialization of a new game
//
void initializeGameScreen(u16 hiscore) {
   u8* pscr;   // Pointer to the screen location where we want to draw
   u8  c;      // Colour pattern to draw
   u8  str[6]; // Score
   
   // Clear the screen
   cpct_clearScreen(0);

   //
   // Draw backgrounds and Hi-Score
   //
   c = cpct_px2byteM0(8,8);  // Colour pattern 8-8 (black-black)
   
   // Draw black background for scoreboard
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 54,   0);  
   cpct_drawSolidBox(pscr, c, 26, 200);

   // Draw "HI" string 
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 60,  16);   
   cpct_drawStringM0("HI", pscr, 3, 8);

   // Draw HI-Score
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 60,  24);
   sprintf(str, "%5u", hiscore);
   cpct_drawStringM0(str, pscr, 15, 8);

   // Draw tiled frame around playing area
   drawFrame(g_SCR_VMEM, 0);
}

////////////////////////////////////////////////////////////////////////////////
// Scan Keyboard and update user actions as requested by the user
//
void updateUser(TCharacter* user) {
   // Scan Keyboard
   cpct_scanKeyboard_f();

   //
   // Check possible keys to press, and do actions
   //

   // KEY = Cursor Up, ACTION = Jump (only when not already jumping)
   if ( cpct_isKeyPressed(Key_CursorUp) && user->status != es_jump ) {
      performAction(user, es_jump, user->side);    // Perform the action of jumping
      getRandomUniform(user->entity.nx);           // Use X coordinate of the user when jumping to forward update the random seed
   
   // KEY = Cursor Right, ACTION = Walk Right
   } else if ( cpct_isKeyPressed(Key_CursorRight) )
      performAction(user, es_walk, s_right);       // Move player to the right

   // KEY = Cursor Left, ACTION = Walk Left
   else if ( cpct_isKeyPressed(Key_CursorLeft) ) 
      performAction(user, es_walk, s_left);        // Move player to the left

   // KEY = Cursor Down, ACTION = Move Floor
   else if ( cpct_isKeyPressed(Key_CursorDown) ) 
      performAction(user, es_moveFloor, user->side); // Enable moving floor

   // KEY = None pressed, ACTION = Change user to static
   else 
      performAction(user, es_static, user->side);
}

////////////////////////////////////////////////////////////////////////////////
// Waits for a key to be pressed, but from a previous state of not being pressed
//
void wait4Key(cpct_keyID key) {
   do
      cpct_scanKeyboard_f();
   while( ! cpct_isKeyPressed(key) );
   do
      cpct_scanKeyboard_f();
   while( cpct_isKeyPressed(key) );
}

#ifdef DEBUGPERF
u32 vscounts[256];
u8 vsci;

// Explaining calculation of available cycles per Frame
//======================================================
// 1 Frame = 19968 microseconds = 79872 cpu cycles
// 1/6 cycles are used by Gate Array to draw the screen
// 1/6 * 79872 = 13312
// 79872 - 13312 = 66560 cycles available per frame
//
#define CYCLESPERFRAME  (u32)66560

u32 calculateUsedCycles(u32 loops) {
   if (loops)
      return CYCLESPERFRAME - (22 + 34 * loops);
   else
      return 0;
}

#endif

////////////////////////////////////////////////////////////////////////////////
// Plays a complete game, until the death of the main character
//
u16 game(u16 hiscore) {
   u8 alive = 1;        // Main character still alive?
   TCharacter* c;       // Pointer to main character

   // Initialize game
   initializeGameScreen(hiscore);   // Set up Game Screen
   initializeEntities();            // Set up initial entities
   c = getCharacter();              // Get the main character

#ifdef DEBUGPERF
   vsci = 0;
   do {
      updateUser(c);                // Update user status (depending on keypresses)

      vscounts[vsci++] = cpct_count2VSYNC();

      scrollWorld();                // Update world scrolling

      vscounts[vsci++] = cpct_count2VSYNC();

      alive = updateCharacter(c);   // Update character status     

      vscounts[vsci++] = cpct_count2VSYNC();

      drawAll();                    // ..draw everything

      vscounts[vsci++] = cpct_count2VSYNC();
   } while (vsci);

   {
      u16 k = 0;
      u8  str[40];
      u8* pvmem=g_SCR_VMEM;
      #define SCRLINESIZE  0x050
      
      cpct_setPALColour(0, 20); // Black
      cpct_setPALColour(1, 22); // Green
      cpct_setPALColour(2,  0); // White
      cpct_setPALColour(3, 28); // Red
      cpct_setVideoMode(1);
      cpct_clearScreen(0);
      cpct_drawStringM1(" C # total [keybo|scrol|physi|draw ]", pvmem, 0, 2);
      while (k < 256) {
         u32 keyb = calculateUsedCycles(vscounts[k+0]);
         u32 scro = calculateUsedCycles(vscounts[k+1]);
         u32 phys = calculateUsedCycles(vscounts[k+2]);
         u32 draw = calculateUsedCycles(vscounts[k+3]);
         u32 tot = keyb + scro + phys + draw;
         sprintf(str, "%2u # %5lu=[%5lu|%5lu|%5lu|%5lu]", k/4, tot, keyb, scro, phys, draw);
         pvmem += SCRLINESIZE;
         cpct_drawStringM1(str, pvmem, 1, 0);
         if (k == 92 || k == 188) {
            wait4Key(Key_Space);
            cpct_clearScreen(0);
            pvmem = g_SCR_VMEM;
            cpct_drawStringM1(" C # total [keybo|scrol|physi|draw ]", pvmem, 0, 2);
         }
         k += 4;
      }
      wait4Key(Key_Space);
   }

#else

   /////
   // Main Game Loop (while character is alive)
   /////
   while(alive) {
      updateUser(c);                // Update user status (depending on keypresses)
      scrollWorld();                // Update world scrolling
      alive = updateCharacter(c);   // Update character status     
      cpct_waitVSYNC();             // Wait for VSYNC and...
      drawAll();                    // ..draw everything
   }

#endif

   // Return final score, at the end of the game
   return getScore();
}


////////////////////////////////////////////////////////////////////////////////
// Shows messages at the end of the game and asks for keypress for starting again
//
void showGameEnd(u16 score) {
   u8* pscr;   // Pointer to the screen place where to show messages
   u8  str[6]; // String array to draw numbers on screen

   // Draw GAME OVER string
   pscr = cpct_getScreenPtr(g_SCR_VMEM,  8, 24);
   cpct_drawStringM0("GAME  OVER", pscr, 6, 0);

   // Draw SCORE string
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 16, 48);
   cpct_drawStringM0(  "SCORE", pscr, 9, 0);

   // Draw the score got in this game
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 16, 56);
   sprintf(str, "%5u", score);
   cpct_drawStringM0(str, pscr, 14, 0);

   // Draw PRESS SPACE string
   pscr = cpct_getScreenPtr(g_SCR_VMEM, 6, 112);
   cpct_drawStringM0("PRESS SPACE", pscr, 11, 0);

   // Wait for SPACE being pressed before continuing
   wait4Key(Key_Space);
}