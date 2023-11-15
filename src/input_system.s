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
.include "input_system.h.s"
.include "entity_manager.h.s"
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "game_manager.h.s"
.include "menu_manager.h.s"
.include "render_system.h.s"


;;
;; Actualiza todas las entidades
;;
input_update_entities::
    ;; Hace que el manager ejecute la funcion input_entity sobre la entidad del jugador
    ld ix, #entities
    call input_entity
    ret
;;

;;
;; Actualiza una entidad
;;    IX - Direccion de la entidad a actualizar
;;
input_entity:

    ;; Guarda en A la velocidad por defecto (0)
    ld a, #0
    push af

    ;; Comprueba las teclas pulsadas

    ;; Tecla O (mover izquierda)
    ld hl, #Key_O
    call cpct_isKeyPressed_asm
    jr z, key_O_not_pressed
        key_O_pressed:
        ;; Se mueve hacia la izquierda
        pop af
        dec a
        push af
        jr key_left_end
    key_O_not_pressed:

    ;; Joystick (mover izquierda)
    ld hl, #Joy0_Left
    call cpct_isKeyPressed_asm
    jr nz, key_O_pressed

    key_left_end:

    ;; Tecla P (mover derecha)
    ld hl, #Key_P
    call cpct_isKeyPressed_asm

    jr z, key_P_not_pressed
        key_P_pressed:
        ;; Se mueve hacia la derecha
        pop af
        inc a
        push af
        jr key_right_end
    key_P_not_pressed:

    ;; Joystick (mover derecha)
    ld hl, #Joy0_Right
    call cpct_isKeyPressed_asm
    jr nz, key_P_pressed

    key_right_end:

    ;; Actualiza la velocidad de la entidad a partir del input
    pop af
    ld e_velX(ix), a

    ;; Guarda en A la velocidad por defecto (0)
    ld a, #0
    push af

    ;; Tecla Q (mover arriba)
    ld hl, #Key_Q
    call cpct_isKeyPressed_asm

    jr z, key_Q_not_pressed
        key_Q_pressed:
        ;; Se mueve hacia arriba
        pop af
        dec a
        dec a
        push af
        jr key_up_end
    key_Q_not_pressed:

    ;; Joystick (mover arriba)
    ld hl, #Joy0_Up
    call cpct_isKeyPressed_asm
    jr nz, key_Q_pressed

    key_up_end:

    ;; Tecla A (mover abajo)
    ld hl, #Key_A
    call cpct_isKeyPressed_asm

    jr z, key_A_not_pressed
        key_A_pressed:
        ;; Se mueve hacia abajo
        pop af
        inc a
        inc a
        push af
        jr key_down_end
    key_A_not_pressed:
    
    ;; Joystick (mover arriba)
    ld hl, #Joy0_Down
    call cpct_isKeyPressed_asm
    jr nz, key_A_pressed

    key_down_end:

    ;; Actualiza la velocidad de la entidad a partir del input
    pop af
    ld e_velY(ix), a

    ret
;;


;;Metodo para la entrada del teclado del menu
input_update_menu::

   ;; Comprueba las teclas pulsadas
    call cpct_isAnyKeyPressed_f_asm
    or a
    jr z, no_key_pressed
        ;; Se ha pulsado una tecla, comprueba si es una de las esperadas
        ;; Tecla 1 (jugar)
        ld hl, #Key_1
        call cpct_isKeyPressed_asm

        jr z, key_1_not_pressed
            ;; Ha pulsado la tecla jugar
            ld a, #1
            ld (menu_option_pressed), a

            ret
        key_1_not_pressed:

        ;; Tecla 2 (ayuda)
        ld hl, #Key_2
        call cpct_isKeyPressed_asm

        jr z, key_2_not_pressed
            ;; Ha pulsado la tecla ayuda
            ld a, #2
            ld (menu_option_pressed), a

            ret
        key_2_not_pressed:
    no_key_pressed:
    ;; O no se ha pulsado ninguna tecla, o no es relevante

    ret
;;

;;
;; Comprueba si se ha pulsado la tecla de continuar
;;
input_update_continue::
   ;; Comprueba las teclas pulsadas
    call cpct_isAnyKeyPressed_f_asm
    or a
    jr z, any_key_pressed
        ;; Se ha pulsado una tecla, comprueba si es la tecla esperada
        ;; Tecla 1 (continuar)
        ld hl, #Key_1
        call cpct_isKeyPressed_asm

        jr z, key_continue_not_pressed
            key_continue_pressed:
            ;; Ha pulsado la tecla para continuar
            ld a, #1
            ld (menu_option_pressed), a

            ret
        key_continue_not_pressed:

        ;; Joystick (continuar)
        ld hl, #Joy0_Fire1
        call cpct_isKeyPressed_asm
        jr nz, key_continue_pressed
    any_key_pressed:
    ;; O no se ha pulsado ninguna tecla, o no es relevante

    ret
;;