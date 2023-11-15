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
;Ficheros que incluye
.include "menu_manager.h.s"
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "render_system.h.s"
.include "input_system.h.s"

;Se guarda la opcion seleccionada del menu
menu_option_pressed:: .db 0

;Strings que se imprimiran por pantalla
start:: .asciz "START (1)"
controls:: .asciz "HELP (2)"
string_controls:: .asciz "CONTROLS"
string_objective::  .asciz "OBJECTIVE"
string_up:: .asciz "Q: UP"
string_down:: .asciz "A: DOWN"
string_left:: .asciz "O: LEFT"
string_right:: .asciz "P: RIGHT"
string_tip_1:: .asciz "AVOID ZOMBIES"
string_tip_2:: .asciz "GET ALL KEYS"
string_tip_3:: .asciz "REACH THE EXIT"

;; Numero para la semilla random, parara de sumar cuando el jugador presione la tecla 1 y empiece el juego
cont_seed::
    .db 0

;;
;; Bucle de ejecucion de la pantalla principal
;;  Salida:
;;      A - 0 si selecciona jugar, 1 si selecciona ayuda
;;
menuman_update::
    ;; Va sumando 1 hasta que el jugador pulse una tecla, para la semilla random
    ld  a, (cont_seed)
    inc a
    ld (cont_seed), a

    ;Se espera a la sincronizacion vertical
    call cpct_waitVSYNC_asm

    ;Introduce el valor por defecto del input
    xor a
    ld (menu_option_pressed), a
    
    ;Comprueba el input
    call input_update_menu

    ;Comprobamos si se ha seleccionado alguna opcion para salir del bucle
    jr z, menuman_update


    ;Si alcanza este punto significa que ha seleccionado una opcion
    ;Se comprueba si la opcion seleccionada es la de jugar
    cp #1
    jr nz, option_one_not_ejecuted
        ;Opcion jugar seleccionada, borra la pantalla e inicia el juego
        call render_erase_screen

        ;; Antes de hacer el ret para que empiece el juego, genera la semilla random
        ld a, (cont_seed)
        ld l, a
        call cpct_setSeed_lcg_u8_asm

        ;; Carga en A un 0 para indicar que comienza la partida
        xor a

        ret
    option_one_not_ejecuted:
    ;Si no ha seleccionado jugar, muestra la ayuda
    call render_help_screen

    ;; Carga en A un 1 para indicar que esta en la pagina de ayuda
    ld a, #1

    ret
;;

;;
;; Bucle que espera a que se pulse la tecla para continuar
;;
menuman_wait_loop::
    ;; Bucle
    wait_continue_loop:

    ;; Espera al VSYNC
    call cpct_waitVSYNC_asm

    ;; Pone la variable a 0
    xor a
    ld (menu_option_pressed), a

    ;; Comprueba el teclado
    call input_update_continue

    ;; Comprueba si se ha pulsado la tecla de continuar
    jr z, wait_continue_loop

    ;; Si la ha pulsado sale del bucle y continua

    ret
;;