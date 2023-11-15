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
;;  Level templates
;;

;; Constantes
    LEVEL_W                     = 20
    LEVEL_H                     = 18
    TILE_W                      = 4
    TILE_H                      = 8

    level_player_pos            = 2
    level_door_pos              = 4
    level_enemies               = 6
    LEVEL_ENEMIES_SIZE          = 3
    LEVEL_KEYS_SIZE             = 2

    ENEMY_SPEED_SLOW            = 3
    ENEMY_SPEED_FAST            = 2
    
    ;; Tipos de enemigos
        ENEMY_TYPE_CHASER_SLOW  = 0x01
        ENEMY_TYPE_CHASER_FAST  = 0x02
    ;;
;;
;; Levels
    .globl level_01
    .globl level_02
    .globl level_03
    .globl level_04
    .globl level_05
    .globl level_06
    .globl level_07
    .globl level_08
    .globl level_09
    .globl level_10
    .globl level_11
    .globl level_12
    .globl level_13
    .globl level_14
    .globl level_15
    .globl level_final
;;