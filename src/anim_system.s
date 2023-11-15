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
.include "anim_system.h.s"
.include "entity_manager.h.s"

anim_update_entities::
    ld hl, #anim_update_entity
    ld b, #E_CMP_ANIM
    call entityman_forall_matching

    ret

anim_update_entity:
    ;; cargo en a y b, las velocidades de la entidad, y luego compruebo que la suma de ambas no es 0 para saber si esta quieto
    ld  a, e_velX(ix)
    ld  b, e_velY(ix)
    add a, b
    or  a
    jr z, endChangeSprite

    ld b, e_animTime(ix)            ;; cargo en b el tiempo actual de animacion
    ld l, e_animation(ix)           ;; cargo en hl la direccion del valor de la animacion
    ld h, e_animation+1(ix)
    ld a, (hl)                      ;; cargo en a el valor de la direccion de la animacion
    cp b                            ;; resto a y b y si da 0 cambio el sprite
    jr nz, notChangingSprite
        ;; hay que cambiar el sprite
        ld  bc, #NEXT_ANIM          
        ld  l, e_animation(ix)
        ld  h, e_animation+1(ix)
        add hl, bc
        ld  e_animation(ix), l
        ld  e_animation+1(ix), h

        ;; compruebo que el siguiente valor es distinto de 0
        ld a, (hl)
        or a
        jr nz, changeSprite
            ;; si es 0 apunta de nuevo al principio de la animacion, hay que obtener esa direccion en hl
            inc hl
            ld  c, (hl)
            inc hl
            ld  b, (hl)
            ld  e_animation(ix), c
            ld  e_animation+1(ix), b

            ld  l, e_animation(ix)
            ld  h, e_animation+1(ix)

        changeSprite:
            call changeSpriteInEntity

            ld a, #0
            ld e_animTime(ix), a    ;; se carga en animT de la entidad un 0 para resetear el tiempo de animacion

            jr endChangeSprite

    notChangingSprite:
        ;; si la resta no es 0, se incrementa en 1 el valor de la animT de la entidad
        ld  a, e_animTime(ix)
        inc a
        ld e_animTime(ix), a

    endChangeSprite:

    ret

;; b: New direction
animsys_changeSpriteDirection::
    ld a, e_direc(ix)       ;; cargo en A la direccion actual de la entidad
    cp b                    ;; resto la direccion nueva a la actual, si es 0 es la misma direccion
    jr z, sameDirection
        ld a, b
        ld e_direc(ix), a   ;; se guarda en la entidad la direccion actual

        ;; ahora se cambia el sprite segun la nueva direccion

        cp #E_DIR_N         ;; comprobamos si es norte
        jr nz, isNotNorth
            ;; se cambia la animacion de la entidad
            ld l, e_animGeneral(ix)
            ld h, e_animGeneral+1(ix)
            ld bc, #ANIM_N
            jr changeEntityAnimation

        isNotNorth:
            cp #E_DIR_S         ;; comprobamos si es sur
            jr nz, isNotSouth
                ;; se cambia la animacion de la entidad
                ld l, e_animGeneral(ix)
                ld h, e_animGeneral+1(ix)
                ld bc, #ANIM_S
                jr changeEntityAnimation

            isNotSouth:
                cp #E_DIR_E         ;; comprobamos si es este
                jr nz, isNotEast
                    ;; se cambia la animacion de la entidad
                    ld l, e_animGeneral(ix)
                    ld h, e_animGeneral+1(ix)
                    ld bc, #ANIM_E
                    jr changeEntityAnimation

                isNotEast:              ;; (creo que podemos no comprobar que sea oeste, se deja de momento)
                    cp #E_DIR_O         ;; comprobamos si es oeste
                    jr nz, changeEntityAnimation
                        ld l, e_animGeneral(ix)
                        ld h, e_animGeneral+1(ix)
                        ld bc, #ANIM_O
                        
                        ;; se cambia la animacion de la entidad

        changeEntityAnimation:
            ;; BC = el valor del incremento para la nueva animacion segun la direccion
            add hl, bc

            ld e, (hl)
            inc hl
            ld d, (hl)
            ex de, hl
            ;; guardamos en la entidad la nueva animacion
            ld  e_animation(ix), l
            ld  e_animation+1(ix), h

            call changeSpriteInEntity
            
            ;; y ponemos el tiempo de animacion en la entidad a 0
            xor a
            ld  e_animTime(ix), a

    sameDirection:

    ret

;; para cambiar el sprite incrementamos hl, que apunta al tiempo de la animacion, ya que lo siguiente al tiempo es el sprite correspondiente
changeSpriteInEntity:
    inc hl                  ;; se incrementa hl para tener la direccion del sprite
    ex  de, hl
    push ix
    pop hl
    ld bc, #6
    add hl, bc
    ex de, hl
    ld  bc, #2
    ldir
    
    ret

;; ix: Direccion de la entidad para cambiar el sprite
;; hl: Direccion del sprite al que queremos cambiar
animsys_changeSprite::
    ld e_sprite(ix), l
    ld e_sprite+1(ix), h

    ret

;; ix: Direccion de la entidad para cambiar la animacion
;; hl: Direccion de la animacion a la que queremos cambiar
animsys_changeAnimation::
    ld e_animation(ix), l
    ld e_animation+1(ix), h

    ret

animsys_changeGlobalAnimation::
    ld e_animGeneral(ix), l
    ld e_animGeneral+1(ix), h

    ret