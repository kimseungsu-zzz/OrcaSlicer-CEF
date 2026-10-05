{ pkgs ? import <nixpkgs> { } }:

let
  cef = pkgs.cef-binary;
in
pkgs.mkShell {
  # Reuse the native build dependencies from nixpkgs' OrcaSlicer package, while
  # substituting a CEF-enabled wxWidgets build from this repository's deps.
  inputsFrom = [ pkgs.orca-slicer ];
  nativeBuildInputs = [ pkgs.cmake pkgs.git pkgs.ninja pkgs.pkg-config pkgs.wayland pkgs.wayland-scanner ];
  packages = [ cef pkgs.libdatachannel ];

  CEF_ROOT = "${cef}";
  DEPS_EXTRA_BUILD_ARGS = "-DSLIC3R_USE_CEF=ON -DSLIC3R_CEF_ROOT=${cef}";
  ORCA_EXTRA_BUILD_ARGS = "-DSLIC3R_USE_CEF=ON -DSLIC3R_CEF_ROOT=${cef}";

  shellHook = ''
    # wxWebViewChromium currently embeds CEF through X11 on Linux.
    export GDK_BACKEND=x11
  '';
}
