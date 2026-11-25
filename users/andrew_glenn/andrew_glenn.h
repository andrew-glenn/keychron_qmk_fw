// Copyright 2026 Andrew Glenn (@andrew-glenn)
// SPDX-License-Identifier: GPL-2.0-or-later

#pragma once

#include QMK_KEYBOARD_H

enum layers {
    BASE,
    JETBRAINS,
    UTIL,
};

#if defined(LAYOUT_tenkey_27)
#    define LAYOUT_q0(...) LAYOUT_tenkey_27(__VA_ARGS__)
#elif defined(LAYOUT_numpad_6x5)
#    define LAYOUT_q0(...) LAYOUT_numpad_6x5(__VA_ARGS__)
#else
#    error "No known Q0 layout macro found (expected LAYOUT_tenkey_27 or LAYOUT_numpad_6x5)"
#endif

void only_active_keys_leds(uint8_t led_min, uint8_t led_max, uint8_t x, uint8_t y, uint8_t z);
void all_keys_leds(uint8_t led_min, uint8_t led_max, uint8_t x, uint8_t y, uint8_t z);
bool tap_hold(keyrecord_t *record, uint16_t tapkey, uint16_t holdkey);
