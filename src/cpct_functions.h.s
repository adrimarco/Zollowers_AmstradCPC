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
;; Funciones de CPCTelera
;;

;; Funciones
    .globl cpct_memset_asm
    .globl cpct_memcpy_asm
    .globl cpct_disableFirmware_asm
    .globl cpct_getScreenPtr_asm
    .globl cpct_setDrawCharM0_asm
    .globl cpct_drawCharM0_asm
    .globl cpct_drawStringM0_asm
    .globl cpct_setPalette_asm
    .globl cpct_setPALColour_asm
    .globl cpct_setVideoMode_asm
    .globl cpct_getRandom_mxor_u8_asm
    .globl cpct_waitVSYNC_asm
    .globl cpct_px2byteM0_asm
    .globl cpct_scanKeyboard_f_asm
    .globl cpct_isKeyPressed_asm
    .globl cpct_isAnyKeyPressed_f_asm
    .globl cpct_drawSprite_asm
    .globl cpct_drawSolidBox_asm
    .globl cpct_etm_setDrawTilemap4x8_ag_asm
    .globl cpct_etm_drawTilemap4x8_ag_asm
    .globl cpct_scanKeyboard_if_asm
    .globl cpct_akp_musicPlay_asm
    .globl cpct_setSeed_lcg_u8_asm
    .globl cpct_getRandom_lcg_u8_asm
    .globl cpct_zx7b_decrunch_s_asm
    .globl cpct_akp_musicInit_asm
    .globl cpct_akp_SFXInit_asm
    .globl cpct_akp_SFXPlay_asm
;;