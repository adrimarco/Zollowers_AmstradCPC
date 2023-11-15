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
.include "game_manager.h.s"
.include "entity_manager.h.s"
.include "physics_system.h.s"
.include "cpct_functions.h.s"
.include "render_system.h.s"
.include "anim_system.h.s"
.include "level_templates.h.s"
.include "input_system.h.s"
.include "collision_system.h.s"
.include "ia_system.h.s"

;; Memoria reservada
   current_level::
      .dw 0x0000
   num_keys::
      .db 0x01
   door_entity::
      .dw 0x0000
   level_number::
      .db -1               ;; Indica el numero del nivel. -1 -> El juego se tiene que inicializar
   levels_list:
      .dw level_01
      .dw level_02
      .dw level_03
      .dw level_04
      .dw level_05
      .dw level_06
      .dw level_07
      .dw level_08
      .dw level_09
      .dw level_10
      .dw level_11
      .dw level_12
      .dw level_13
      .dw level_14
      .dw level_15
      .dw level_final
      .dw 0xFFFF
   game_over:
      .db 0
   freeze_screen:          ;; Si != 0 -> El juego no se actualiza
      .db 0
   remaining_lives::
      .db INITIAL_LIFE
   time_left::
      .db MAX_TIME_LEFT
   player_score::
      .db 0 , 0
   player_hit_counter::
      .db 0
   bonus_points:
      .db 0
;;

;;
;; Inicializa el juego
;;
gameman_init::
   .db 0xED, 0xFF          ;; BREAKPOINT
   ;; El juego ha comenzado
   ld a, #1
   ld (game_over), a

   ;;Reiniciamos la puntuacion del jugador y los puntos bonus
   xor a
   ld (player_score), a
   ld (player_score+1), a
   ld (bonus_points), a

   ;; Actualiza las vidas del jugador a la cantidad inicial
   ld a, #INITIAL_LIFE
   ld (remaining_lives), a
   
   ;;Dibuja el hud 
   call render_HUD_display

   ;; Comprueba si el juego ha sido inicializado previamente
   ld a, (level_number)
   or a
   jr z, gameman_init_initialized
      ;; Inicializa las entidades
      call entityman_init

      jr gameman_init_level
   gameman_init_initialized:
      ;; Carga en level_number el valor por defecto
      ld a, #-1
      ld (level_number), a

   gameman_init_level:

   ;; Crea una entidad player
   ld hl, #entity_player_temp
   call entityman_create_entity

   ;; Crea una entidad puerta
   ld hl, #entity_door_temp
   call entityman_create_entity
   ;; Guardo en door_entity la direccion de memoria donde estara la entidad puerta
   push ix
   pop hl
   ld (door_entity), hl

   ;; Actualiza level_number y carga el primer nivel
   call gameman_load_next_level

   ret 
;;

;;
;; Bucle del juego
;;
gameman_play::
   ;; Cambia el sprite al jugador
   ld ix, #entities
   ld hl, #_spr_poli_S_0
   call animsys_changeSprite

   ;; Renderiza las entidades
   call render_entities

   ;; Actualiza el color del borde a por defecto
   ld h, #DEFAULT_BORDER
   call render_border_color

   ;; Modifica el valor de game_over para que la partida comience
   ld a, #1
   ld (game_over), a

   ;; Muestra el nivel actual
   call render_show_level_default

   ;; Congela brevemente la pantalla antes de empezar a jugar
   ld a, #LEVEL_START_FREEZE
   ld (freeze_screen), a

   loop:
      call cpct_waitVSYNC_asm
      ;; Comprueba que la pantalla no esta congelada
      ld a, (freeze_screen)
      or a
      jr nz, screen_frozen
         ;; Comprueba que no debe salir del bucle
         ld a, (game_over)
         or a
         jr z, check_lives

         ;; La ejecucion continua
         call render_entities
         
         call entityman_destroy_entities
         call physics_update_entities
         call collision_update

         ;; Comprueba que tras las colisiones no se ha producido ningun evento que termine el bucle
         ld a, (game_over)
         or a
         ld a, (freeze_screen)               ;; Carga en A el contenido de freeze_screen porque lo necesita si salta a frozen_screen
         jr z, screen_frozen

         call ia_update_entities
         call input_update_entities
         call anim_update_entities

         jr loop
      screen_frozen:
         ;; Comprueba si no se ha terminado la partida
         ld a, (game_over)
         or a
         jr z, not_border_effect
            ;; La partida esta empezando, modifica el color del borde
            ld h, #WAIT_BORDER
            call render_border_color
            
            ;; Espera a que pasen cierta cantidad de lineas
            ld a, (freeze_screen)
            count_time:
               ld l, #18
               dec_timer:
               ;; Decrementa el contador
               dec l
               jr nz, dec_timer

               ;; Resta una linea (que en realidad son 2)
               dec a
               jr nz, count_time

            ;; Termina de contar lineas, actualiza el color del borde
            ld h, #DEFAULT_BORDER
            call render_border_color
         not_border_effect:

         ;; La pantalla esta congelada
         halt
         halt
         ld a, (freeze_screen)
         dec a
         ld (freeze_screen), a

         jr loop
      
      check_lives:
      ;; Si ha perdido comprueba si le quedan vidas al jugador
      ld a, (remaining_lives)
      or a
      jr nz, gameman_play

   ret
;;

;;
;; Dibuja los obstaculos de un nivel
;;    HL - Direccion del nivel
;;
gameman_load_level:
   ;; Guarda la direccion del nivel en la pila y obtiene la direccion del mapa
   push hl

   ld e, (hl)
   inc hl
   ld d, (hl)
   ex de, hl

   ;; Actualiza el nivel actual
   ld (current_level), hl

   call render_draw_level

   ;; Recupera la direccion del nivel
   pop iy

   ;; Situa al jugador y la puerta
   ld ix, #entities
   ld b, level_player_pos(iy)
   ld c, level_player_pos+1(iy)
   call entityman_set_tile_position

   ld ix, (door_entity)
   ld b, level_door_pos(iy)
   ld c, level_door_pos+1(iy)
   call entityman_set_tile_position

   ;; Actualiza el sprite de la puerta para que este cerrada
   ld ix, (door_entity)
   ld hl, #_spr_door_0
   call animsys_changeSprite

   ;; Desplaza IY hasta los enemigos
   ld bc, #level_enemies
   add iy, bc

   ;; Coloca los enemigos
   check_next_enemy:
   ld h, (iy)
   ld l, 1(iy)

   ld a, h
   cp #0xFF
   jr z, level_enemies_end
      ;; No es el final del vector
      ;; Guarda el numero de enemigos creados y la posicion del nuevo enemigo en la pila
      push hl

      ;; Crea la entidad
      ld hl, #entity_enemy_temp
      call entityman_create_entity

      ;; Situa el enemigo en el mapa
      pop bc
      call entityman_set_tile_position

      ld a, 2(iy)
      cp #ENEMY_TYPE_CHASER_SLOW
      jr nz, not_type_chaser_slow
         .db #0xED, #0xFF
         ;; Hace un random para el easter egg del zombie de larcenas legacy
         call cpct_getRandom_lcg_u8_asm
         and a,#100                       ;; En A almacena el numero de 0 a 99
         cp #10                           ;; Resta 10 para ver si el numero esta entre 0 y 9, si es asi, se activa el zombie easter egg
         jr nc, create_default_zombie
            ;; Cambio el sprite de la entidad al del enemigo tipo chaser
            ld hl, #_spr_zombieL_O_0
            call animsys_changeSprite
            
            ;; Cambia la animacion de la entidad al del enemigo tipo chaser
            ld hl, #anim_zombieL_O
            call animsys_changeAnimation

            ;; Cambia la animacion global de la entidad al del enemigo tipo chaser
            ld hl, #anim_zombieL
            call animsys_changeGlobalAnimation

            jr random_sprite_endif

         create_default_zombie:
         ;; Cambio el sprite de la entidad al del enemigo tipo chaser
         ld hl, #_spr_zombieG_O_0
         call animsys_changeSprite
         
         ;; Cambia la animacion de la entidad al del enemigo tipo chaser
         ld hl, #anim_zombieG_O
         call animsys_changeAnimation

         ;; Cambia la animacion global de la entidad al del enemigo tipo chaser
         ld hl, #anim_zombieG
         call animsys_changeGlobalAnimation

         random_sprite_endif:

         ;; Cambia el comportamiento de la entidad al del enemigo tipo chaser y tambien su velocidad
         ld hl, #ia_chaser
         ld a,  #ENEMY_SPEED_SLOW
         call ia_changeEntityIA

         jr type_enemy_endif
      not_type_chaser_slow:

      cp #ENEMY_TYPE_CHASER_FAST
      jr nz, not_type_chaser_fast
         ;; Cambio el sprite de la entidad al del enemigo tipo chaser
         ld hl, #_spr_zombieB_O_0
         call animsys_changeSprite

         ;; Cambia la animacion de la entidad al del enemigo tipo chaser
         ld hl, #anim_zombieB_O
         call animsys_changeAnimation

         ;; Cambia la animacion global de la entidad al del enemigo tipo chaser
         ld hl, #anim_zombieB
         call animsys_changeGlobalAnimation

         ;; Cambia el comportamiento de la entidad al del enemigo tipo chaser y tambien su velocidad
         ld hl, #ia_chaser
         ld a,  #ENEMY_SPEED_FAST
         call ia_changeEntityIA

         jr type_enemy_endif
      not_type_chaser_fast:
      
      type_enemy_endif:

      ;; Pasa a la siguiente posicion
      ld bc, #LEVEL_ENEMIES_SIZE
      add iy, bc
      jr check_next_enemy
   level_enemies_end:

   ;; Desplaza IY hasta las llaves
   inc iy

   ;; Inicializa el numero de llaves
   xor d

   ;; Coloca las llaves
   check_next_key:
   ld h, (iy)
   ld l, 1(iy)

   ld a, h
   cp #0xFF
   jr z, level_keys_end
      ;; No es el final del vector
      ;; Guarda el numero de enemigos creados y la posicion del nuevo enemigo en la pila
      push de
      push hl

      ;; Crea la entidad
      ld hl, #entity_key_temp
      call entityman_create_entity

      ;; Situa el enemigo en el mapa
      pop bc
      call entityman_set_tile_position

      ;; Incrementa la cantidad de llaves creadas
      pop de
      inc d

      ;; Pasa a la siguiente posicion
      ld bc, #LEVEL_KEYS_SIZE
      add iy, bc
      jr check_next_key
   level_keys_end:
   ;; Guarda el numero de llaves
   ld a, d
   ld (num_keys), a

   ;;Dibuja las entidades
   call render_entities

   ;; Dibuja el mapa del nivel
   ld hl, (current_level)
   call render_draw_level

   ;; Pone el tiempo a 60 segundos
   ;ld a,#60
   ;ld (time_left),a

   ret
;;


;;
;; Reduce en uno la cantidad de llaves a recoger y elimina una llave
;;    IX - Direccion de la llave
;;
gameman_add_key::
   ;; Marca la llave para ser destruida
   call entityman_set_destroy_entity

   ;; Reproduce sonido de coger llave
   call game_man_playsound_key

   ;; Actualiza el numero de llaves
   ld a, (num_keys)
   dec a
   ld (num_keys), a

   ;; Comprueba la cantidad de llaves restantes en el nivel
   or a
   jr nz, numKeysNotZero
      ;; Si es 0, el jugador tiene todas las llaves, asi que la puerta se abre (cambia el sprite)
      ld ix, (door_entity)
      ld hl, #_spr_door_1
      call animsys_changeSprite
      call game_man_playsound_door
   numKeysNotZero:

   ;; Suma la puntuacion
   ld a,#KEY_TAKEN
   call game_manager_update_score

   ;; Actualiza la puntuacion en pantalla
   call render_show_score_default

   ret

;;
;; Prepara al game manager para cargar el proximo nivel. Incrementa el numero del nivel actual y 
;; devuelve la direccion del nivel.
;; Salida:
;;    HL - Direccion del proximo nivel. 0xFFFF si no hay mas niveles.
;;
gameman_next_level:
   ;; Carga el nivel actual
   ld a, (level_number)

   ;; Incrementa su valor y guarda el resultado
   inc a
   ld (level_number), a

   ;; Busca y recoge la direccion del proximo nivel
   add a, a

   ld hl, #levels_list
   ld b, #0
   ld c, a
   add hl, bc

   ;; Ahora HL guarda la direccion donde se encuentra la direccion del nivel
   ld e, (hl)
   inc hl
   ld d, (hl)

   ;; Intercambia DE y HL para tener la direccion del nivel en HL
   ex de, hl

   ret
;;

;;
;; Carga el proximo nivel
;;
gameman_load_next_level::
   call gameman_next_level
   ;; Actualiza el contador de golpes
   call game_manager_update_hit_counter

   ;; Comprueba que no es el ultimo nivel
   ld a, h
   cp #0xFF
   jr z, no_more_levels
      ;; Carga el proximo nivel
      call gameman_load_level

      ;; Tras cargar el nivel, indica que termina la partida para congelar la pantalla
      xor a
      ld (game_over), a

      ret
   no_more_levels:
      ;; No quedan niveles, vuelve al menu
      ;; Pone la cantidad de vidas a 0 para que salga
      xor a
      ld (remaining_lives), a
      call gameman_game_over

   ret
;;

;;
;; Elimina las entidades y resetea las variables de los niveles
;;
gameman_game_over::
   ;; Destruye las entidades, marcandolas para destruir primero
   ld hl, #entityman_set_destroy_entity
   call entityman_forall

   call entityman_destroy_entities

   ;; Resetea los valores de los niveles
   xor a
   ld (game_over), a

   ret
;;

;;
;; Elimina las entidades y resetea las variables de los niveles
;;
gameman_reset_level::
   ;; Devuelve las entidades movibles a su posicion original
   call gameman_reset_level_entities_position

   ;; Indica que debe terminar el nivel
   xor a
   ld (game_over), a

   ret
;;

;;
;; Comprueba si puede pasar de nivel
;;
gameman_check_door::
   ;; Comprueba las llaves restantes
   ld a, (num_keys)
   or a
   jr nz, not_enough_keys
      ;; El jugador ha recogido todas las llaves
      ;; Elimina las entidades no permanentes
      call entityman_destroy_non_permanent_entities

      ;; Actualiza freeze_screen para que el cambio de nivel sea instantaneo
      ld a, #1
      ld (freeze_screen), a

      ;; Carga el proximo nivel S
      call gameman_score_reward
      call gameman_load_next_level
   not_enough_keys:

   ret
;;

;;
;; Disminuye una vida al jugador. Si aun quedan vidas reinicia el nivel. Si no termina el juego.
;;
gameman_lose_one_life::
   ;; Cambia el sprite del jugador
   ld hl, #_spr_poli_D
   ld ix, #entities
   call animsys_changeSprite

   ;; Resetea los puntos de bonus
   xor a
   ld (bonus_points), a

   ;; Resetea el contador de golpes
   call game_manager_reset_hit_counter

   ;; Renderiza la entidad player para ver el cambio del sprite en pantalla
   call render_entity

   ;; Reproduce sonido
   call game_man_playsound_hit
   
   ;; Congela la pantalla brevemente
   ld a, #LOSE_LIVE_FREEZE
   ld (freeze_screen), a

   ;; Actualiza el color del borde al color de muerte
   ld h, #DEATH_BORDER
   call render_border_color

   ;; Comprueba si es el ultimo nivel, en cuyo caso la partida termina directamente
   ld a, (level_number)
   cp #LAST_LEVEL_INDEX
   jr z, insta_death
      ;; Carga las vidas actuales
      ld a, (remaining_lives)

      ;; Reduce las vidas restantes en 1 y lo guarda
      dec a
      ld (remaining_lives), a

      jr check_lives_remaining
   insta_death:
      ;; Es el ultimo nivel, por lo que muere directamente
      xor a
      ld (remaining_lives), a

   check_lives_remaining:
   ;; Comprueba si se han acabado las vidas
   or a
   jr z, no_lives_remaining

      ;;Actualizamos el sprite de las vidas
      call render_update_lives

      ;; Aun le quedan vidas, por lo que resetea el nivel
      call gameman_reset_level

      ret
      
   no_lives_remaining:
      ;; No le quedan vidas al jugador, por lo que termina la partida
      call gameman_game_over
   ret
;;

;;
;; Devuelve al jugador y los enemigos a la posicion en la que comienzan el nivel
;;
gameman_reset_level_entities_position:
   ;; Reduce el numero del nivel en 1 para obtener la direccion del nivel actual al llamar a gameman_next_level
   ld a, (level_number)
   dec a
   ld (level_number), a
   call gameman_next_level

   ;; Copia HL a IY
   push hl
   pop iy
   .db 0xED, 0xFF
   ;; Situa al jugador
   ld ix, #entities
   ld b, level_player_pos(iy)
   ld c, level_player_pos+1(iy)
   call entityman_set_tile_position

   ;; Desplaza IY hasta los enemigos
   ld bc, #level_enemies
   add iy, bc

   ;; Contador de enemigos
   ld a, #1                   ;; Empieza en 1 porque los enemigos estan despues del jugador y la puerta
   push af

   ;; Coloca los enemigos
   check_next_enemy_position:
   ld h, (iy)
   ld l, 1(iy)

   ld a, h
   cp #0xFF
   jr z, enemies_position_end
      ;; No es el final del vector
      ;; Recupera el indice del siguiente enemigo
      pop af

      ;; Guarda el indice del proximo para posibles proximas iteraciones
      inc a
      push af

      ;; Guarda la posicion en la que se situara
      push hl

      ;; Recupera una referencia a la entidad
      call entityman_get_entity_by_id

      ;; Recupera la posicion y situa el enemigo en el mapa
      pop bc
      call entityman_set_tile_position

      ;; Pasa a la siguiente posicion
      ld bc, #LEVEL_ENEMIES_SIZE
      add iy, bc
      jr check_next_enemy_position
   enemies_position_end:

   ;; Hace un pop para dejar la pila correcta
   pop af

   ret
;;

;;
; Metodo para sumar puntos 
; Dependiendo de si te han golpeado o no sumas una cantidad de puntos
;;
game_manager_update_score::
   ;Cargamos en a el contador de golpes y comprobamos que no sea 0
   ld a,(player_hit_counter)
   or a
   ;Si es 0 le sumamos 1 para que sume los puntos por defecto
   jr nz, hit_counter_not_zero
      inc a
   ;Le pasamos al registro C el valor a sumar y llamamos al metodo, ponemos el registro B a 0
   hit_counter_not_zero:
   ld c,a
   ld b,#0x00
   call game_manager_score_up
   ret

;;
;Recibe en el registro 'BC' la cantidad de puntos a sumar
;;
game_manager_score_up:
   
   call gameman_add_bonus_points

   ld a,(player_score)
   ld h,a
   ld a,(player_score+1)
   ld l,a
   add c
   daa
   ld (player_score+1),a
   ld a,h
   adc b
   daa
   ld (player_score),a
   ret
;;

;;
;; Suma puntos al bonus de puntos
;;    C - Puntos a sumar
;;
gameman_add_bonus_points:
   ;; Suma los puntos de bonus
   ld a, (bonus_points)
   add c
   daa
   ld (bonus_points), a

   ;; Comprueba que no ha llegado al maximo
   cp #BONUS_LIFE
   jr c, not_bonus
      push bc
      call gameman_bonus_life
      pop bc
   not_bonus:

   ret
;;

;;
;;
;;
gameman_bonus_life:
   ;; Reinicia los puntos de bonus
   xor a
   ld (bonus_points), a

   ;; Comprueba que no tiene el maximo de vida
   ld a, (remaining_lives)
   cp #3
   ret z

   ;; Suma una vida
   inc a
   ld (remaining_lives), a

   ;; Muestra las vidas
   call render_update_lives

   ret
;;

;;
;Resetea el contador de gopes
;;
game_manager_reset_hit_counter:

   ld a,#0
   ld (player_hit_counter),a

   ret

;;
;Actualiza el contador de golpes del jugador
;;
game_manager_update_hit_counter:
   ld a,(player_hit_counter)
   or a
   jr z, hit_counter_its_zero
   sub #4
   jr z, hit_counter_its_four
      ld a,(player_hit_counter)
      add a,a
      ld (player_hit_counter),a
      ret
   hit_counter_its_zero:
   ld a,#1
   ld (player_hit_counter),a
   hit_counter_its_four:
   ret

;;
;Actualiza la puntuacion cuando te pasas el nivel
;;
gameman_score_reward::

   ld a,(player_hit_counter)
   or a
   jr z, not_bonus_applied
   sub #4
   jr z, max_bonus_applied
   ld a,(player_hit_counter)
   dec a
   jr z, not_bonus_applied
   ld bc,#0x20
   call game_manager_score_up
   jr end_of_function

   max_bonus_applied:
      ld bc,#0x40
      call game_manager_score_up
      jr end_of_function
   not_bonus_applied:
      ld bc,#0x10
      call game_manager_score_up
   end_of_function:
      call render_show_score_default
   ret

game_man_playsound_key:
   ld l,#1
   ld h,#15
   ld e,#70
   ld d,#0
   ld bc,#0
   ld a,#2
   call cpct_akp_SFXPlay_asm
   ret

game_man_playsound_hit:
   ld l,#1
   ld h,#15
   ld e,#50
   ld d,#0
   ld bc,#0
   ld a,#2
   call cpct_akp_SFXPlay_asm
   ret

game_man_playsound_door:
   ld l,#1
   ld h,#15
   ld e,#90
   ld d,#0
   ld bc,#0
   ld a,#2
   call cpct_akp_SFXPlay_asm
   ret
;;

;;
;; Resetea las variables necesarias al final de la partida
;;
gameman_reset::
   xor a
   ld (level_number), a

   ret
;;
