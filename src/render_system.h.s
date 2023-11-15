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
;; Render_system
;;

;; Funciones
    .globl render_init
    .globl render_entities
    .globl render_entity
    .globl render_draw_level
    .globl render_menu_init
    .globl render_menu_print_start
    .globl render_menu_print_controls
    .globl render_menu_draw_selected
    .globl render_menu_draw_default
    .globl render_menu_update_selection
    .globl render_erase_screen
    .globl render_erase_entity
    .globl render_HUD_display
    .globl render_show_level
    .globl render_show_level_default
    .globl render_update_lives
    .globl render_show_score
    .globl render_show_score_default
    .globl render_border_color
    .globl render_display_final_score
    .globl render_sprite
    .globl render_help_screen
;;

;; Constantes
    ;; Tamanyo tilemap
        TILEMAP_WIDTH       = 20
        TILEMAP_VIEW_SIZE   = 0x1214
    ;;
    ;; Strings del menu principal
        MENU_CHARACTER_COLOR_DEFAULT       =   7
        MENU_CHARACTER_COLOR_MAIN          =  10
        MENU_CHARACTER_BG_COLOR_BLACK      =   0
        MENU_STRING_COORD_X                =  25
        MENU_START_COORD_Y                 =  120
        MENU_CONTROLS_COORD_Y              =  140
        MENU_SPRITE_X                      =  20
        MENU_SPRITE_Y                      =  40
    ;;
    ;; Strings del HUD
        LEVEL_STRING_COORD_X               =  6
        LEVEL_NUMBER_COORD_X               =  12
        SCORE_STRING_COORD_X               =  30
        LIVES_STRING_COORD_X               =  54
        HUD_STRING_COORD_Y                 =  164
        HUD_STRING_2_COORD_Y               =  176  
        SCORE_DIGIT0_COORD_X               =  SCORE_STRING_COORD_X
        SCORE_DIGIT1_COORD_X               =  SCORE_DIGIT0_COORD_X + 4
    ;;
    ;; Sprites del HUD
        SPRITE_HEART_WIDTH                 =  4
        SPRITE_HEART_HEIGHT                =  8  
        COLOR_BLACK                        =  0
        BOX_HEIGHT                         =  8
        BOX_WIDTH                          =  4
    ;;
    ;; Colores del borde de la pantalla
        DEFAULT_BORDER      = 0x00
        MAIN_MENU_BORDER    = 0x04
        DEATH_BORDER        = 0x0C
        WAIT_BORDER         = 0x1A
    ;;
    ;; Pantalla de puntuacion final
        ;; Strings
            FS_GAME_OVER_X      = 22
            FS_GAME_OVER_Y      = 40
            FS_LABELS_X         = 19
            FS_VALUES_X         = 43
            FS_LABEL_SCORE_Y    = 100
            FS_LABEL_LEVEL_Y    = 116
            FS_CONTINUE_X       = 16
            FS_CONTINUE_Y       = 160
        ;;
        ;; Sprites
            FS_SPR_1_X          = FS_GAME_OVER_X - 8
            FS_SPR_2_X          = FS_GAME_OVER_X + 36 + 4
            FS_SPR_1_2_Y        = FS_GAME_OVER_Y - 4
            FS_SPR_3_X          = 38
            FS_SPR_3_Y          = 56
            SPR_W               = 4
            SPR_H               = 16
            FS_EXTRA_1_X        = 4
            FS_EXTRA_1_Y        = 8
            FS_EXTRA_2_X        = 12
            FS_EXTRA_2_Y        = 94
            FS_EXTRA_3_X        = 54
            FS_EXTRA_3_Y        = 66
            FS_EXTRA_4_X        = 70
            FS_EXTRA_4_Y        = 120
            FS_EXTRA_5_X        = 8
            FS_EXTRA_5_Y        = 162
        ;;
    ;;
    ;; Pantalla de ayuda
        ;; Strings
            HS_CONTROLS_TITLE_X     = 23
            HS_CONTROLS_TITLE_Y     = 16
            HS_CONTROLS_1_X         = 4
            HS_CONTROLS_2_X         = 44
            HS_CONTROLS_1_Y         = 40
            HS_CONTROLS_2_Y         = HS_CONTROLS_1_Y + 16
            HS_OBJECTIVE_TITLE_X    = HS_CONTROLS_TITLE_X - 2
            HS_OBJECTIVE_TITLE_Y    = 88
            HS_OBJECTIVE_X          = 16
            HS_OBJECTIVE_1_Y        = HS_OBJECTIVE_TITLE_Y + 24
            HS_OBJECTIVE_2_Y        = HS_OBJECTIVE_1_Y + 16
            HS_OBJECTIVE_3_Y        = HS_OBJECTIVE_2_Y + 16
            HS_CONTINUE_X           = 16
            HS_CONTINUE_Y           = 176
        ;; Sprites
            HS_SPR_X                = 8
            HS_SPR_1_Y              = HS_OBJECTIVE_1_Y - 4
            HS_SPR_2_Y              = HS_OBJECTIVE_2_Y - 4
            HS_SPR_3_Y              = HS_OBJECTIVE_3_Y - 4
    ;;

    .globl _spr_menu
    .globl _g_palette
    .globl _tileset_00
    .globl _hud
    .globl _spr_heart

;;