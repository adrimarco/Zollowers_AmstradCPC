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
.include "anim_system.h.s"

anim_player::
    .dw #anim_player_N
    .dw #anim_player_S
    .dw #anim_player_E
    .dw #anim_player_O

anim_player_N::
    .db #POLI_ANIM_T
    .dw _spr_poli_N_0
    .db #POLI_ANIM_T
    .dw _spr_poli_N_1
    .db #0
    .dw #anim_player_N

anim_player_S::
    .db #POLI_ANIM_T
    .dw _spr_poli_S_0
    .db #POLI_ANIM_T
    .dw _spr_poli_S_1
    .db #0
    .dw #anim_player_S

anim_player_E::
    .db #POLI_ANIM_T
    .dw _spr_poli_E_0
    .db #POLI_ANIM_T
    .dw _spr_poli_E_1
    .db #0
    .dw #anim_player_E

anim_player_O::
    .db #POLI_ANIM_T
    .dw _spr_poli_O_0
    .db #POLI_ANIM_T
    .dw _spr_poli_O_1
    .db #0
    .dw #anim_player_O

anim_zombieG::
    .dw #anim_zombieG_N
    .dw #anim_zombieG_S
    .dw #anim_zombieG_E
    .dw #anim_zombieG_O

anim_zombieG_N::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_N_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_N_1
    .db #0
    .dw #anim_zombieG_N

anim_zombieG_S::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_S_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_S_1
    .db #0
    .dw #anim_zombieG_S

anim_zombieG_E::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_E_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_E_1
    .db #0
    .dw #anim_zombieG_E

anim_zombieG_O::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_O_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieG_O_1
    .db #0
    .dw #anim_zombieG_O

anim_zombieB::
    .dw #anim_zombieB_N
    .dw #anim_zombieB_S
    .dw #anim_zombieB_E
    .dw #anim_zombieB_O

anim_zombieB_N::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_N_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_N_1
    .db #0
    .dw #anim_zombieB_N

anim_zombieB_S::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_S_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_S_1
    .db #0
    .dw #anim_zombieB_S

anim_zombieB_E::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_E_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_E_1
    .db #0
    .dw #anim_zombieB_E

anim_zombieB_O::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_O_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieB_O_1
    .db #0
    .dw #anim_zombieB_O

;; Animaciones Zombie Larcenas

anim_zombieL::
    .dw #anim_zombieL_N
    .dw #anim_zombieL_S
    .dw #anim_zombieL_E
    .dw #anim_zombieL_O

anim_zombieL_N::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_N_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_N_1
    .db #0
    .dw #anim_zombieL_N

anim_zombieL_S::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_S_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_S_1
    .db #0
    .dw #anim_zombieL_S

anim_zombieL_E::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_E_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_E_1
    .db #0
    .dw #anim_zombieL_E

anim_zombieL_O::
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_O_0
    .db #ENEMY_ANIM_T
    .dw _spr_zombieL_O_1
    .db #0
    .dw #anim_zombieL_O