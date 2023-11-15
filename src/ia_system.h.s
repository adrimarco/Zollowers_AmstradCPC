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
;;  IA SYSTEM
;;

;; Ia behaviours
    .globl ia_chaser
;;

;; Functions
    .globl ia_changeEntityIA
    .globl ia_update_entities
;;

;; Aceso a valores de la memoria de las distintas ia
    ia_behaviour       = 0     ;; Funcion de la ia a ejecutar
    ia_tileObjective   = 2     ;; Tile al que tiene que moverse
;;