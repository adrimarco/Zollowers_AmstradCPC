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
.include "physics_system.h.s"
.include "entity_manager.h.s"
.include "collision_system.h.s"
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "anim_system.h.s"

;;
;; Actualiza todas las entidades
;;
physics_update_entities::
    ;; Hace que el manager ejecute la funcion update_entity sobre todas las entidades
    ld hl, #update_entity
    ld b, #E_CMP_PHYSIC
    call entityman_forall_matching
    ret
;;

;;
;; Actualiza una entidad
;;    IX - Direccion de la entidad a actualizar
;;
update_entity:
    ;; Comprueba si puede moverse
    ld a, e_currentMovTime(ix)
    or a
    jp nz, update_movement_tick
        ;; Guardo en BC la velocidad en X
        ld b, e_velX(ix)

        ;; Comprueba que la velocidad en X no es 0
        ld a, b
        or a
        jp z, update_x_end
            ;; Cargo en A la posicion X de la entidad
            ld a, e_posX(ix)

            ;; Calculo la nueva posicion X
            add a, b
            cp #MAX_X
            ;; Comprueba que X no esta por debajo de 0
            jr nc, update_x_end
                ld d, e_sprW(ix)
                add a, d
                cp #MAX_X + 1
                ;; Comprueba que X no es superior al maximo
                jr nc, update_x_end
                    ;; Le resta el ancho para volver al valor original
                    sub d

                    ;; El valor es correcto y lo actualiza
                    ld e_posX(ix), a

                    ;; Actualiza la informacion del tile en el que se encuentra
                    call entityman_update_tile

                    ;; Comprueba las colisiones
                    call check_map_collision_x

                    ;; Se llama a la funcion para cambiar la direccion de la entidad
                    call changeEntityDirectionX
        update_x_end:

        ;; Guarda en C la velocidad en Y
        ld c, e_velY(ix)

        ;; Comprueba que la velocidad en Y no es 0
        ld a, c
        or a
        jp z, update_y_end
            ;; Cargo en A la posicion Y de la entidad
            ld a, e_posY(ix)

            ;; Calculo la nueva posicion Y
            add a, c
            cp #MAX_Y
            ;; Comprueba que Y no esta por debajo de 0
            jr nc, update_y_end
                ld d, e_sprH(ix)
                add a, d
                cp #MAX_Y + 1
                ;; Comprueba que Y no es superior al maximo
                jr nc, update_y_end
                    ;; Le resta el alto para volver al valor original
                    sub d

                    ;; El valor es correcto y lo actualiza
                    ld e_posY(ix), a

                    ;; Actualiza la informacion del tile en el que se encuentra
                    call entityman_update_tile

                    ;; Comprueba las colisiones
                    call check_map_collision_y

                    ;; Se llama a la funcion para cambiar la direccion de la entidad
                    call changeEntityDirectionY
        update_y_end:

        ;; Resetea el contador de ticks para el movimiento
        ld a, e_movTime(ix)
        ld e_currentMovTime(ix), a
        jr update_movement_tick_end
    update_movement_tick:
        ;; Todavia no debe actualizar el movimiento
        dec a
        ld e_currentMovTime(ix), a

        ;; Pone las velocidades a 0
        xor a
        ld e_velX(ix), a
        ld e_velY(ix), a
    update_movement_tick_end:

    ret
;;

;;
;; Deshace el movimiento en el eje X restando su velocidad
;;      IX - Direccion de la entidad
;;
physics_undo_x_movement::
    ;; Carga la velocidad y la posicion de la entidad
    ld a, e_posX(ix)
    ld b, e_velX(ix)

    ;; Resta los valores
    sub b

    ;; Guarda el resultado
    ld e_posX(ix), a

    ret
;;

;;
;; Deshace el movimiento en el eje Y restando su velocidad
;;      IX - Direccion de la entidad
;;
physics_undo_y_movement::
    ;; Carga la velocidad y la posicion de la entidad
    ld a, e_posY(ix)
    ld b, e_velY(ix)

    ;; Resta los valores
    sub b

    ;; Guarda el resultado
    ld e_posY(ix), a

    ret
;;

changeEntityDirectionX:
    ;; Cargo en a la velocidad de X (Puede ser 1 o -1)
    ld a, e_velX(ix)
    or a                ;; Comprueba que la velocidad Y no sea 0, si es 0 no cambiara la direccion
    ret z

    cp #1
    ;; Compruebo si la velocidad es 1 para saber la direccion del eje X
    jr z, directionIsEast
        ;; La velocidad es -1, direccion Oeste
        ld b, #E_DIR_O
        jr endif_x_dir
    directionIsEast:
        ;; La velocidad es 1, direccion Este
        ld b, #E_DIR_E
    endif_x_dir:

    ;; Como hemos cargado en B, la direccion del movimiento, llamamos a la funcion de cambiar el Sprite segun la direccion
    call animsys_changeSpriteDirection

    ret

changeEntityDirectionY:
    ;; Cargo en a la velocidad de Y (Puede ser 2 o -2)
    ld a, e_velY(ix)
    or a                ;; Comprueba que la velocidad Y no sea 0, si es 0 no cambiara la direccion
    ret z

    cp #2
    ;; Compruebo si la velocidad es 2 para saber la direccion del eje X
    jr z, directionIsSouth
        ;; L velocidad es -2, direccion Norte
        ld b, #E_DIR_N
        jr endif_y_dir
    directionIsSouth:
        ;; La velocidad es 2, direccion Sur
        ld b, #E_DIR_S
    endif_y_dir:

    ;; Como hemos cargado en B, la direccion del movimiento, llamamos a la funcion de cambiar el Sprite segun la direccion
    call animsys_changeSpriteDirection

    ret