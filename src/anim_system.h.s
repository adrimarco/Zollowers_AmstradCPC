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

;; Functions animation
    .globl anim_update_entities

    .globl animsys_changeSpriteDirection

    .globl animsys_changeSprite
    .globl animsys_changeAnimation
    .globl animsys_changeGlobalAnimation

    .globl anim_player
    .globl anim_player_N
    .globl anim_player_S
    .globl anim_player_E
    .globl anim_player_O

    .globl anim_zombieG
    .globl anim_zombieG_N
    .globl anim_zombieG_S
    .globl anim_zombieG_E
    .globl anim_zombieG_O

    .globl anim_zombieB
    .globl anim_zombieB_N
    .globl anim_zombieB_S
    .globl anim_zombieB_E
    .globl anim_zombieB_O

    .globl anim_zombieL
    .globl anim_zombieL_N
    .globl anim_zombieL_S
    .globl anim_zombieL_E
    .globl anim_zombieL_O
;;

;; Animation
    ANIM_N          = 0
    ANIM_S          = 2
    ANIM_E          = 4
    ANIM_O          = 6

    POLI_ANIM_T     = 12
    ENEMY_ANIM_T    = 12
    NEXT_ANIM       = 3
;;