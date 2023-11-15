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
;
;;menu_manager
;

;Metodos y variables
    .globl start
    .globl controls
    .globl menu_option_pressed
    .globl menuman_update
    .globl menuman_wait_loop
;
;; Strings globales
    .globl string_up
    .globl string_down
    .globl string_left
    .globl string_right
    .globl string_controls
    .globl string_objective
    .globl string_tip_1
    .globl string_tip_2
    .globl string_tip_3
;;
;; Constantes
    MENU_INDEX_SIZE                    = 2
    MENU_ACTIVATION_NULL               = 0
    MENU_ACTIVATION_OK                 = 1
;