// Copyright 2026 Andrew Glenn (@andrew-glenn)
// SPDX-License-Identifier: GPL-2.0-or-later

#include "andrew_glenn.h"

void only_active_keys_leds(uint8_t led_min, uint8_t led_max, uint8_t x, uint8_t y, uint8_t z) {
    uint8_t layer = get_highest_layer(layer_state);

    for (uint8_t row = 0; row < MATRIX_ROWS; ++row) {
        for (uint8_t col = 0; col < MATRIX_COLS; ++col) {
            uint8_t index = g_led_config.matrix_co[row][col];

            if (index >= led_min && index < led_max) {
                if (index != NO_LED && keymap_key_to_keycode(layer, (keypos_t){col, row}) > KC_TRNS) {
                    rgb_matrix_set_color(index, x, y, z);
                }
            }
        }
    }
}

void all_keys_leds(uint8_t led_min, uint8_t led_max, uint8_t x, uint8_t y, uint8_t z) {
    for (uint8_t index = led_min; index < led_max; ++index) {
        rgb_matrix_set_color(index, x, y, z);
    }
}

bool rgb_matrix_indicators_advanced_user(uint8_t led_min, uint8_t led_max) {
    switch (get_highest_layer(layer_state)) {
        case BASE:
            only_active_keys_leds(led_min, led_max, 0, 255, 255);
            break;
        case JETBRAINS:
            only_active_keys_leds(led_min, led_max, 51, 255, 51);
            break;
        case UTIL:
            all_keys_leds(led_min, led_max, 255, 0, 0);
            break;
        default:
            break;
    }
    return false;
}

bool tap_hold(keyrecord_t *record, uint16_t tapkey, uint16_t holdkey) {
    static uint16_t key_timer;
    if (record->event.pressed) {
        key_timer = timer_read();
    } else {
        if (timer_elapsed(key_timer) < TAPPING_TERM) {
            tap_code16(tapkey);
        } else {
            tap_code16(holdkey);
        }
    }
    return false;
}

bool process_record_user(uint16_t keycode, keyrecord_t *record) {
    switch (keycode) {
        case KC_MUTE:
            return tap_hold(record, LSG(KC_SPACE), KC_MUTE);
        case KC_KP_ENTER:
            if (get_highest_layer(layer_state) == BASE) {
                return tap_hold(record, S(KC_F10), KC_Q);
            }
            break;
    }
    return true;
}
