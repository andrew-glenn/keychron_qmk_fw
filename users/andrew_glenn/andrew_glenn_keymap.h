// Copyright 2026 Andrew Glenn (@andrew-glenn)
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include "andrew_glenn.h"

/*
 ROTARY | CIRCLE  | TRIANGE | SQUARE | X     |
   M1   | NUMLOCK |  /      |  *     | -     |
   M2   |   7     |  8      |  9     | +     |
   M3   |   4     |  5      |  6     | (nc)  |
   M4   |   1     |  2      |  3     | ENTER |
   M5   |   0     | (nc)    | (dot)  | (nc)  |
*/

// clang-format off
const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [BASE] = LAYOUT_q0(
        KC_MUTE,        KC_NO,               KC_MPRV,              KC_MNXT,               KC_MPLY,
        LSG(KC_V),      KC_NO,               KC_NO,                KC_NO,                 LSFT(KC_F12),
        KC_NO,          KC_NO,               KC_NO,                LSG(KC_H),             LSFT(KC_F11),
        KC_NO,          KC_NO,               KC_NO,                KC_NO,
        KC_NO,          KC_NO,               KC_NO,                KC_NO,                 KC_KP_ENTER,
        TO(JETBRAINS),  KC_NO,                                     KC_NO),
    [JETBRAINS] = LAYOUT_q0(
        KC_MUTE,        KC_TRNS,             KC_TRNS,              KC_TRNS,               KC_TRNS,
        KC_NO,          HYPR(KC_A),          HYPR(KC_KP_SLASH),    HYPR(KC_KP_ASTERISK),  HYPR(KC_KP_MINUS),
        KC_NO,          HYPR(KC_7),          HYPR(KC_8),           HYPR(KC_9),            HYPR(KC_KP_PLUS),
        KC_NO,          HYPR(KC_4),          HYPR(KC_5),           HYPR(KC_6),
        KC_NO,          HYPR(KC_1),          HYPR(KC_2),           HYPR(KC_3),            KC_TRNS,
        TO(UTIL),       HYPR(KC_0),                                HYPR(KC_KP_DOT)),
    [UTIL] = LAYOUT_q0(
        KC_MUTE,        KC_NO,               KC_NO,                KC_NO,                 KC_NO,
        KC_NO,          KC_NO,               KC_NO,                KC_NO,                 KC_NO,
        KC_NO,          KC_NO,               KC_NO,                KC_NO,                 KC_NO,
        KC_NO,          KC_NO,               KC_NO,                KC_NO,
        QK_BOOTLOADER,  KC_NO,               KC_NO,                KC_NO,                 KC_NO,
        TO(BASE),       KC_NO,                                     KC_NO),
};
// clang-format on

#if defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][2] = {
    [BASE]      = {ENCODER_CCW_CW(KC_VOLD, KC_VOLU)},
    [JETBRAINS] = {ENCODER_CCW_CW(KC_VOLD, KC_VOLU)},
    [UTIL]      = {ENCODER_CCW_CW(KC_VOLD, KC_VOLU)},
};
#endif
