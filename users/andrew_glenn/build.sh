#!/usr/bin/env bash
# Build both Keychron numpads from this tree.
#
# Everything lives in this one repository: the shared keymap in
# users/andrew_glenn/, and both board definitions under keyboards/keychron/.
# No QMK_USERSPACE and no second source tree are involved.
#
# Usage:  ./build.sh [plus|max]     (no argument builds both)

set -euo pipefail

TOOLCHAIN=/opt/homebrew/opt/arm-gcc-bin@14/bin
KEYMAP=andrew_glenn

# Repo root, derived from this script's location (users/andrew_glenn/build.sh).
QMK_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

export PATH="$TOOLCHAIN:$PATH"

# An external userspace would silently take precedence over the in-tree keymap.
unset QMK_USERSPACE

if [[ ! -x "$TOOLCHAIN/arm-none-eabi-gcc" ]]; then
    echo "error: $TOOLCHAIN/arm-none-eabi-gcc not found" >&2
    echo "       brew install osx-cross/arm/arm-gcc-bin@14" >&2
    echo "       (homebrew-core's arm-none-eabi-gcc lacks newlib and will not work)" >&2
    exit 1
fi

if [[ ! -f "$QMK_ROOT/users/$KEYMAP/andrew_glenn_keymap.h" ]]; then
    echo "error: not inside the expected repo layout: $QMK_ROOT" >&2
    exit 1
fi

build() {
    local target="$1" name="$2"
    echo "==> $name"
    ( cd "$QMK_ROOT" && make "$target:$KEYMAP" )
}

case "${1:-both}" in
    plus) build keychron/q0/plus        "Q0 Plus (home, STM32L432)" ;;
    max)  build keychron/q0_max/encoder "Q0 Max (work, STM32F401, wired)" ;;
    both)
        build keychron/q0/plus        "Q0 Plus (home, STM32L432)"
        build keychron/q0_max/encoder "Q0 Max (work, STM32F401, wired)"
        ;;
    *) echo "usage: $0 [plus|max]" >&2; exit 2 ;;
esac

echo
echo "==> artifacts"
ls -l "$QMK_ROOT"/keychron_q0*_"$KEYMAP".bin 2>/dev/null | awk '{print "    "$5" bytes  "$9}'
