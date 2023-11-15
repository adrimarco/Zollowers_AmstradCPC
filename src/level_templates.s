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
.include "level_templates.h.s"

;; Level headers
    .include "levels/level_01.h.s"
    .include "levels/level_02.h.s"
    .include "levels/level_03.h.s"
    .include "levels/level_04.h.s"
    .include "levels/level_05.h.s"
    .include "levels/level_06.h.s"
    .include "levels/level_07.h.s"
    .include "levels/level_08.h.s"
    .include "levels/level_09.h.s"
    .include "levels/level_10.h.s"
    .include "levels/level_11.h.s"
    .include "levels/level_12.h.s"
    .include "levels/level_13.h.s"
    .include "levels/level_14.h.s"
    .include "levels/level_15.h.s"
    .include "levels/level_final.h.s"
;;

level_01::
    .dw _level_01                   ;TileY  TileX
    .dw 0x0809                      ;8      9       Player
    .dw 0x1009                      ;16     9       Puerta
    .dw 0x0011                      ;0      17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0411                      ;4      17      Llave
    .dw 0x0402                      ;4      2
    .dw 0x0C00                      ;12     0
    .dw 0x0C13                      ;12     19
    .db 0xFF                        ;Fin de las llaves

level_02::
    .dw _level_02                   ;TileY  TileX
    .dw 0x080B                      ;8      11      Player
    .dw 0x0811                      ;8      17      Puerta
    .dw 0x0011                      ;0      17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0406                      ;4      6       Llave
    .dw 0x0800                      ;8      0
    .dw 0x0C11                      ;12     17
    .dw 0x1005                      ;16     5
    .dw 0x000E                      ;0      14
    .db 0xFF                        ;Fin de las llaves

level_03::
    .dw _level_03                   ;TileY  TileX
    .dw 0x0008                      ;0      8       Player
    .dw 0x0C01                      ;12     1       Puerta
    .dw 0x100D                      ;16     13      Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x1013                      ;16     19      Llave
    .dw 0x0000                      ;0      0
    .dw 0x0413                      ;4      19
    .dw 0x0C07                      ;12     7
    .dw 0x1008                      ;16     8
    .dw 0x0408                      ;4      8
    .db 0xFF                        ;Fin de las llaves

level_04::
    .dw _level_04                   ;TileY  TileX
    .dw 0x0200                      ;2       0      Player
    .dw 0x1009                      ;16      9      Puerta
    .dw 0x0E13                      ;14     19      Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo    .db 0xFF
    .db 0xFF
    .dw 0x0206                      ;2       6      Llave
    .dw 0x000D                      ;0      13      Llave
    .dw 0x0C08                      ;12      8      Llave
    .dw 0x0E00                      ;14      0      Llave
    .dw 0x0A11                      ;10     17      Llave
    .db 0xFF                        ;Fin de las llaves

level_05::
    .dw _level_05                   ;TileY  TileX
    .dw 0x0E0B                      ;14     11      Player
    .dw 0x0A0F                      ;10     15      Puerta
    .dw 0x0001                      ;0      1       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x060F                      ;6      15      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0406                      ;4      6       Llave
    .dw 0x0000                      ;0      0
    .dw 0x1001                      ;16     1
    .dw 0x0213                      ;2      19
    .dw 0x1011                      ;16     17
    .db 0xFF                        ;Fin de las llaves

level_06::
    .dw _level_06                   ;TileY  TileX
    .dw 0x0A0F                      ;10     15      Player
    .dw 0x0A06                      ;10     6       Puerta
    .dw 0x0E10                      ;14     16      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0008                      ;0      8       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0010                      ;0      16      Llave
    .dw 0x0003                      ;0      3
    .dw 0x0C02                      ;12     2
    .dw 0x0E06                      ;14     6
    .dw 0x0411                      ;4      17
    .dw 0x0808                      ;8      8
    .dw 0x0E0F                      ;14     15
    .db 0xFF                        ;Fin de las llaves

level_07::
    .dw _level_07                   ;TileY  TileX
    .dw 0x0607                      ;6      7       Player
    .dw 0x1013                      ;16     19      Puerta
    .dw 0x0E11                      ;14     17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0206                      ;2      6       Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x100C                      ;16     12      Llave
    .dw 0x0C02                      ;12     2
    .dw 0x0600                      ;6      0
    .dw 0x0003                      ;0      3
    .dw 0x0210                      ;2      16
    .dw 0x0A13                      ;10     19
    .db 0xFF                        ;Fin de las llaves

level_08::
    .dw _level_08                   ;TileY  TileX
    .dw 0x0000                      ;0      0       Player
    .dw 0x0C06                      ;12     6       Puerta
    .dw 0x0011                      ;0      17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0E12                      ;14     18      Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0A0D                      ;10     13      Llave
    .dw 0x0E00                      ;14     0
    .dw 0x1007                      ;16     7
    .dw 0x020B                      ;12     11
    .dw 0x0813                      ;8      19
    .db 0xFF                        ;Fin de las llaves

level_09::
    .dw _level_09                   ;TileY  TileX
    .dw 0x0411                      ;4      17      Player
    .dw 0x0C05                      ;12     5       Puerta
    .dw 0x000C                      ;0      12      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x1002                      ;16     2       Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0403                      ;4      3       Llave
    .dw 0x0A0D                      ;10     13
    .dw 0x0C08                      ;12     8
    .dw 0x1013                      ;16     19
    .dw 0x0409                      ;4      9
    .db 0xFF                        ;Fin de las llaves

level_10::
    .dw _level_10                   ;TileY  TileX
    .dw 0x0A06                      ;10     6       Player
    .dw 0x0A05                      ;10     5       Puerta
    .dw 0x0A13                      ;10     19      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0E0B                      ;14     11      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x1001                      ;16     1       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0209                      ;2      9       Llave
    .dw 0x0613                      ;6      19
    .dw 0x1012                      ;16     18
    .dw 0x0A0A                      ;10     10
    .dw 0x0B00                      ;11     0
    .db 0xFF                        ;Fin de las llaves

level_11::
    .dw _level_11                   ;TileY  TileX
    .dw 0x0800                      ;8      0       Player
    .dw 0x0009                      ;0      9       Puerta
    .dw 0x060F                      ;6      15      Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .dw 0x1007                      ;16     7       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0C11                      ;12     17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0805                      ;8      5       Llave
    .dw 0x0002                      ;0      2
    .dw 0x0C0C                      ;12     12
    .dw 0x0A11                      ;10     17
    .dw 0x0C09                      ;12     9
    .dw 0x040D                      ;4      13
    .db 0xFF                        ;Fin de las llaves

level_12::
    .dw _level_12                   ;TileY  TileX
    .dw 0x080E                      ;8      14      Player
    .dw 0x0E08                      ;14     8       Puerta
    .dw 0x0C00                      ;12     0       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x020D                      ;2      13      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0C13                      ;12     19      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0200                      ;2      0       Llave
    .dw 0x0A13                      ;10     19
    .dw 0x020A                      ;2      10
    .dw 0x0E02                      ;14     2
    .dw 0x0E0D                      ;14     13
    .dw 0x0805                      ;8      5
    .db 0xFF                        ;Fin de las llaves

level_13::
    .dw _level_13                   ;TileY  TileX
    .dw 0x1000                      ;16     0       Player
    .dw 0x1013                      ;16     19      Puerta
    .dw 0x0011                      ;0      17      Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .dw 0x0004                      ;0      4       Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0001                      ;0      1       Llave
    .dw 0x0012                      ;0      18
    .dw 0x040B                      ;4      11
    .dw 0x0812                      ;8      18
    .dw 0x0801                      ;8      1
    .dw 0x0C0B                      ;12     11
    .db 0xFF                        ;Fin de las llaves

level_14::
    .dw _level_14                   ;TileY  TileX
    .dw 0x080B                      ;8      11      Player
    .dw 0x0007                      ;0      7       Puerta
    .dw 0x0001                      ;0      1       Enemigo
    .db ENEMY_TYPE_CHASER_FAST      ;               Tipo del enemigo
    .dw 0x0412                      ;4      18      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x100B                      ;16     11      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x020D                      ;2      13      Llave
    .dw 0x0402                      ;4      2
    .dw 0x1002                      ;16     2
    .dw 0x1013                      ;16     19
    .dw 0x0C09                      ;12     9
    .db 0xFF                        ;Fin de las llaves

level_15::
    .dw _level_15                   ;TileY  TileX
    .dw 0x0A0C                      ;10     12      Player
    .dw 0x0005                      ;0      5       Puerta
    .dw 0x0601                      ;6      1       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x000E                      ;0      14      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x1004                      ;16     4       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0C04                      ;12     4       Llave
    .dw 0x1013                      ;16     19
    .dw 0x0203                      ;2      3
    .dw 0x060B                      ;6      11
    .dw 0x0213                      ;2      19
    .db 0xFF                        ;Fin de las llaves

level_final::
    .dw _level_final                ;TileY  TileX
    .dw 0x080F                      ;8      15      Player
    .dw 0x1000                      ;16     0       Puerta
    .dw 0x0011                      ;0      17      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0010                      ;0      16      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x1001                      ;16     1       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x1002                      ;16     2       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0200                      ;2      0       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0400                      ;4      0       Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0E13                      ;14     19      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .dw 0x0C13                      ;12     19      Enemigo
    .db ENEMY_TYPE_CHASER_SLOW      ;               Tipo del enemigo
    .db 0xFF
    .dw 0x0013                      ;0      19      Llave
    .db 0xFF                        ;Fin de las llaves