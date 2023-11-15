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
.include "entity_manager.h.s"
.include "level_templates.h.s"
.include "cpct_functions.h.s"

;; Memoria reservada
    entities::
        .ds MAX_ENTITIES*ENTITIES_SIZE      ;; El ultimo byte siempre sera 0 para terminar las comprobaciones
        .db 0x00
    next_entity::
        .ds 2
    num_entities::
        .ds 1  
;;

;;
;; Inicializa las entidades
;;
entityman_init::
   ;; Llena la memoria que ocupan las entidades con 0
   ld de, #entities
   ld a, #0x00
   ld bc, #MAX_ENTITIES*ENTITIES_SIZE

   call cpct_memset_asm

   ;; Pone a 0 el numero de entidades
   ld a, #0
   ld (num_entities), a

   ;; Hace que next_entity apunte a la primera posicion del espacio de memoria para entidades
   ld bc, #entities
   ld (next_entity), bc
   ret
;;

;;
;; Crea una nueva entidad
;;      HL - Direccion de la plantilla a utilizar
;; Salida:
;;      IX - Direccion de la entidad creada
;;
entityman_create_entity::
    ;; Carga la direccion de la siguiente entidad libre
    ld de, (next_entity)

    ;; Copia los valores por defecto en ese espacio de memoria
    ld bc, #ENTITIES_SIZE

    call cpct_memcpy_asm

    ;; Carga la direccion de la entidad creada 
    ld hl, (next_entity)
    ;; Guarda el valor
    push hl

    ;; Incrementa la direccion para guardar la de la siguiente
    ld bc, #ENTITIES_SIZE
    add hl, bc
    ld (next_entity), hl

    ;; Incrementa el numero de entidades
    ld a, (num_entities)
    inc a
    ld (num_entities), a

    ;; Recupera la direccion de la entidad creada para poder utilizarla
    pop ix

    ret
;;

;;
;; Actualiza el estado de una entidad para eliminarla posteriormente
;;    IX - Direccion de la entidad a marcar para destruir
;;
entityman_set_destroy_entity::
   ;; Anyade el tipo E_TYPE_DESTROY para indicar que se debe destruir
    ld a, (ix)
    or #E_TYPE_DESTROY
    ld (ix), a
    ret
;;

;;
;; Destruye la entidades marcadas para destruir
;;
entityman_destroy_entities::
    ;; Carga la direccion de la primera entidad
    ld hl, #entities
    
    check_next_entity:
        ;; Comprueba que no es la ultima entidad
        ld a, (hl)
        or a
        jr z, not_destroy_endif
        ;; Si no es la ultima, comprueba si se debe destruir

        and #E_TYPE_DESTROY
        or a
        ;; Comprueba si su estado indica que debe ser destruida
        jr z, not_destroy
            ;; Hay que destruir la entidad
            ;; Hace que DE apunte a la entidad a destruir
            ex de, hl
            ;; HL pasa a apuntar a la ultima entidad
            ld hl, (next_entity)
            ld bc, #-ENTITIES_SIZE
            add hl, bc

            ;; Actualiza el valor de la ultima entidad
            ld (next_entity), hl

            ;; Decrementa el numero de entidades
            ld a, (num_entities)
            dec a
            ld (num_entities), a

            ;; Comprueba que no se esta destruyendo la ultima entidad
            ld a, h
            cp d
            jr nz, copy_mem
            ld a, l
            cp e
            jr z, no_copy
                copy_mem:
                ;; Copia la ultima entidad en la posicion de la entidad destruida
                ld bc, #ENTITIES_SIZE
                ldir
                
                ;; HL apunta al estado de la entidad destruida
                ld bc, #-ENTITIES_SIZE
                add hl, bc

                ;; Modifica el estado de la entidad destruida
                ld (hl), #E_TYPE_INVALID

                ;; Vuelve a la entidad copiada para seguir la comprobacion
                ex de, hl
                add hl, bc

                jr check_next_entity

            no_copy:
            ;; Modifica el estado de la entidad destruida
            ld (hl), #E_TYPE_INVALID

            ;; Al no copiarse significa que es la ultima, por lo que sale del bucle
            jr not_destroy_endif

        not_destroy:
            ;; No hay que destruir la entidad, asi que pasa a la siguiente
            ld bc, #ENTITIES_SIZE
            add hl, bc
            
            jr check_next_entity

        not_destroy_endif:
    
    ret
;;

;;
;; Devuelve la direccion de la entidad con el indice indicado
;;      A  - Indice de la entidad
;;  Salida:
;;      IX - Direccion de la entidad
;;
entityman_get_entity_by_id::
    ;; Carga la direccion de la primera entidad y el tamanyo de estas
    ld ix, #entities
    ld bc, #ENTITIES_SIZE

    ;; Comprueba que el indice no ha llegado a 0
    check_index:
    or a
    ret z

    ;; Pasa a la siguiente entidad
    add ix, bc
    dec a
    jr check_index
;;

;;
;; Comprueba si hay espacio libre para crear mas entidades
;; Salida:
;;      Flag Z vale 1 si no hay espacio y 0 en caso contrario
;;
entityman_free_space::
    ld a, (num_entities)
    ld b, #MAX_ENTITIES
    cp b
    ret
;;

;;
;; Hace que todas las entidades ejecuten una funcion
;;      HL - Direccion de la funcion a ejecutar
;;
entityman_forall::
    ;; Guarda la funcion que debe ejecutar
    ld (forall_call+1), hl

    ;; Carga la direccion de la primera entidad
    ld ix, #entities

    go_next_entity:
    ;; Comprueba que no es la ultima entidad
    ld a, (ix)
    or a
    jp z, forall_end
        ;; Guarda la direccion de la entidad para no perderla
        push ix

        ;; Llama a la funcion
        forall_call:
        call forall_end

        ;; Recupera la direccion de la entidad
        pop ix

        ;; Apunta a la direccion de la siguiente entidad
        ld bc, #ENTITIES_SIZE
        add ix, bc

        ;; Vuelve atras
        jp go_next_entity

    forall_end:
    
    ret
;;

;;
;; Hace que todas las entidades ejecuten una funcion siempre y cuando tengan los componentes indicados
;;      HL - Direccion de la funcion a ejecutar
;;      B  - Byte con los flags de los componentes
;;
entityman_forall_matching::
    ;; Guarda la funcion que debe ejecutar
    ld (forall_matching_call+1), hl

    ;; Carga la direccion de la primera entidad
    ld ix, #entities

    forall_matching_next_entity:
    ;; Comprueba que no es la ultima entidad
    ld a, (ix)
    or a
    jp z, forall_matching_end
        ;; Comprueba que contiene los componentes necesarios
        push bc
        ld a, e_components(ix)
        and b
        sub b
        jp nz, not_matching
            ;; Guarda la direccion de la entidad para no perderla
            push ix

            ;; Llama a la funcion
            forall_matching_call:
            call forall_matching_end            ;; La direccion es sustituida al inicio de la funcion

            ;; Recupera la direccion de la entidad
            pop ix

        not_matching:
        ;; Apunta a la direccion de la siguiente entidad
        ld bc, #ENTITIES_SIZE
        add ix, bc

        pop bc

        ;; Vuelve atras
        jp forall_matching_next_entity

    forall_matching_end:
    
    ret
;;

;;
;; Hace que todas las entidades ejecuten una funcion por pares siempre y cuando tengan los componentes indicados
;;      HL - Direccion de la funcion a ejecutar
;;      B  - Byte con los flags de los componentes
;;
entityman_forall_pairs_matching::
    ;; Carga la direccion del jugador en IY
    ld iy, #entities

    ;; Salta a entityman_forall_matching
    call entityman_forall_matching
    
    ret
;;

;;
;; Dada una posicion en tiles actualiza la posicion de la entidad
;;      IX - Direccion de la entidad
;;      B  - Tile X
;;      C  - Tile Y
;;
entityman_set_tile_position::
    ;; Guarda los valores de BC en la pila
    push bc

    ;; Pone HL a 0
    ld hl, #0
    push hl

    ;; Incrementa C para que funcione con el valor 0
    inc c
    
    add_next_row:
    ;; Resta una fila y comprueba si quedan mas
    dec c
    jr z, last_row

        ;; Carga en D el valor de altura de un tile
        ld de, #LEVEL_W
        ;; Anyade una fila al indice
        add hl, de

        ;; Recupera de la pila la posicion Y
        pop de
        ex de, hl

        ;; Guardo BC para no perderlo
        push bc

        ;; Suma a la posicion el valor correspondiente
        ld c, #0
        ld b, #TILE_H
        add hl, bc

        ;; Recupero los indices
        pop bc
        
        ;; Guarda la posicion de nuevo en la pila
        push hl
        ex de, hl

        jr add_next_row
    last_row:

    ;; Suma el indice de la columna
    ld d, #0
    ld e, b
    add hl, de

    ;; Guarda el valor del tile y la posicion Y
    ld e_tile(ix), h
    ld e_tile+1(ix), l
    pop hl
    ld e_posY(ix), h

    ;; Recupera los valores de la pila
    pop bc

    ;; Inicializa A para calcular la nueva posicion X
    xor a

    ;; Incrementa B para que funcione con el valor 0
    inc b

    add_next_column:
    ;; Resta una columna y comprueba si quedan mas
    dec b
    jr z, last_column
        ;; Suma la posicion X en pixeles
        add a, #TILE_W

        jr add_next_column
    last_column:

    ;; Guarda el valor de la posicion X
    ld e_posX(ix), a

    ;; Actualiza los componentes para indicar que esta alineada con los tiles
    ld b, #(E_CMP_TILE_X_ALIGN | E_CMP_TILE_Y_ALIGN)
    call entityman_add_cmp

    ret
;;

;;
;; Anyade uno o mas componentes a la entidad
;;      IX - Direccion de la entidad
;;      B  - Componentes a anyadir
;;
entityman_add_cmp::
    ;; Guarda en A los componentes de la entidad
    ld a, e_components(ix)

    ;; Anyade los componentes en B a los que hay
    or b

    ld e_components(ix), a

    ret
;;

;;
;; Elimina uno o mas componentes a la entidad
;;      IX - Direccion de la entidad
;;      A  - Componentes a eliminar
;;
entityman_remove_cmp::
    ;; Guarda en B los componentes de la entidad
    ld b, e_components(ix)

    ;; Se eliminan los componentes de A de la entidad
    cpl
    and b

    ld e_components(ix), a

    ret
;;

;;
;; Actualiza el valor de la entidad que indica el tile en el que se encuentra
;;  IX - Direccion de la entidad
;;
entityman_update_tile::
    ;; Inicializa HL y BC
    ld hl, #0
    ld b, #0
    ld c, #20                   ;; LEVEL_W

    ;; Guarda en A la posicion Y y la divide entre 8 para obtener el tile
    ld a, e_posY(ix)
    srl a
    srl a
    srl a

    add_next_tile_row:
    ;; Comprueba si hay mas tiles de filas
    or a
    jr z, check_row_end
        ;; Anyade indices segun la fila
        add hl, bc
        dec a
        jr add_next_tile_row
    check_row_end:

    ;; Guarda en A la posicion X y la divide entre 4 para obtener el tile
    ld a, e_posX(ix)
    srl a
    srl a

    ;; Anyade el indice de la columna
    ld c, a
    add hl, bc

    ;; Actualiza el valor en la entidad
    ld e_tile(ix), h
    ld e_tile+1(ix), l

    ;; Comprueba si esta alineado en X con los tiles
    ld a, e_posX(ix)
    and #0x03
    jr nz, not_x_alignment
        ;; Esta alineado, por lo que lo marca en los componentes
        ld b, #E_CMP_TILE_X_ALIGN
        call entityman_add_cmp

        jr not_x_alignment_endif
    not_x_alignment:
        ;; No esta alineado y lo marca en los componentes
        ld a, #E_CMP_TILE_X_ALIGN
        call entityman_remove_cmp
    not_x_alignment_endif:

    ;; Comprueba si esta alineado en Y con los tiles
    ld a, e_posY(ix)
    and #0x07
    jr nz, not_y_alignment
        ;; Esta alineado, por lo que lo marca en los componentes
        ld b, #E_CMP_TILE_Y_ALIGN
        call entityman_add_cmp

        jr not_y_alignment_endif
    not_y_alignment:
        ;; No esta alineado y lo marca en los componentes
        ld a, #E_CMP_TILE_Y_ALIGN
        call entityman_remove_cmp
    not_y_alignment_endif:

    ret
;;

;;
;; Elimina las entidades no permanentes
;;
entityman_destroy_non_permanent_entities::
    ;; Carga la direccion de la primera entidad no permanente
    ld ix, #entities
    ld bc, #ENTITIES_SIZE
    add ix, bc

    non_permanent_next:
    add ix, bc

    ;; Recorre hasta la ultima entidad
    ld a, e_type(ix)
    or a
    jr z, non_permanent_entities_end
        ;; Cambia el tipo de la entidad para que sea destruida
        or #E_TYPE_DESTROY
        ld e_type(ix), a

        ;; Pasa a la siguiente
        jr non_permanent_next
    non_permanent_entities_end:

    ;; Elimina las entidades marcadas
    call entityman_destroy_entities

    ret
;;