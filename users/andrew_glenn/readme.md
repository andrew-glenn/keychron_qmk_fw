# andrew_glenn userspace

One keymap, two Keychron numpads, one repository.

## Hardware

| Location | Board | MCU | Build target | Layout macro |
|---|---|---|---|---|
| home | Keychron Q0 Plus | STM32L432 | `keychron/q0/plus` | `LAYOUT_numpad_6x5` |
| work | Keychron Q0 Max | STM32F401 | `keychron/q0_max/encoder` | `LAYOUT_tenkey_27` |

Both are 27-key, 6x5 matrices with identical key ordering, so one keymap covers
both. Only the layout macro name differs, and that is resolved at compile time.

## Files

```
users/andrew_glenn/
  andrew_glenn_keymap.h   <- THE keymap. Edit this and nothing else.
  andrew_glenn.h          <- layer enum, LAYOUT_q0 wrapper, prototypes
  andrew_glenn.c          <- tap_hold, LED helpers, process_record_user
  rules.mk                <- SRC += andrew_glenn.c, ENCODER_MAP_ENABLE
  build.sh / flash.sh
keyboards/keychron/q0/plus/keymaps/andrew_glenn/keymap.c        <- one-line include
keyboards/keychron/q0_max/encoder/keymaps/andrew_glenn/keymap.c <- identical
```

The per-board `keymap.c` files are one-line includes. QMK requires a `keymap.c`
per board; the content lives here.

Board differences key off which layout macro the tree defines, not a board name,
so this survives upstream board renames:

```c
#if   defined(LAYOUT_tenkey_27)   // Q0 Max
#elif defined(LAYOUT_numpad_6x5)  // Q0 Plus
#else #error
#endif
```

## Building

```bash
./users/andrew_glenn/build.sh         # both
./users/andrew_glenn/build.sh plus    # home only
./users/andrew_glenn/build.sh max     # work only
```

Or directly:

```bash
make keychron/q0/plus:andrew_glenn
make keychron/q0_max/encoder:andrew_glenn
```

The toolchain must be the keg-only `arm-gcc-bin@14`:

```bash
brew install osx-cross/arm/arm-gcc-bin@14
export PATH="/opt/homebrew/opt/arm-gcc-bin@14/bin:$PATH"
```

Homebrew-core's `arm-none-eabi-gcc` is **freestanding** — no newlib — and fails
with `fatal error: stdint.h: No such file or directory`. `build.sh` sets `PATH`
itself and checks for this.

`build.sh` also unsets `QMK_USERSPACE`. An external userspace would silently take
precedence over the in-tree keymap here, which is a confusing way to lose edits.

Expected sizes: Q0 Plus ~44544 bytes, Q0 Max ~80412. Note `size` reports less than
the file length (48108 vs 80412 for the Max) — that is QMK's standard STM32F4 flash
layout: sector 0 init code, sector 1 emulated EEPROM, firmware from `0x08008000`.
The 32K gap is zero-fill, not bloat.

## Flashing

```bash
./users/andrew_glenn/flash.sh         # auto-detect which board is attached
./users/andrew_glenn/flash.sh plus
./users/andrew_glenn/flash.sh max
```

Both boards expose the **same** DFU id (`0483:df11`) — that is the STM32 ROM
bootloader, which knows nothing about the keyboard — so identification uses:

1. **HID mode** — the running keyboard's USB PID: `0x0131` Plus, `0x0800` Max
   (both VID `0x3434`). Unambiguous, but needs working firmware.
2. **DFU mode** — the bootloader's own flash geometry, which a chip cannot
   misreport. STM32F401 (Max) gives non-uniform sectors
   `04*016Kg,01*064Kg,01*128Kg`; STM32L432 (Plus) gives uniform 2K pages.

If neither gives a positive match the script **aborts instead of picking one**.
Flashing an image built for the wrong MCU writes and verifies perfectly, then fails
to boot — indistinguishable from a dead board. That is how an afternoon got lost.

The script also refuses to flash a `.bin` older than `andrew_glenn_keymap.h`, so a
forgotten rebuild cannot masquerade as a successful flash.

Enter DFU via the `UTIL` layer: `BASE` -> `TO(JETBRAINS)` -> `TO(UTIL)` (all keys
red), then the bottom-left key (`QK_BOOTLOADER`).

Plug the keyboard **directly into the machine**. DFU re-enumeration through a dock
or hub chain drops the device mid-flash.

> The Plus DFU-geometry branch is **unverified** — only the Max has been seen in
> DFU. If `flash.sh` aborts with an unrecognised flash map it prints the actual
> string; add it to `detect_via_dfu`.

## Q0 Max notes

The Q0 Max is not in upstream QMK — Keychron maintains it only in their own fork
(`github.com/Keychron/qmk_firmware`, branch `wireless_playground`), which is pinned
to a 2023q4 QMK base and ships only their boards. It was ported into this tree
**wired only**, which required:

* the SNLED27351 **SPI** LED driver — upstream only had I2C. Taken from QMK
  PR #25319, closed unmerged under a hold on wireless boards, then updated to the
  current GPIO names (`setPinOutput` -> `gpio_set_pin_output`).
* dropping the wireless stack. It is all behind `LK_WIRELESS_ENABLE`, never defined
  once the fork's `wireless.mk` include is gone, so it compiles out.
* renaming 78 LED position macros (`J_2` -> `CB10_CA2`); upstream renamed these when
  it adopted the driver. Hex values verified identical.
* `encoder_cb_init` dropped — the encoder now uses upstream's polling path instead
  of Keychron's interrupt callbacks.

> **Not yet hardware-verified.** The Q0 Max build compiles and passes lint, but
> per-key RGB over SPI, the key-to-LED mapping, and encoder behaviour all still need
> checking on the physical board. Keychron's fork remains the known-good reference
> if something is wrong.

Wireless would need the radio stack ported too (~8.7k LOC under
`keyboards/keychron/common/`, plus ~79 lines of core hooks in `host.c`, `report.c`
and `chibios.c`). Upstream still has the `drivers/bluetooth` hook API, so it is
possible — but the board is used wired, so it was not done.
