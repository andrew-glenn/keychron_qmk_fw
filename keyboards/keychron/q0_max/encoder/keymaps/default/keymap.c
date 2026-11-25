// Copyright 2024 @ Keychron (https://www.keychron.com)
// SPDX-License-Identifier: GPL-2.0-or-later

#include QMK_KEYBOARD_H

// clang-format off

enum layers {
    BASE,
    FUNC
};

const uint16_t PROGMEM keymaps[][MATRIX_ROWS][MATRIX_COLS] = {
    [BASE] = LAYOUT_tenkey_27(
        KC_MUTE, KC_ESC,   KC_DEL,  KC_TAB,   KC_BSPC,
        _______, KC_NUM,   KC_PSLS, KC_PAST,  KC_PMNS,
        _______, KC_P7,    KC_P8,   KC_P9,    KC_PPLS,
        _______, KC_P4,    KC_P5,   KC_P6,
        _______, KC_P1,    KC_P2,   KC_P3,    KC_PENT,
        MO(FUNC), KC_P0,            KC_PDOT),

    [FUNC] = LAYOUT_tenkey_27(
        RM_TOGG, _______,  KC_MUTE, KC_VOLD,  KC_VOLU,
        _______, RM_NEXT,  RM_VALU, RM_HUEU,  _______,
        _______, RM_PREV,  RM_VALD, RM_HUED,  _______,
        _______, RM_SATU,  RM_SPDU, KC_MPRV,
        _______, RM_SATD,  RM_SPDD, KC_MPLY,  _______,
        _______, RM_TOGG,           KC_MNXT),
};

#if defined(ENCODER_MAP_ENABLE)
const uint16_t PROGMEM encoder_map[][NUM_ENCODERS][NUM_DIRECTIONS] = {
    [BASE] = { ENCODER_CCW_CW(KC_VOLD, KC_VOLU) },
    [FUNC] = { ENCODER_CCW_CW(RM_VALD, RM_VALU) },
};
#endif // ENCODER_MAP_ENABLE
