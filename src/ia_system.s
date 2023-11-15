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
.include "ia_system.h.s"

;; ----------------------------
;; | Comportamientos de la ia |
;; ----------------------------

;; Este comportamiento de ia cambiara la posicion x e y a la que ir (sera la del player)
ia_chaser::
    .dw #ia_moveTo  ;; Funcion de la ia a ejecutar

;; -------------
;; | Funciones |
;; -------------

ia_update_entities::
    ;; Hace que el manager ejecute la funcion update_entity sobre todas las entidades
    ld hl, #update_entity
    ld b, #E_CMP_IA
    call entityman_forall_matching

    ret
;;

;;
;; Actualiza una entidad
;; IX - Direccion de la entidad a actualizar
;;
update_entity:
    ;; Comprueba que la entidad puede moverse, si no se puede mover no actualiza la entidad
    ld a, e_currentMovTime(ix)
    ld b, e_movTime(ix)
    cp b
    ret z
    
    ;; Carga en HL la posicion de memoria de la ia de la entidad
    ld  l, e_iaFunc(ix)
    ld  h, e_iaFunc+1(ix)
    
    ;; La guarda en iy 
    push hl
    pop iy
    
    ;; Carga en HL la funcion a ejecutar de la ia
    ld l, ia_behaviour(iy)
    ld h, ia_behaviour+1(iy)
    ld (ia_call_function+1), hl

    ia_call_function:
        call ia_update_entities

    ret

;; Comprobara si la entidad no esta alineada para moverse o cambiar la direccion en caso de estar alineada
ia_moveTo:
    ld a, e_components(ix)  ;; Cargo en A los componentes para ver si esta alineado

    ;; Comprueba si la entidad tiene los componentes de estar alineado en x e y
    and  #(E_CMP_TILE_X_ALIGN | E_CMP_TILE_Y_ALIGN)   
    sub #(E_CMP_TILE_X_ALIGN | E_CMP_TILE_Y_ALIGN) 
    jr nz, entity_not_aligned
        ;; La entidad esta alineada asi que pasara a calcular el siguiente tile al que moverse
        call ia_decide_next_direction
        jr entity_not_aligned_endif

    entity_not_aligned:     ;; La entidad no esta alineada, se sigue moviendo dependiendo de la direccion
    
    ld a, e_direc(ix)                   ;; Cargo en A la direccion actual de la entidad
    cp #E_DIR_N                         ;; Comprueba si la direccion es norte
    jr nz, direc_not_North
        ;; La entidad va en direccion norte
        ld a, #-2
        jr changeVelY
        
    direc_not_North:
        cp #E_DIR_S                     ;; Comprueba si la direccion es sur
        jr nz, direc_not_South
            ;; La entidad va en direccion sur
            ld a, #2
            jr changeVelY
        
        direc_not_South:
            cp #E_DIR_E                 ;; Comprueba si la direccion es este
            jr nz, direc_not_East
                ;; La entidad va en direccion este
                ld a, #1
                jr changeVelX
        
            direc_not_East:
                ;; La entidad va en direccion oeste
                ld a, #-1
                jr changeVelX

    changeVelX:
    ;; Cambia la velocidad en X al valor guardado en A
        ld e_velX(ix), a
        jr entity_not_aligned_endif

    changeVelY:
    ;; Cambia la velocidad en Y al valor guardado en A
        ld e_velY(ix), a

    entity_not_aligned_endif:

    ret

;; Decidira la siguiente direccion de la entidad dependiendo de su direccion actual y direcciones disponibles
;; - Dependiendo de la direccion actual, encendera unos bits en A u otros (A - 0xWESN)
ia_decide_next_direction:
    ld a, e_direc(ix)           ;; Cargo en A la direccion actual de la entidad
    cp #E_DIR_N                 ;; Comprueba si la direccion es norte
    jr nz, is_not_North
        ;; La entidad va en direccion norte, se elimina la opcion de sur
        ld b, #E_DIR_S
        jr removeDirection
        
    is_not_North:
        cp #E_DIR_S             ;; Comprueba si la direccion es sur
        jr nz, is_not_South
            ;; La entidad va en direccion sur, se elimina la opcion de norte
            ld b, #E_DIR_N
            jr removeDirection
        
        is_not_South:
            cp #E_DIR_E         ;; Comprueba si la direccion es este
            jr nz, is_not_East
                ;; La entidad va en direccion este, se elimina la opcion de oeste
                ld b, #E_DIR_O
                jr removeDirection
        
            is_not_East:
                ;; La entidad va en direccion oeste, se elimina la opcion de este
                ld b, #E_DIR_E

    ;; En B esta almacenada la direccion que no se puede tomar
    ;; Cargo en A, los primeros 4 bits a 1 (0x0F) para restar la direccion que hay en B
    removeDirection:
        ld a, #0x0F             ;; Carga en A, todas las posibles direcciones
        sub b                   ;; Elimina de todas las direcciones la direccion guardada en B

        ;; Compruebo si la entidad esta en los bordes de la pantalla
        ld d, a                 ;; Guardo A en D para no perder su valor

        ld a, e_posY(ix)        ;; Guarda en A la posicion Y del jugador
        or a                    ;; Comprueba que no es 0

        jr nz, not_in_Y_0
            ld a, d             ;; Copia en A las direcciones disponibles guardadas en D
            ld b, #E_DIR_N      ;; Resto la direccion norte para eliminarla de posibles direcciones
            sub b
            ld d, a             ;; Vuelve a guardar los valores de A en D
        not_in_Y_0:

        ld a, e_posX(ix)        ;; Guarda en A la posicion X del jugador
        or a                    ;; Comprueba que no es 0

        jr nz, not_in_X_0
            ld a, d             ;; Copia en A las direcciones disponibles guardadas en D
            ld b, #E_DIR_O      ;; Resto la direccion oeste para eliminarla de posibles direcciones
            sub b
            ld d, a             ;; Vuelve a guardar los valores de A en D
        not_in_X_0:

        ld  a, e_posY(ix)       ;; Guarda en A la posicion Y del jugador
        add a, #SPR_ENEMY_H     ;; Suma a la posicion Y el alto del sprite
        cp #MAX_Y               ;; Comprueba que no es el maximo

        jr nz, not_in_Y_MAX
            ld a, d             ;; Copia en A las direcciones disponibles guardadas en D
            ld b, #E_DIR_S      ;; Resto la direccion sur para eliminarla de posibles direcciones
            sub b
            ld d, a             ;; Vuelve a guardar los valores de A en D
        not_in_Y_MAX:

        ld  a, e_posX(ix)       ;; Guarda en A la posicion X del jugador
        add a, #SPR_ENEMY_W     ;; Suma a la posicion X el ancho del sprite
        cp #MAX_X               ;; Comprueba que no es el maximo

        jr nz, not_in_X_MAX
            ld a, d             ;; Copia en A las direcciones disponibles guardadas en D
            ld b, #E_DIR_E      ;; Resto la direccion este para eliminarla de posibles direcciones
            sub b
            ld d, a             ;; Vuelve a guardar los valores de A en D
        not_in_X_MAX:

        ld a, d                 ;; Carga en A las direcciones disponibles guardadas en D

        ;; En collisions comprobara las colisiones con los tiles de las direcciones posibles
        ;; y devolvera en A, las direcciones a las que se podra desplazar
        call check_posible_directions

        ;; CALCULOS PARA VER CUAL DE LAS POSIBLES DIRECCION TIENE MENOS DISTANCIA

        or a                                ;; Comprueba que hay alguna direccion, si no hay, cambia la direccion actual
        jr nz, calculate_directions
            ld a, e_direc(ix)               ;; Guardo en A, la direccion de la entidad actual

            cp #E_DIR_N                     ;; Compruebo si la direccion elegida es norte
            jr nz, actual_not_North
                ld c, #E_DIR_S
                jp change_direction
                
            actual_not_North:
                
            cp #E_DIR_S                     ;; Compruebo si la direccion elegida es sur
            jr nz, actual_not_South
                ld c, #E_DIR_N
                jr change_direction         ;; Salto a cambiar la direccion de la entidad
            
            actual_not_South:

            cp #E_DIR_E                     ;; Compruebo si la direccion elegida es este
            jr nz, actual_not_East
                ld c, #E_DIR_O
                jr change_direction         ;; Salto a cambiar la direccion de la entidad

            actual_not_East:
                
            cp #E_DIR_O                     ;; Compruebo si la direccion elegida es oeste
            jr nz, actual_not_West
                ld c, #E_DIR_E
                jr change_direction         ;; Salto a cambiar la direccion de la entidad

            actual_not_West:

        calculate_directions:
        
        ld bc, #0xFF00              ;; Cargo en B el valor maximo para que el primer calculo sea el minimo al restar
        
        push af                     ;; Guardo en el pila las direcciones para no perderlas
        
        and #E_DIR_N                ;; Comprueba si el norte es una posible direccion
        jr z, north_not_valid
            ;; Calcula la distancia si fueramos al norte
            ld a, e_posY(ix)        ;; Cargo en A la posicion Y de la entidad
            ld d, #SPR_H_HALF       ;; Cargo en D el valor del incremento para la posicion anterior
            sub d                   ;; Resto D a A para obtener la posicion a la que ira el enemigo
            ld h, e_posX(ix)        ;; Cargo en H la posicion X de la entidad si fuera al norte
            ld l, a                 ;; Cargo en L la posicion Y de la entidad si fuera al norte

            push bc                 ;; Guardo el minimo en la pila para no perderlo

            call ia_calculate_distance  ;; Devuelve en A, el calculo de la distancia si fuera al norte

            pop bc                  ;; Saco de la pila en BC el valor minimo actual
            cp b                    ;; Resto el valor de B, la distancia menor actual a A
            jr nc,  north_not_minor
                ;; Ha saltado el carry, el nuevo numero es menor asi que cambio la menor direccion guardada
                ld b, a             ;; Guardo en B el minimo actual
                ld c, #E_DIR_N      ;; Guardo en C la direccion del minimo actual
            north_not_minor:

        north_not_valid:

        pop af                      ;; Guardo en el pila las direcciones para no perderlas
        push af                     ;; Saca de la pila las direcciones para comprobar la siguiente

        and #E_DIR_S                ;; Comprueba si el sur es una posible direccion
        jr z, south_not_valid
            ;; Calcula la distancia si fueramos al sur
            ld  a, e_posY(ix)       ;; Cargo en A la posicion Y de la entidad
            ld  d, #SPR_H           ;; Cargo en D el valor del incremento para la posicion anterior
            add d                   ;; Sumo D a A para obtener la posicion a la que ira el enemigo           
            ld  h, e_posX(ix)       ;; Cargo en H la posicion X de la entidad si fuera al sur
            ld  l, a                ;; Cargo en L la posicion Y de la entidad si fuera al sur
            
            push bc                 ;; Guardo el minimo en la pila para no perderlo

            call ia_calculate_distance  ;; Devuelve en A, el calculo de la distancia si fuera al sur

            pop bc                  ;; Saco de la pila en BC el valor minimo actual
            cp b                    ;; Resto el valor de B, la distancia menor actual a A
            jr nc,  south_not_minor
            ;; Ha saltado el carry, el nuevo numero es menor asi que cambio la menor direccion guardada
                ld b, a             ;; Guardo en B el minimo actual
                ld c, #E_DIR_S      ;; Guardo en C la direccion del minimo actual
            south_not_minor:

        south_not_valid:

        pop af                      ;; Guardo en el pila las direcciones para no perderlas
        push af                     ;; Saca de la pila las direcciones para comprobar la siguiente

        and #E_DIR_E                ;; Comprueba si el este es una posible direccion
        jr z, east_not_valid
            ;; Calcula la distancia si fueramos al este
            ld  a, e_posX(ix)       ;; Cargo en A la posicion X de la entidad
            ld  d, #SPR_W           ;; Cargo en D el valor del incremento para la posicion anterior
            add d                   ;; Sumo D a A para obtener la posicion a la que ira el enemigo            
            ld  h, a                ;; Cargo en H la posicion X de la entidad si fuera al norte
            ld  l, e_posY(ix)       ;; Cargo en L la posicion Y de la entidad si fuera al norte
            
            push bc                 ;; Guardo el minimo en la pila para no perderlo

            call ia_calculate_distance  ;; Devuelve en A, el calculo de la distancia si fuera al este

            pop bc                  ;; Saco de la pila en BC el valor minimo actual
            cp b                    ;; Resto el valor de B, la distancia menor actual a A
            jr nc,  east_not_minor
            ;; Ha saltado el carry, el nuevo numero es menor asi que cambio la menor direccion guardada
                ld b, a             ;; Guardo en B el minimo actual
                ld c, #E_DIR_E      ;; Guardo en C la direccion del minimo actual
            east_not_minor:

        east_not_valid:

        pop af                      ;; Saca de la pila las direcciones para comprobar la siguiente
        push af                     ;; Guardo en la pila las direcciones para no perderlas

        and #E_DIR_O                ;; Comprueba si el oeste es una posible direccion
        jr z, west_not_valid
            ;; Calcula la distancia si fueramos al oeste
            ld  a, e_posX(ix)       ;; Cargo en A la posicion X de la entidad
            ld  d, #SPR_W           ;; Cargo en D el valor del incremento para la posicion anterior
            sub d                   ;; Resto D a A para obtener la posicion a la que ira el enemigo
            ld  h, a                ;; Cargo en H la posicion X de la entidad si fuera al oeste
            ld  l, e_posY(ix)       ;; Cargo en L la posicion Y de la entidad si fuera al oeste

            push bc

            call ia_calculate_distance  ;; Devuelve en A, el calculo de la distancia si fuera al oeste

            pop bc                  ;; Saco de la pila en BC el valor minimo actual
            cp b                    ;; Resto el valor de B, la distancia menor actual a A
            jr nc,  west_not_minor
            ;; Ha saltado el carry, el nuevo numero es menor asi que cambio la menor direccion guardada
                ld b, a             ;; Guardo en B el minimo actual
                ld c, #E_DIR_O      ;; Guardo en C la direccion del minimo actual
            west_not_minor:

        west_not_valid:

    pop af                          ;; Saco las direcciones que estaban guardadas en la pila
    ;; En C esta la direccion con menor distancia
    change_direction:

    ld a, c                         ;; Cargo en A la direccion que tendra que tomar la entidad
    cp #E_DIR_N                     ;; Compruebo si la direccion elegida es norte
    jr nz, not_North
        ld e_velX(ix), #0           ;; Pone la velocidad X de la entidad a 0
        ld e_velY(ix), #-2          ;; Pone la velocidad Y de la entidad a -2
        jr direction_changed
        
    not_North:
        
    cp #E_DIR_S                     ;; Compruebo si la direccion elegida es sur
    jr nz, not_South
        ld e_velX(ix), #0           ;; Pone la velocidad X de la entidad a 0
        ld e_velY(ix), #2           ;; Pone la velocidad Y de la entidad a 2
        jr direction_changed
    
    not_South:

    cp #E_DIR_E                     ;; Compruebo si la direccion elegida es este
    jr nz, not_East
        ld e_velX(ix), #1           ;; Pone la velocidad X de la entidad a 1
        ld e_velY(ix), #0           ;; Pone la velocidad Y de la entidad a 0
        jr direction_changed

    not_East:
        
    cp #E_DIR_O                     ;; Compruebo si la direccion elegida es oeste
    jr nz, not_West
        ld e_velX(ix), #-1          ;; Pone la velocidad X de la entidad a -1
        ld e_velY(ix), #0           ;; Pone la velocidad Y de la entidad a 0
        jr direction_changed

    not_West:

    direction_changed:

    ret

;; Calcula la distancia entre el tile pasado en HL y el tile que ocupa el jugador
;;  A  - Devuelve en A la distancia entre donde quiere ir el enemigo y el player
;;  HL - H posicion X futura de la entidad, L posicion Y futura de la entidad
ia_calculate_distance:
    ld iy, #entities            ;; Carga en IY la entidad player
    ld b, e_posX(iy)            ;; Cargo en H la posicion X actual del player
    ld c, e_posY(iy)            ;; Cargo en L la posicion Y actual del player

    ld a, h                     ;; Cargo en A la posicion X a la que ira la entidad
    sub b                       ;; Resta la posicion X del player a la posicion X futura de la entidad
    jr nc, resY_is_positive     ;; Salta si la resta es positiva
        neg                     ;; Como el resultado es negativo, hace el negado para hacerlo positivo

    resY_is_positive:

    ld d, a                     ;; Guardo el resultado de | posEntX - posJugY | en D

    ld a, l                     ;; Cargo en A la posicion Y a la que ira la entidad
    sub c                       ;; Resta la posicion Y del player a la posicion Y futura de la entidad
    jr nc, resX_is_positive     ;; Salta si la resta es positiva
        neg                     ;; Como el resultado es negativo, hace el negado para hacerlo positivo

    resX_is_positive:

    add d
    ;; Sumo | posEntY - posJugY | con | posEntX - posJugX | 
    ;; para obtener la distancia entre la posicion futura y el player                  

    ret

;; IX - Direccion de la entidad para cambiar la ia
;; HL - Direccion de la ia a la que queremos cambiar
;; A  - Valor de los ticks en los que se movera el enemigo
ia_changeEntityIA::
    ld e_iaFunc(ix), l
    ld e_iaFunc+1(ix), h
    ld e_movTime(ix), a

    ret