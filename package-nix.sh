#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$(readlink -f "$0")")"

if [[ ! -x build/src/Release/orca-slicer ]]; then
  echo "Release build not found. Build OrcaSlicer first." >&2
  exit 1
fi

# The current multi-config install script also refers to these libraries from
# build/src, while the compiled Release artifacts live in build/src/Release.
cp -L build/src/Release/libavformat.so* build/src/
cp -L build/src/Release/libavcodec.so* build/src/
cp -L build/src/Release/libavutil.so* build/src/
cp -L build/src/Release/libswresample.so* build/src/
cp -L build/src/Release/libswscale.so* build/src/

nix-shell --run 'cmake --install build --config Release' \
  >build/nix-package-install.log 2>&1 || {
    tail -80 build/nix-package-install.log >&2
    exit 1
  }

nix-build package.nix -o result-nix
