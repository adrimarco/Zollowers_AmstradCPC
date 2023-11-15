;;
;; GAME_MANAGER
;;

;; Funciones
    .globl gameman_init
    .globl gameman_play
    .globl gameman_add_key
    .globl gameman_load_next_level
    .globl gameman_check_door
    .globl gameman_lose_one_life
    .globl game_manager_update_score
    .globl gameman_reset
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
;; Variables
    .globl current_level
    .globl time_left
    .globl remaining_lives
    .globl player_score
    .globl level_number
    .globl player_hit_counter

    .globl gameman_score_reward
;;

;; Constantes
    INITIAL_LIFE        = 3
    LEVEL_START_FREEZE  = 150
    LOSE_LIVE_FREEZE    = 150
    KEY_TAKEN           = 2
    MAX_TIME_LEFT       = 60
    LAST_LEVEL_INDEX    = 15
    BONUS_LIFE          = 128
;;