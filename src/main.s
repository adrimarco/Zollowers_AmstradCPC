;-----------------------------LICENSE NOTICE--------------------------------------------------
;  This file is part of Zollowers an Amstrad CPC 464  game developed for the CPCRetrodev2022
;  Copyright (C) 2022 Blue Panda Studio you can find us on twitter: @BluePandaStudi0
;
;  This program is free software: you can redistribute it and/or modify
;  it under the terms of the GNU Lesser General Public License as published by
;  the Free Software Foundation, either version 3 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU Lesser General Public License for more details.
;
;  You should have received a copy of the GNU Lesser General Public License
;  along with this program. See the license.txt archive.
;  If not, see <http://www.gnu.org/licenses/>.
;---------------------------------------------------------------------------------------------
.include "game_manager.h.s"
.include "render_system.h.s"
.include "menu_manager.h.s"
.include "cpctelera.h.s"
.include "cpct_functions.h.s"

.area _DATA
.area _CODE
contador_int: .db 6
.globl _ost
interruption_controller::

   ;Ponemos el modo de interrupciones a 1
   im 1

   ;Deshabilitamos las interrupciones
   di

   ;;Cuando haya una interrupcion haremos que ejecute el metodo interruption_counter
   ld hl,#0x38
   ld (hl),#0xC3
   inc hl
   ld (hl),#<interruption_counter
   inc hl
   ld (hl),#>interruption_counter
   inc hl
   ld (hl),#0xC9
   ;Habilitamos las interrupciones
   ei

   ret
interruption_counter::

   ;;Guardamos los registros
   cpctm_push af,bc,de,hl,ix,iy

   ld a,(contador_int)
   dec a
   jr nz, contador_not_zero
      ld a,(time_left)
      dec a
      ld (time_left),a
      call cpct_scanKeyboard_if_asm
      call cpct_akp_musicPlay_asm
      ld a,#6
   contador_not_zero:
   ld (contador_int),a

   ;;Recuperamos los registros
   cpctm_pop iy,ix,hl,de,bc,af

   ;;Activamos las interrupciones
   ei
   reti

_main::
   
   call interruption_controller
   ld de,#_ost
   call cpct_akp_musicInit_asm
   ld de,#_ost
   call cpct_akp_SFXInit_asm
   call render_init

   main_menu:
   ;; Menu principal
      call render_menu_init
      call menuman_update

      ;; Comprueba el resultado del menu para saber si debe empezar el juego o mostrar la ayuda
      or a
      jr z, start_game
         ;; Ha seleccionado la ayuda, espera a que salga para volver al menu
         call menuman_wait_loop
         jr main_menu

   ;; Loop del juego
      start_game:
      call gameman_init
      call gameman_play

   ;; Fin de la partida y pantalla de puntuacion
      call render_display_final_score
      call menuman_wait_loop

   ;; Reset y vuelta al principio
      call gameman_reset

   jr main_menu