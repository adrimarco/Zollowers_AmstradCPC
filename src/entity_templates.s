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
.include "game_manager.h.s"
.include "anim_system.h.s"

;; Player template
entity_player_temp::
    .db E_TYPE_PLAYER                                                               ;; Tipo
    .db E_CMP_RENDER | E_CMP_PHYSIC | E_CMP_INPUT | E_CMP_COLLIDER | E_CMP_ANIM     ;; Componentes
    .db 0                                                                           ;; Posicion X
    .db 0                                                                           ;; Posicion Y
    .db 0                                                                           ;; Velocidad X
    .db 0                                                                           ;; Velocidad Y
    .dw _spr_poli_S_0                                                               ;; Sprite
    .db SPR_POLI_W                                                                  ;; Ancho sprite
    .db SPR_POLI_H                                                                  ;; Alto sprite
    .dw anim_player_S                                                               ;; Animacion Actual
    .db 0                                                                           ;; Tiempo animacion
    .dw 0x0000                                                                      ;; Funcion de IA
    .dw 0x0000                                                                      ;; Posicion anterior
    .db PLAYER_MOV_TIME                                                             ;; Ticks entre movimiento
    .db PLAYER_MOV_TIME                                                             ;; Ticks que faltan para moverse
    .db E_DIR_S                                                                     ;; Direccion a la que mira
    .dw 0                                                                           ;; Tile que ocupa
    .db E_TYPE_KEY | E_TYPE_DOOR | E_TYPE_ENEMY                                     ;; Tipos con los que colisiona
    .dw anim_player                                                                 ;; Animacion general
;;

;; Enemy template
entity_enemy_temp::
    .db E_TYPE_ENEMY                                                           ;; Tipo
    .db E_CMP_RENDER | E_CMP_PHYSIC | E_CMP_COLLIDER | E_CMP_ANIM | E_CMP_IA   ;; Componentes
    .db 0                                                                      ;; Posicion X
    .db 0                                                                      ;; Posicion Y
    .db 0                                                                      ;; Velocidad X
    .db 0                                                                      ;; Velocidad Y
    .dw 0x0000                                                                 ;; Sprite
    .db SPR_ENEMY_W                                                            ;; Ancho sprite
    .db SPR_ENEMY_H                                                            ;; Alto sprite
    .dw 0x0000                                                                 ;; Animacion
    .db 0                                                                      ;; Tiempo animacion
    .dw 0x0000                                                                 ;; Funcion de IA
    .dw 0x0000                                                                 ;; Posicion anterior
    .db ENEMY_MOV_TIME                                                         ;; Ticks entre movimiento
    .db ENEMY_MOV_TIME                                                         ;; Ticks que faltan para moverse
    .db E_DIR_O                                                                ;; Direccion a la que mira
    .dw 0                                                                      ;; Tile que ocupa
    .db 0                                                                      ;; Tipos con los que colisiona
    .dw anim_zombieG                                                           ;; Animacion General
;;

;; Key template
entity_key_temp::
    .db E_TYPE_KEY                                  ;; Tipo
    .db E_CMP_RENDER | E_CMP_COLLIDER               ;; Componentes
    .db MIN_X + 29                                  ;; Posicion X
    .db MIN_Y                                       ;; Posicion Y
    .db 0                                           ;; Velocidad X
    .db 0                                           ;; Velocidad Y
    .dw _spr_key                                    ;; Sprite
    .db SPR_KEY_W                                   ;; Ancho sprite
    .db SPR_KEY_H                                   ;; Alto sprite
    .dw 0x0000                                      ;; Animacion
    .db 0                                           ;; Tiempo animacion
    .dw 0x0000                                      ;; Funcion de IA
    .dw 0x0000                                      ;; Posicion anterior
    .db PLAYER_MOV_TIME                             ;; Ticks entre movimiento
    .db PLAYER_MOV_TIME + 1                         ;; Ticks que faltan para moverse
    .db 0                                           ;; Direccion a la que mira
    .dw 0                                           ;; Tile que ocupa
    .db 0                                           ;; Tipos con los que colisiona
    .dw 0x0000                                      ;; Animacion general
;;

;; Door template
entity_door_temp::
    .db E_TYPE_DOOR                                 ;; Tipo
    .db E_CMP_RENDER | E_CMP_COLLIDER               ;; Componentes
    .db MIN_X + 60                                  ;; Posicion X
    .db MIN_Y                                       ;; Posicion Y
    .db 0                                           ;; Velocidad X
    .db 0                                           ;; Velocidad Y
    .dw _spr_door_0                                 ;; Sprite
    .db SPR_DOOR_W                                  ;; Ancho sprite
    .db SPR_DOOR_H                                  ;; Alto sprite
    .dw 0x0000                                      ;; Animacion
    .db 0                                           ;; Tiempo animacion
    .dw 0x0000                                      ;; Funcion de IA
    .dw 0x0000                                      ;; Posicion anterior
    .db PLAYER_MOV_TIME                             ;; Ticks entre movimiento
    .db PLAYER_MOV_TIME                             ;; Ticks que faltan para moverse
    .db 0                                           ;; Direccion a la que mira
    .dw 0                                           ;; Tile que ocupa
    .db 0                                           ;; Tipos con los que colisiona
    .dw 0x0000                                      ;; Animacion general
;;