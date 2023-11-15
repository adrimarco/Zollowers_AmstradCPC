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
.include "collision_system.h.s"
.include "entity_manager.h.s"
.include "physics_system.h.s"
.include "game_manager.h.s"

;;
;; Actualiza las colisiones
;;
collision_update::
    ;; Comprueba las colisiones entre pares de entidades
    ld hl, #check_collision
    ld b, #E_CMP_COLLIDER
    call entityman_forall_pairs_matching
    ret
;;

;;
;; Comprueba si dos entidades colisionan
;;      IX - Direccion de la primera entidad
;;      IY - Direccion de la segunda entidad
;;
check_collision:
    ld c, #0

    ;; Carga en A el tipo de entidades contra los que colisiona la primera entidad
    ld a, e_collideAgainst(ix)
    ;; Carga en B el tipo de la segunda entidad
    ld b, e_type(iy)
    ;; Comprueba si A puede colisionar con B
    and b
    jr z, first_coll_checked
        ;; Pueden colisionar
        ld c, #1
    first_coll_checked:

    ;; Carga en A el tipo de entidades contra los que colisiona la segunda entidad
    ld a, e_collideAgainst(iy)
    ;; Carga en B el tipo de la primera entidad
    ld b, e_type(ix)
    ;; Comprueba si A puede colisionar con B
    and b
    jr z, second_coll_checked
        ;; Pueden colisionar
        ld c, #1
    second_coll_checked:

    ld a, c
    or a
    jp z, entities_not_collide
        ;; Las entidades pueden colisionar, asi que se comprueban sus bounding boxes
        ;; Bx >= Ax+Aw --> Bx-(Ax+Aw) >= 0
        ld a, e_posX(ix)
        ld b, e_sprW(ix)
        add a, b
        ld b, a
        ld a, e_posX(iy)
        sub b
        jr nc, entities_not_collide

        ;; Ax >= Bx+Bw --> Ax-(Bx+Bw) >= 0
        ld a, e_posX(iy)
        ld b, e_sprW(iy)
        add a, b
        ld b, a
        ld a, e_posX(ix)
        sub b
        jr nc, entities_not_collide
            
        ;; By >= Ay+Ah --> By-(Ay+Ah) >= 0
        ld a, e_posY(ix)
        ld b, e_sprH(ix)
        add a, b
        ld b, a
        ld a, e_posY(iy)
        sub b
        jr nc, entities_not_collide

        ;; Ay >= By+Bh --> Ay-(By+Bh) >= 0
        ld a, e_posY(iy)
        ld b, e_sprH(iy)
        add a, b
        ld b, a
        ld a, e_posY(ix)
        sub b
        jr nc, entities_not_collide

        ;; Si llega aqui significa que no se han cumplido las condiciones para no colisionar
        call update_collided_entities
        
    entities_not_collide:
    ret
;;

;;
;; Dadas dos entidades que colisionan, decide que ocurre segun sus tipos
;;      IX - Direccion de la segunda entidad
;;      IY - Direccion del jugador
;;
update_collided_entities:
    ;; Comprueba si la segunda entidad es una llave
    ld a, e_type(ix)
    and #E_TYPE_KEY
    jr z, second_not_key
        ;; La segunda entidad es una llave, aniado la llave a la score y borro la entidad
        push ix
        call gameman_add_key
        pop ix
        ret
    second_not_key:

    ;; Comprueba si la segunda entidad es una puerta
    ld a, e_type(ix)
    and #E_TYPE_DOOR
    jr z, second_not_door
        ;; La segunda entidad es una puerta, comprueba si pasa de nivel
        push iy                     ;; Guardo la direccion donde apunta iy para no perderla al resetear el nivel
        call gameman_check_door
        pop iy
        ret
    second_not_door:

    ;; Comprueba si la segunda entidad es un enemigo
    ld a, e_type(ix)
    and #E_TYPE_ENEMY
    jr z, second_not_enemy
        push iy                     ;; Guardo la direccion donde apunta iy para no perderla al resetear el nivel
        ;; La segunda entidad es un enemigo, por lo que el jugador pierde una vida
        call gameman_lose_one_life
        pop iy
    second_not_enemy:

    ret
;;

;;
;; Comprueba si colisiona con el mapa
;;      IX - Direccion de la entidad a comprobar
;;
check_map_collision_y::
    ;; Comprueba si la entidad se ha movido antes de comprobar las colisiones
    ld a, e_velY(ix)
    or a

    ret z
    
    ;; La entidad se mueve, por lo que se comprueban las colisiones
    ;; Carga en BC el tile donde se encuentra
    ld b, e_tile(ix)
    ld c, e_tile+1(ix)

    ;; A partir de la velocidad y la alineacion, comprueba que tile mirar
    cp #2       ;; VELOCIDAD_Y
    jr nz, check_collision_down
        ;; Comprueba las colisiones debajo, por lo que calcula el tile que tiene que comprobar
        ld hl, #20              ;; LEVEL_W

        ;; Carga en A los componentes para comprobar si esta alineada en Y
        ld a, e_components(ix)
        and #E_CMP_TILE_Y_ALIGN
        jr nz, check_collision_down_y_aligned
            ;; No esta alineado, asi que comprueba 2 tiles por debajo
            ;; Calcula el tile
            add hl, hl
            add hl, bc

            ;; Guarda el valor en BC
            ld b, h
            ld c, l

            jr check_collision_down
        check_collision_down_y_aligned:
            ;; Esta alineado, asi que comprueba 1 tile por debajo
            ;; Calcula el tile
            add hl, bc

            ;; Guarda el valor en BC
            ld b, h
            ld c, l
    check_collision_down:
    ;; Comprueba cuantos tile comprobar en funcion de la alineacion en X
    ld de, #0x0101              ;; D = 1, E = 1

    ld a, e_components(ix)
    and #E_CMP_TILE_X_ALIGN
    jr nz, check_map_y_collision_x_not_aligned
        ;; No esta alineada en X, por lo que comprueba tambien el tile siguiente
        ld e, #2

    check_map_y_collision_x_not_aligned:

    ;; Comprueba si colisiona
    call check_tile_collision
    or a
    jr z, not_map_collision_y
        ;; Hay colision, por lo que deshace el movimiento
        call physics_undo_y_movement

        ;; Actualiza la velocidad
        xor a
        ld e_velY(ix), a
    not_map_collision_y:

    ret
;;

;;
;; Comprueba si colisiona con el mapa
;;      IX - Direccion de la entidad a comprobar
;;
check_map_collision_x::
    ;; Comprueba si la entidad se ha movido antes de comprobar las colisiones
    ld a, e_velX(ix)
    or a

    ret z
    
    ;; La entidad se mueve, por lo que se comprueban las colisiones
    ;; Carga en BC el tile donde se encuentra
    ld b, e_tile(ix)
    ld c, e_tile+1(ix)

    ;; A partir de la velocidad y la alineacion, comprueba que tile mirar
    cp #1       ;; VELOCIDAD_X
    jr nz, check_collision_right
        ;; Comprueba las colisiones a la derecha, por lo que calcula el tile que tiene que comprobar

        ;; Carga en A los componentes para comprobar si esta alineada en X
        ld a, e_components(ix)
        and #E_CMP_TILE_X_ALIGN
        jr nz, check_collision_right_x_aligned
            ;; No esta alineado, asi que comprueba el siguiente tile
            inc bc
        check_collision_right_x_aligned:
    check_collision_right:
    ;; Comprueba cuantos tile comprobar en funcion de la alineacion en X
    ld de, #0x1402              ;; D = 20 (LEVEL_W), E = 2

    ld a, e_components(ix)
    and #E_CMP_TILE_Y_ALIGN
    jr nz, check_map_x_collision_y_not_aligned
        ;; No esta alineada en Y, por lo que comprueba una fila mas de tiles
        ld e, #3

    check_map_x_collision_y_not_aligned:

    ;; Comprueba si colisiona
    call check_tile_collision
    or a
    jr z, not_map_collision_x
        ;; Hay colision, por lo que deshace el movimiento
        call physics_undo_x_movement

        ;; Actualiza la velocidad
        xor a
        ld e_velX(ix), a
    not_map_collision_x:

    ret
;;

;;
;; Comprueba si existe colision en el tile indicado
;;      BC - Indice del tile a comprobar
;;      D  - Incremento entre indices
;;      E  - Numero de comprobaciones
;; Salida:
;;      A  - 1 si hay colision, 0 si no hay colision
;;
check_tile_collision:
    ;; Carga en A el contenido del tile
    ld hl, (current_level)
    add hl, bc

    ;; Carga en BC el incremento entre indices
    ld b, #0
    ld c, d

    check_next_index_tile:
    ld a, (hl)
    ;; Comprueba si existe colision
    cp #SOLID_TILE_INDEX
    jr c, tile_collision
        ;; Pasa a comprobar el siguiente
        add hl, bc
        dec e
        jr nz, check_next_index_tile
            ;; Si acaba, entonces no ha habido colisiones
            xor a
            jr check_tile_collision_endif
    tile_collision:
        ld a, #1
    check_tile_collision_endif:

    ret
;;

;; Comprueba de las direcciones posibles cuales no tienen colision
;;      A - Direcciones a las que puede moverse 0xWESN (1 se puede mover, 0 no se puede mover)
;;      Devuelve en A, las direcciones posibles
check_posible_directions::
    ;; -----------------------------
    ;; | COMPROBAR DIRECCION NORTE |
    ;; -----------------------------

    push af                     ;; Guarda en la pila las posibles direcciones para no perderlas
    and #E_DIR_N                ;; Comprueba si en A, la direccion norte es posible
    jr z, north_allowed         ;; Si es 0, no puede ir al norte
        ;; Comprueba el tile del norte
        ld h, e_tile(ix)       ;; Cargo en HL el tile en la que esta la entidad
        ld l, e_tile+1(ix)
        ld bc, #-20             ;; Cargo en BC el indice del tile que quiero
        add hl, bc              ;; Sumo a HL el indice para obtener el tile que quiero comprobar
        ld b, h
        ld c, l                 ;; Guardo en BC el tile que ocupa la direccion norte

        ld de, #1               ;; Numero de comprobaciones D = 0, E = 1

        call check_tile_collision

        or a                    ;; Comprueba que A es 0 para ver que no hay colision
        jr z, north_allowed
            ;; No puede ir hacia el norte
            pop af              ;; Guardo en AF, las direcciones para modificar que no puede norte
            ld b, #E_DIR_N      ;; Cargo en B, la direccion que voy a eliminar
            sub b               ;; Elimina la direccion de af
            jr north_allowed_endif
    north_allowed:
        ;; Puede ir al norte por lo que no modifico la direccion
        pop af                  ;; Saco de la pila las direcciones y las guardo en af

    north_allowed_endif:

    ;; -----------------------------
    ;; |  COMPROBAR DIRECCION SUR  |
    ;; -----------------------------

    push af                     ;; Guarda en la pila las posibles direcciones para no perderlas
    and #E_DIR_S                ;; Comprueba si en A, la direccion sur es posible
    jr z, south_allowed         ;; Si es 0, no puede ir al sur
        ;; Comprueba el tile del norte
        ld h, e_tile(ix)       ;; Cargo en HL el tile en la que esta la entidad
        ld l, e_tile+1(ix)
        ld bc, #40              ;; Cargo en BC el indice del tile que quiero
        add hl, bc              ;; Sumo a HL el indice para obtener el tile que quiero comprobar
        ld b, h
        ld c, l                 ;; Guardo en BC el tile que ocupa la direccion sur

        ld de, #1               ;; Numero de comprobaciones D = 0, E = 1

        call check_tile_collision

        or a                    ;; Comprueba que A es 0 para ver que no hay colision
        jr z, south_allowed
            ;; No puede ir hacia el norte
            pop af              ;; Guardo en AF, las direcciones para modificar que no puede norte
            ld b, #E_DIR_S      ;; Cargo en B, la direccion que voy a eliminar
            sub b               ;; Elimina la direccion de af
            jr south_allowed_endif
    south_allowed:
        ;; Puede ir al norte por lo que no modifico la direccion
        pop af                  ;; Saco de la pila las direcciones y las guardo en af
    south_allowed_endif:

    ;; -----------------------------
    ;; |  COMPROBAR DIRECCION ESTE |
    ;; -----------------------------

    push af                     ;; Guarda en la pila las posibles direcciones para no perderlas
    and #E_DIR_E                ;; Comprueba si en A, la direccion este es posible
    jr z, east_allowed          ;; Si es 0, no puede ir al este
        ;; Comprueba el tile del este
        ld h, e_tile(ix)       ;; Cargo en HL el tile en la que esta la entidad
        ld l, e_tile+1(ix)
        inc hl                  ;; Aumento en 1 para ir al tile que quiero comprobar
        ld b, h
        ld c, l                 ;; Guardo en BC el tile que ocupa la direccion este

        ld de, #0x1402          ;; D = LEVEL_W | E = 2 comprobaciones

        call check_tile_collision

        or a                    ;; Comprueba que A es 0 para ver que no hay colision
        jr z, east_allowed
            ;; No puede ir hacia el este
            pop af              ;; Guardo en AF, las direcciones para modificar que no puede este
            ld b, #E_DIR_E      ;; Cargo en B, la direccion que voy a eliminar
            sub b               ;; Elimina la direccion de af
            jr east_allowed_endif
    east_allowed:
        ;; Puede ir al este por lo que no modifico la direccion
        pop af                  ;; Saco de la pila las direcciones y las guardo en af
    east_allowed_endif:

    ;; -----------------------------
    ;; | COMPROBAR DIRECCION OESTE |
    ;; -----------------------------

    push af                     ;; Guarda en la pila las posibles direcciones para no perderlas
    and #E_DIR_O                ;; Comprueba si en A, la direccion oeste es posible
    jr z, west_allowed      ;; Si es 0, no puede ir al oeste
        ;; Comprueba el tile del oeste
        ld h, e_tile(ix)       ;; Cargo en HL el tile en la que esta la entidad
        ld l, e_tile+1(ix)
        dec hl                  ;; Decrementa en 1 para ir al tile que quiero comprobar
        ld b, h
        ld c, l                 ;; Guardo en BC el tile que ocupa la direccion oeste

        ld de, #0x1402          ;; D = LEVEL_W | E = 2 comprobaciones

        call check_tile_collision

        or a                    ;; Comprueba que A es 0 para ver que no hay colision
        jr z, west_allowed
            ;; No puede ir hacia el oeste
            pop af              ;; Guardo en AF, las direcciones para modificar que no puede oeste
            ld b, #E_DIR_O      ;; Cargo en B, la direccion que voy a eliminar
            sub b               ;; Elimina la direccion de af
            jr west_allowed_endif
    west_allowed:
        ;; Puede ir al este por lo que no modifico la direccion
        pop af                  ;; Saco de la pila las direcciones y las guardo en af
    west_allowed_endif:

    ret