# Nix development shell with CEF

Enter the repository's Nix shell with `nix-shell`. It reuses the native build
dependencies from nixpkgs' OrcaSlicer package and provides nixpkgs' CEF binary
distribution to both the dependency and application CMake configurations.

Build the dependencies and application with:

```sh
./build_linux.sh -d -s
```

The CEF distribution is passed through `SLIC3R_CEF_ROOT`; CMake stages its
`Release` libraries and `Resources` beside the executable and into the install
tree. The wxWidgets CEF backend currently requires an X11 display. The shell
sets `GDK_BACKEND=x11` so the application uses XWayland when started from it.

The normal build remains WebKitGTK-based unless `SLIC3R_USE_CEF=ON` is passed to
both the dependency and application configurations.

CEF uses its own persistent browser profile under wxWidgets' user-local data
directory. The current wxWidgets Chromium backend does not expose the per-view
user-agent override used by OrcaSlicer on other platforms, so CEF sends its
default Chromium user agent. Printer-specific WebKit cookie storage and the
WebKitGTK vue-resize workaround are not applied to CEF.
