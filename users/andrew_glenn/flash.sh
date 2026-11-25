#!/usr/bin/env bash
# Flash whichever Keychron numpad is attached.
#
# Both boards expose the SAME DFU id (0483:df11) because that is the STM32 ROM
# bootloader, which knows nothing about the keyboard. So identification uses, in
# order of reliability:
#
#   1. HID mode  -- the running keyboard's USB PID (0x0131 Plus / 0x0800 Max).
#                   Unambiguous. Requires working firmware.
#   2. DFU mode  -- the bootloader's own flash geometry string. STM32F401 (Max)
#                   reports non-uniform sectors; STM32L432 (Plus) reports uniform
#                   2K pages. A chip cannot misreport this.
#
# If neither yields a positive match the script ABORTS rather than picking one.
# Flashing an image built for the wrong MCU writes and verifies cleanly, then
# fails to boot -- it looks exactly like a dead board. Never guess.
#
# Usage:  ./flash.sh [plus|max]     (no argument auto-detects)

set -euo pipefail

KEYMAP=andrew_glenn
QMK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

PLUS_BIN="$QMK_ROOT/keychron_q0_plus_${KEYMAP}.bin"
MAX_BIN="$QMK_ROOT/keychron_q0_max_encoder_${KEYMAP}.bin"
KEYMAP_SRC="$QMK_ROOT/users/$KEYMAP/andrew_glenn_keymap.h"

die() { echo "error: $*" >&2; exit 1; }

command -v dfu-util >/dev/null || die "dfu-util not found (brew install dfu-util)"

# ---------------------------------------------------------------- detection ---

detect_via_hid() {
    local ioreg
    ioreg="$(ioreg -p IOUSB -l -w 0 2>/dev/null || true)"
    # ioreg prints decimal: 0x3434 = 13364, 0x0131 = 305, 0x0800 = 2048.
    if grep -q '"idVendor" = 13364' <<<"$ioreg"; then
        if grep -q '"idProduct" = 305' <<<"$ioreg"; then echo plus; return 0; fi
        if grep -q '"idProduct" = 2048' <<<"$ioreg"; then echo max; return 0; fi
    fi
    return 1
}

detect_via_dfu() {
    local map
    map="$(dfu-util -l 2>/dev/null | grep -o 'name="@Internal Flash[^"]*"' | head -1 || true)"
    [[ -z "$map" ]] && return 1
    DFU_MAP="$map"
    # STM32F401 (Q0 Max): non-uniform sectors, e.g. 04*016Kg,01*064Kg,01*128Kg
    if grep -qE '[0-9]+\*[0-9]+Kg,[0-9]+\*[0-9]+Kg' <<<"$map"; then echo max; return 0; fi
    # STM32L432 (Q0 Plus): uniform 2K pages, e.g. 128*002Kg
    if grep -qE '[0-9]+\*0*2Kg' <<<"$map" && ! grep -q ',' <<<"$map"; then echo plus; return 0; fi
    return 1
}

VARIANT="${1:-}"
HOW="explicit argument"

if [[ -z "$VARIANT" ]]; then
    if VARIANT="$(detect_via_hid)"; then
        HOW="running keyboard USB PID"
    elif VARIANT="$(detect_via_dfu)"; then
        HOW="DFU flash geometry (${DFU_MAP})"
    else
        echo "Could not identify the attached keyboard." >&2
        echo >&2
        if dfu-util -l 2>/dev/null | grep -q '0483:df11'; then
            echo "A DFU device is present but its flash map was not recognised:" >&2
            echo "  ${DFU_MAP:-<none reported>}" >&2
            echo "Pass the variant explicitly: $0 plus | max" >&2
        else
            echo "No Keychron keyboard and no DFU device (0483:df11) on the bus." >&2
            echo "  - plug the keyboard DIRECTLY into the machine, not a dock or hub" >&2
            echo "  - for DFU: BASE -> TO(JETBRAINS) -> TO(UTIL), then bottom-left key" >&2
        fi
        exit 1
    fi
fi

case "$VARIANT" in
    plus) BIN="$PLUS_BIN"; LABEL="Q0 Plus (home, STM32L432)" ;;
    max)  BIN="$MAX_BIN";  LABEL="Q0 Max (work, STM32F401)" ;;
    *)    die "unknown variant '$VARIANT' (expected plus or max)" ;;
esac

[[ -f "$BIN" ]] || die "firmware not built: $(basename "$BIN")  -- run ./build.sh $VARIANT"

# Stale-artifact guard: the thing that makes a "successful" flash a no-op.
if [[ -f "$KEYMAP_SRC" && "$KEYMAP_SRC" -nt "$BIN" ]]; then
    die "$(basename "$BIN") is older than the keymap source -- run ./build.sh $VARIANT"
fi

echo "==> $LABEL"
echo "    detected by: $HOW"
echo "    firmware:    $(basename "$BIN") ($(wc -c <"$BIN" | tr -d ' ') bytes)"

# ------------------------------------------------------------------- flashing ---

if ! dfu-util -l 2>/dev/null | grep -q '0483:df11'; then
    echo
    echo "    Keyboard is running, not in DFU. Enter the bootloader now:"
    echo "      BASE -> TO(JETBRAINS) -> TO(UTIL)  (all keys red), bottom-left key"
    echo -n "    waiting for DFU "
    for _ in $(seq 60); do
        if dfu-util -l 2>/dev/null | grep -q '0483:df11'; then echo " ok"; break; fi
        echo -n .
        sleep 1
    done
    dfu-util -l 2>/dev/null | grep -q '0483:df11' || { echo; die "timed out waiting for DFU"; }

    # Re-confirm identity now that we can read the flash map; catches the case
    # where detection came from HID but a different board entered DFU.
    if CONFIRM="$(detect_via_dfu)"; then
        [[ "$CONFIRM" == "$VARIANT" ]] || die "DFU device is '$CONFIRM', expected '$VARIANT' -- refusing to flash"
    fi
fi

echo
dfu-util -a 0 -d 0483:df11 -s 0x08000000:leave -D "$BIN"

echo
echo "==> flashed. Power-cycle if it does not re-enumerate on its own."
echo "    Verify the keyboard itself, not this exit code:"
echo "      - does it type?"
echo "      - UTIL layer lights all keys red?"
echo "      - QK_BOOTLOADER re-enters DFU?"
