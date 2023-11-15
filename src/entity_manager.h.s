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
;;
;;  Entity_manager
;;

;; Funciones
    .globl entityman_init
    .globl entityman_create_entity
    .globl entityman_set_destroy_entity
    .globl entityman_destroy_entities
    .globl entityman_get_entity_by_id
    .globl entityman_free_space
    .globl entityman_forall
    .globl entityman_forall_matching
    .globl entityman_forall_pairs_matching
    .globl entityman_set_tile_position
    .globl entityman_add_cmp
    .globl entityman_remove_cmp
    .globl entityman_update_tile
    .globl entityman_destroy_non_permanent_entities
;;

;; Constantes
    ENTITIES_SIZE           = 25
    MAX_ENTITIES            = 12
    MIN_X                   = 0
    MAX_X                   = 80
    MIN_Y                   = 0
    MAX_Y                   = 144
    ;; Tipos de entidad
        E_TYPE_INVALID      = 0x00
        E_TYPE_DEFAULT      = 0x01
        E_TYPE_PLAYER       = 0X02
        E_TYPE_KEY          = 0x04
        E_TYPE_DOOR         = 0x08
        E_TYPE_ENEMY        = 0x10
        E_TYPE_DESTROY      = 0x80
    ;; Componentes de las entidades
        E_CMP_DEFAULT       = 0x00
        E_CMP_PHYSIC        = 0x01
        E_CMP_RENDER        = 0x02
        E_CMP_INPUT         = 0x04
        E_CMP_IA            = 0x08
        E_CMP_ANIM          = 0x10
        E_CMP_COLLIDER      = 0x20
        E_CMP_TILE_X_ALIGN  = 0X80      ;; Indica que la entidad esta alineada con los tiles en X
        E_CMP_TILE_Y_ALIGN  = 0X40      ;; Indica que la entidad esta alineada con los tiles en Y
    ;; Direcciones para el movimiento
        E_DIR_N             = 0x01
        E_DIR_S             = 0x02
        E_DIR_E             = 0x04
        E_DIR_O             = 0x08
    ;; Aceso a valores de entidades
        e_type              = 0
        e_components        = 1
        e_posX              = 2
        e_posY              = 3
        e_velX              = 4
        e_velY              = 5
        e_sprite            = 6
        e_sprW              = 8
        e_sprH              = 9
        e_animation         = 10
        e_animTime          = 12
        e_iaFunc            = 13
        e_posAnt            = 15
        e_movTime           = 17
        e_currentMovTime    = 18
        e_direc             = 19
        e_tile              = 20
        e_collideAgainst    = 22
        e_animGeneral       = 23
    ;; Tamanios de los sprites
        SPR_POLI_W = 4
        SPR_POLI_H = 16

        SPR_ENEMY_W = 4
        SPR_ENEMY_H = 16

        SPR_KEY_W  = 4
        SPR_KEY_H  = 16

        SPR_DOOR_W = 4
        SPR_DOOR_H = 16

        SPR_W = 4
        SPR_H = 16
        SPR_H_HALF = 8

    ;; Ticks para el movimiento
        PLAYER_MOV_TIME     = 2
        ENEMY_MOV_TIME      = 3
    ;; Sprites
        .globl _spr_poli_N_0
        .globl _spr_poli_N_1
        .globl _spr_poli_S_0
        .globl _spr_poli_S_1
        .globl _spr_poli_E_0
        .globl _spr_poli_E_1
        .globl _spr_poli_O_0
        .globl _spr_poli_O_1
        .globl _spr_poli_D

        .globl _spr_zombieG_N_0
        .globl _spr_zombieG_N_1
        .globl _spr_zombieG_S_0
        .globl _spr_zombieG_S_1
        .globl _spr_zombieG_E_0
        .globl _spr_zombieG_E_1
        .globl _spr_zombieG_O_0
        .globl _spr_zombieG_O_1

        .globl _spr_zombieB_N_0
        .globl _spr_zombieB_N_1
        .globl _spr_zombieB_S_0
        .globl _spr_zombieB_S_1
        .globl _spr_zombieB_E_0
        .globl _spr_zombieB_E_1
        .globl _spr_zombieB_O_0
        .globl _spr_zombieB_O_1
        
        .globl _spr_zombieL_N_0
        .globl _spr_zombieL_N_1
        .globl _spr_zombieL_S_0
        .globl _spr_zombieL_S_1
        .globl _spr_zombieL_E_0
        .globl _spr_zombieL_E_1
        .globl _spr_zombieL_O_0
        .globl _spr_zombieL_O_1

        .globl _spr_key
        
        .globl _spr_door_0
        .globl _spr_door_1
;;
    

;; Etiquetas
    .globl entities
    .globl next_entity
    ;; Plantillas de entidades
        .globl entity_player_temp
        .globl entity_enemy_temp
        .globl entity_key_temp
        .globl entity_door_temp
;;