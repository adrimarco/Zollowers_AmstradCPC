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
.include "render_system.h.s"
.include "entity_manager.h.s"
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "menu_manager.h.s"
.include "game_manager.h.s"

.include "screens/imagen_inicio.h.s"

;Strings que se imprimiran por pantalla
string_level: .asciz "LEVEL"
string_score: .asciz "SCORE"
string_lives: .asciz "LIVES"
string_game_over: .asciz "GAME OVER"
string_continuar: .asciz "CONTINUE (1)"

;;
;; Inicializa el sistema de render
;;
render_init:

    ;; Cambia el modo de color
    ld c, #0

    call cpct_setVideoMode_asm

    ;; Modifica la paleta
    ld hl, #_g_palette
    ld de, #16

    call cpct_setPalette_asm

    ld h, #DEFAULT_BORDER
    call render_border_color

    ;; Configura el tileset
    ld bc, #TILEMAP_VIEW_SIZE
    ld de, #TILEMAP_WIDTH
    ld hl, #_tileset_00

    call cpct_etm_setDrawTilemap4x8_ag_asm

    ret
;;

;;
;; Dibuja todas las entidades
;;
render_entities::
    ;; Hace que el manager ejecute la funcion render_entity sobre todas las entidades
    ld hl, #render_entity
    ld b, #E_CMP_RENDER
    call entityman_forall_matching
    ret
;;

;;
;; Dibuja una entidad
;;      IX - Direccion de la entidad a dibujar
;;
render_entity::
    ;; Comprobar que la entidad no se tiene que destruir
    ld a, e_type(ix)
    and #E_TYPE_DESTROY
    jr nz, notDrawingEntity
        ;; La entidad no se va a destruir, por lo que se dibuja
        ;; Calcula de la posicion del sprite actual en pantalla
        ld de, #0xC000
        ld c, e_posX(ix)
        ld b, e_posY(ix)

        call cpct_getScreenPtr_asm

        ;; La guarda para usarla mas tarde y no carcularla de nuevo
        push hl

        ;; Comprueba si la entidad se mueve para borrarla
        ld a, e_components(ix)
        and #E_CMP_PHYSIC
        jr z, not_erase
            ;; Como se mueve, borra el sprite de la posicion anterior
            call render_erase_entity
        not_erase:

        ;; Recupera en HL la direccion donde se va a dibujar el sprite
        pop hl

        ld e_posAnt+1(ix), h
        ld e_posAnt(ix), l

        ;; Cargo los parametros y dibujo el sprite
        ex de, hl
        ld h, e_sprite+1(ix)
        ld l, e_sprite(ix)
        ld c, e_sprW(ix)
        ld b, e_sprH(ix)

        call cpct_drawSprite_asm
        ret
    notDrawingEntity:
        ;; La entidad se destruye, por lo que unicamente se borra
        call render_erase_entity
    ret
;;

;;
;; Borra una entidad de la pantalla
;;      IX - Direccion de la entidad
;;      HL - Direccion de referencia para no realizar borrado
;;
render_erase_entity::
    ld d, e_posAnt+1(ix)        ;; Cargo en de la posicion de pantalla donde se dibujo
    ld e, e_posAnt(ix)

    ;; Comprueba que la direccion anterior no coincide con HL para no hacer el borrado
    ld a, d
    cp h
    jr nz, new_position
    ;; El primer valor es igual, comprueba el otro
    ld a, e
    cp l
    ;; Si la direccion es la misma hace ret
    ret z

    new_position:
    ;; Borra el sprite de la posicion anterior
    ld a, #0                    ;; Cargo en a el color de fondo
    ld c, e_sprW(ix)            ;; Cargo en c el ancho del sprite
    ld b, e_sprH(ix)            ;; Cargo en c el alto del sprite

    call cpct_drawSolidBox_asm  ;; Dibuja un solid box del ancho y alto del sprite en la posicion anterior del sprite para borrarlo
    ret
;;

;;
;; Dada la direccion de un nivel, dibuja sus tiles
;;      HL - Direccion del nivel
;;
render_draw_level::
    ;; Guarda la direccion para no perderla
    push hl

    ;; Calcula la posicion donde se dibuja el mapa
    ld de, #0xC000
    ld c, #MIN_X
    ld b, #MIN_Y

    call cpct_getScreenPtr_asm

    ;; Recupera la direccion del nivel
    pop de

    ;; Dibuja los tiles del nivel
    call cpct_etm_drawTilemap4x8_ag_asm

    ret
;;

;Metodo para hacer que el texto se escriba en color amarillo
render_menu_draw_selected::
    ;;En l se guarda el color de las letras y en h el color de fondo
    ld l,#MENU_CHARACTER_COLOR_MAIN
    ld h,#MENU_CHARACTER_BG_COLOR_BLACK
    call cpct_setDrawCharM0_asm
    ret 

;Metodo para hacer que el texto se escriba de color rojo
render_menu_draw_default::
    ;;En l se guarda el color de las letras y en h el color de fondo
    ld l,#MENU_CHARACTER_COLOR_DEFAULT 
    ld h,#MENU_CHARACTER_BG_COLOR_BLACK
    call cpct_setDrawCharM0_asm
    ret

;;Metodo para borrar lo que hay en pantalla
render_erase_screen:
    ld de,#0xC000
    ld a,#MENU_CHARACTER_BG_COLOR_BLACK 
    ld bc,#16400
    call cpct_memset_asm
    ret 

;Metodo para imprimir el texto 'Start'
render_menu_print_start:
    ;Guardamos en el registro iy la direccion de memoria donde empieza el string
    ld iy, #(start)
        ;En el registro de se pone donde inicia la memoria de video y en los 
        ;registros c y d las coordenadas x e y, con ello obtenemos donde poner el string
    ld de,#CPCT_VMEM_START_ASM
    ld c,#MENU_STRING_COORD_X 
    ld b,#MENU_START_COORD_Y
    call cpct_getScreenPtr_asm

    ;;Llamamos al metodo para dibujar el string en pantalla
    call cpct_drawStringM0_asm

    ret

;Metodo para imprimir el texto 'Controls'
render_menu_print_controls:
    ;Guardamos en el registro iy la direccion de memoria donde empieza el string
    ld iy, #(controls)

    ;En el registro de se pone donde inicia la memoria de video y en los 
    ;registros c y d las coordenadas x e y, con ello obtenemos donde poner el string
    ld de,#CPCT_VMEM_START_ASM
    ld c,#MENU_STRING_COORD_X 
    ld b,#MENU_CONTROLS_COORD_Y
    call cpct_getScreenPtr_asm

    ;;Llamamos al metodo para dibujar el string en pantalla
    call cpct_drawStringM0_asm

    ret


;Metodo para actualizar la seleccion del menu principal
render_menu_update_selection::

    ;Guardamos en el registro a la selección actual
    ld a,#0

    ;Se comprueba si esta es 0 la cual corresponderia a Start, de ser asi la reimprime si no
    ;reimprime controls
    or a
    jr nz, option_one_not_chosen
        call render_menu_print_start
        ret
    option_one_not_chosen:
        call render_menu_print_controls
        ret

;Metodo para inicializar la pantalla principal
render_menu_init::
    ;Vacia la pantalla
    call render_erase_screen

    ;; Actualiza el color del borde a por defecto
    ld h, #MAIN_MENU_BORDER
    call render_border_color

    ;Cargamos en hl el sprite y en b y c el alto y el ancho
    ld hl, #_imagen_inicio_end
    ld de, #0xFFFF
    call cpct_zx7b_decrunch_s_asm

    ret
;;
;Metodo para dibujar strings
;       IY- String
;       C- Coordenada x
;       B- Coordenada y
;;
render_string::

    ;En el registro de se pone donde inicia la memoria de video y en los 
    ;registros c y d las coordenadas x e y, con ello obtenemos donde poner el string
    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm

    ;;Llamamos al metodo para dibujar el string en pantalla
    call cpct_drawStringM0_asm
    ret


;;
;Metodo para mostrar el HUD del juego
;;
render_HUD_display::

    ;; Calcula la posicion donde se dibuja el interfaz
    ld de, #0xC000
    ld c, #MIN_X
    ld b, #MAX_Y

    call cpct_getScreenPtr_asm

    ;;Guardo en el registro DE el tilemap
    ld de,#_hud

    ;; Dibuja los tiles del nivel
    call cpct_etm_drawTilemap4x8_ag_asm

    call render_menu_draw_default
    
    ;; Dibuja la string time
    ld iy,#string_level
    ld c,#LEVEL_STRING_COORD_X 
    ld b,#HUD_STRING_COORD_Y
    call render_string

    ;;Dibuja la string score
    ld iy,#string_score
    ld c,#SCORE_STRING_COORD_X 
    ld b,#HUD_STRING_COORD_Y
    call render_string

    ;;Dibuja la string lives
    ld iy,#string_lives
    ld c,#LIVES_STRING_COORD_X 
    ld b,#HUD_STRING_COORD_Y
    call render_string

    ;;Dibuja las vidas del jugador
    call render_update_lives

    ld de,#CPCT_VMEM_START_ASM
    ld c,#SCORE_DIGIT0_COORD_X 
    ld b,#HUD_STRING_2_COORD_Y 
    call cpct_getScreenPtr_asm
    ld e,#'0'
    call cpct_drawCharM0_asm

    call render_show_score_default

    ret
;

render_show_level_default::
    ;; Carga los valores por defecto
    ld c, #LEVEL_NUMBER_COORD_X
    ld b, #HUD_STRING_2_COORD_Y

    jr render_show_level
;;
;; Actualiza el tiempo restante para el jugador
;;      C - Posicion X en pantalla
;;      B - Posicion Y en pantalla
;;
render_show_level::
    ;; Almacena en la pila el valor de BC
    push bc

    ;; Incrementa C en 4 para el digito de las unidades
    ld a, c
    add a, #4
    ld c, a

    ;; Guarda el valor para no perderlo y usarlo a continuacion
    push bc

    ;; Guarda en A el numero del nivel
    ld a,(level_number)
    inc a

    ;; Calcula la representacion en char
    call render_get_char_representation

    ;; Recupera de la pila la posicion donde dibujarlo y guarda la representacion para despues
    pop bc
    push af

    and #0x0F
    add #48

    ;; Copia el valor en E y lo guarda en la pila para no perderlo
    ld e,a
    push de

    ;; Recupera la direccion donde se dibujara
    ld de,#CPCT_VMEM_START_ASM 
    call cpct_getScreenPtr_asm

    ;; Recupera el numero que va a dibujar
    pop de

    ;; Dibuja el primer numero
    call cpct_drawCharM0_asm

    ;; Recupera el numero del nivel de la pila para imprimir el segundo digito
    pop af
    rra
    rra
    rra
    rra
    and #0x0F
    add #48

    ;; Recupera la posicion donde va a dibujar el digito de las decenas
    pop bc

    ;; Copia el valor en E y lo guarda en la pila
    ld e,a
    push de

    ;; Calcula la direccion donde se va a dibujar
    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm

    ;; Recupera el numero a dibujar y lo dibuja
    pop de
    call cpct_drawCharM0_asm

    ret 
;;

;;
;; Devuelve la representacion en caracteres en un byte de un numero
;;      A - Numero que se transformara a char
;;  Salida:
;;      A - Numero con representacion en char
;;
render_get_char_representation:
    ;; Inicializa B con 0
    ld b, #0

    ;; Hace un bucle para guardar en B las decenas del numero en A
    check_lower_than_ten:
    cp #10
    jr c, lower_than_ten
        ;; Incrementa en 1 las decenas
        inc b
        ;; Resta una decena al numero
        sub #10
        ;; Repite el proceso
        jr check_lower_than_ten
    lower_than_ten:
    ;; Desplaza las decenas 4 bits
    sla b
    sla b
    sla b
    sla b

    ;; Junta los valores
    add a, b
    ret
;;

;;
;Actualiza el sprite de vidas del jugador
;;
render_update_lives::
    ;; Borra los sprites
    ld de,#CPCT_VMEM_START_ASM
    ld b, #HUD_STRING_2_COORD_Y
    ld c, #LIVES_STRING_COORD_X 
    call cpct_getScreenPtr_asm
    ex de,hl
    ld a,#COLOR_BLACK
    ld b,#BOX_HEIGHT
    ld c,#BOX_WIDTH*5
    call cpct_drawSolidBox_asm

    ;; Carga las vidas
    ld a,(remaining_lives)

    ;; Comprueba cuantas vidas tienes
    cp #3
    jr z, draw_three_lives

    cp #2
    jr z, draw_two_lives

    cp #1
    jr z, draw_one_life

    ;; Si no tienes vidas, no dibuja ningun sprite
    ret
    draw_three_lives:
    ;; Dibuja el tercer sprite
    ld c,#LIVES_STRING_COORD_X + 16
    ld b,#HUD_STRING_2_COORD_Y
    ld hl,#_spr_heart
    ld d,#SPRITE_HEART_HEIGHT
    ld e,#SPRITE_HEART_WIDTH 

    call render_sprite

    draw_two_lives:
    ;; Dibuja el segundo sprite
    ld c,#LIVES_STRING_COORD_X + 8
    ld b,#HUD_STRING_2_COORD_Y
    ld hl,#_spr_heart
    ld d,#SPRITE_HEART_HEIGHT
    ld e,#SPRITE_HEART_WIDTH 

    call render_sprite

    draw_one_life:
    ;; Dibuja el primer sprite
    ld c,#LIVES_STRING_COORD_X
    ld b,#HUD_STRING_2_COORD_Y
    ld hl,#_spr_heart
    ld d,#SPRITE_HEART_HEIGHT
    ld e,#SPRITE_HEART_WIDTH 

    call render_sprite

    ret 
;;

render_show_score_default::
    ;; Carga los valores por defecto
    ld c,#SCORE_DIGIT1_COORD_X 
    ld b,#HUD_STRING_2_COORD_Y 
    
    jr render_show_score
;;

;;
;; Actualiza la puntuacion mostrada del jugador
;;      C - Posicion X en pantalla
;;      B - Posicion Y en pantalla
;;
render_show_score::
;;Dibuja el primer byte de la puntuacion del jugador
    ;; Guarda la posicion para los demas digitos
    push bc

    ld a,(player_score)
    rra
    rra
    rra
    rra
    and #0x0F
    add #48
    ld e,a

    push de

    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm
    pop de
    call cpct_drawCharM0_asm

;;Dibuja el segundo byte de la puntuacion del jugador
    ;; Actualiza la posicion para el segundo digito y la guarda para el tercero
    pop bc
    ld a, c
    add a, #4
    ld c, a
    push bc

    ld a,(player_score)
    and #0x0F
    add #48
    ld e,a

    push de

    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm
    pop de
    call cpct_drawCharM0_asm

;;Dibuja el tercer byte de la puntuacion del jugador
    ;; Actualiza la posicion para el tercer digito y la guarda para el cuarto
    pop bc
    ld a, c
    add a, #4
    ld c, a
    push bc

    ld a,(player_score+1)
    rra
    rra
    rra
    rra
    and #0x0F
    add #48
    ld e,a

    push de

    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm
    pop de
    call cpct_drawCharM0_asm

;;Dibuja el primer byte de la puntuacion del jugador
    ;; Actualiza la posicion para el cuarto digito
    pop bc
    ld a, c
    add a, #4
    ld c, a

    ld a,(player_score+1)
    and #0x0F
    add #48
    ld e,a

    push de

    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm
    pop de
    call cpct_drawCharM0_asm
    
    
    ret 

;;
;; Cambia el color del borde de la pantalla
;;      H - Nuevo color
;;
render_border_color::
    ld l, #16
    call cpct_setPALColour_asm

    ret
;;

;;
;; Dibuja la pantalla final donde se muestra la puntuacion obtenida
;;
render_display_final_score::
    ;; Vacia la pantalla
    call render_erase_screen

    call render_menu_draw_selected

    ;; Dibuja el string GAME OVER
    ld iy, #string_game_over
    ld c, #FS_GAME_OVER_X
    ld b, #FS_GAME_OVER_Y
    call render_string

    call render_menu_draw_default

    ;; Dibuja dos zombis a los lados del texto y el poli zombificado
    ;; Dibuja el primer sprite
    ld c,#FS_SPR_1_X 
    ld b,#FS_SPR_1_2_Y 
    ld hl, #_spr_zombieG_E_0
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el segundo sprite
    ld c,#FS_SPR_2_X 
    ld b,#FS_SPR_1_2_Y 
    ld hl, #_spr_zombieG_O_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el tercer sprite
    ld c,#FS_SPR_3_X 
    ld b,#FS_SPR_3_Y 
    ld hl, #_spr_poli_D
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja la puntuacion final conseguida
    ;; Dibuja el string SCORE
    ld iy, #string_score
    ld c, #FS_LABELS_X
    ld b, #FS_LABEL_SCORE_Y
    call render_string

    ;; Dibuja el valor de los puntos obtenido
    ld c, #FS_VALUES_X
    ld b, #FS_LABEL_SCORE_Y
    call render_show_score

    ;; Dibuja el ultimo nivel alcanzado
    ;; Dibuja el string LEVEL
    ld iy, #string_level
    ld c, #FS_LABELS_X
    ld b, #FS_LABEL_LEVEL_Y
    call render_string

    ;; Dibuja el numero del nivel en el que ha terminado el jugador
    ld c, #FS_VALUES_X
    ld b, #FS_LABEL_LEVEL_Y
    call render_show_level

    ;; Dibuja el string CONTINUAR
    ld iy, #string_continuar
    ld c, #FS_CONTINUE_X
    ld b, #FS_CONTINUE_Y
    call render_string

    ;; Comprueba si ha llegado al ultimo nivel
    ld a, (level_number)
    cp #LAST_LEVEL_INDEX
    ret nz

    ;; Es el ultimo nivel, asi que dibuja muchos zombis en pantalla
    ;; Dibuja el primer zombi extra
    ld c,#FS_EXTRA_1_X  
    ld b,#FS_EXTRA_1_Y
    ld hl,#_spr_zombieB_O_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el segundo zombi extra
    ld c,#FS_EXTRA_2_X  
    ld b,#FS_EXTRA_2_Y
    ld hl,#_spr_zombieG_E_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el tercer zombi extra
    ld c,#FS_EXTRA_3_X  
    ld b,#FS_EXTRA_3_Y
    ld hl,#_spr_zombieL_O_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el cuarto zombi extra
    ld c,#FS_EXTRA_4_X  
    ld b,#FS_EXTRA_4_Y
    ld hl,#_spr_zombieB_E_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ;; Dibuja el quinto zombi extra
    ld c,#FS_EXTRA_5_X  
    ld b,#FS_EXTRA_5_Y
    ld hl,#_spr_zombieB_O_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ret
;;

;;
;; Dibuja un sprite en las coordenadas indicadas
;;      B  - Posicion Y en pantalla
;;      C  - Posicion X en pantalla
;;      D  - Alto del sprite
;;      E  - Ancho del sprite
;;      HL - Direccion del sprite
;;
render_sprite::
    ;; Guarda HL y DE en la pila para no perderlo
    push hl
    push de

    ;; Calcula la direccion donde dibujarlo a partir de BC
    ld de,#CPCT_VMEM_START_ASM
    call cpct_getScreenPtr_asm
    ex de, hl

    ;; Saca el resto de parametros (sprite, ancho, alto) de la pila y lo dibuja
    pop bc
    pop hl

    call cpct_drawSprite_asm

    ret
;;

;;
;; Dibuja la pantalla de ayuda
;;
render_help_screen::
    ;; Vacia la pantalla
    call render_erase_screen

    ;; Dibuja los string en pantalla
    ;; Strings de controles
    call render_menu_draw_selected

    ld iy, #string_controls
    ld c, #HS_CONTROLS_TITLE_X
    ld b, #HS_CONTROLS_TITLE_Y
    call render_string

    call render_menu_draw_default

    ld iy, #string_up
    ld c, #HS_CONTROLS_2_X
    ld b, #HS_CONTROLS_1_Y
    call render_string

    ld iy, #string_down
    ld c, #HS_CONTROLS_2_X
    ld b, #HS_CONTROLS_2_Y
    call render_string

    ld iy, #string_left
    ld c, #HS_CONTROLS_1_X
    ld b, #HS_CONTROLS_1_Y
    call render_string

    ld iy, #string_right
    ld c, #HS_CONTROLS_1_X
    ld b, #HS_CONTROLS_2_Y
    call render_string

    ;; Strings de objetivos
    call render_menu_draw_selected

    ld iy, #string_objective
    ld c, #HS_OBJECTIVE_TITLE_X
    ld b, #HS_OBJECTIVE_TITLE_Y
    call render_string
    
    call render_menu_draw_default

    ld iy, #string_tip_1
    ld c, #HS_OBJECTIVE_X
    ld b, #HS_OBJECTIVE_1_Y
    call render_string

    ld iy, #string_tip_2
    ld c, #HS_OBJECTIVE_X
    ld b, #HS_OBJECTIVE_2_Y
    call render_string

    ld iy, #string_tip_3
    ld c, #HS_OBJECTIVE_X
    ld b, #HS_OBJECTIVE_3_Y
    call render_string

    ;; String de continuar
    ld iy, #string_continuar
    ld c, #HS_CONTINUE_X
    ld b, #HS_CONTINUE_Y
    call render_string

    ;; Dibuja los sprites
    ld c,#HS_SPR_X  
    ld b,#HS_SPR_1_Y
    ld hl,#_spr_zombieG_O_1
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ld c,#HS_SPR_X  
    ld b,#HS_SPR_2_Y
    ld hl,#_spr_key
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ld c,#HS_SPR_X  
    ld b,#HS_SPR_3_Y
    ld hl,#_spr_door_0
    ld e, #SPR_W
    ld d, #SPR_H

    call render_sprite

    ret
;;