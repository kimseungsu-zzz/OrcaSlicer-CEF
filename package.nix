{ pkgs ? import <nixpkgs> {}
, installTree ? ./build/OrcaSlicer
, pythonRuntime ? ./deps/build/OrcaSlicer_dep/usr/local/libpython
}:

let
  app = builtins.path {
    path = installTree;
    name = "orcaslicer-install-tree";
  };
  python = builtins.path {
    path = pythonRuntime;
    name = "orcaslicer-python-runtime";
  };
  runtimeInputs = (pkgs.orca-slicer.buildInputs or []) ++ [
    pkgs.nspr
    pkgs.nss
    pkgs.webkitgtk_4_1
    pkgs.libsoup_3
  ];
  runtimeLibs = pkgs.lib.makeLibraryPath runtimeInputs;
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "orcaslicer-webkit";
  version = "2.5.0-dev";
  dontUnpack = true;
  inputsFrom = [ pkgs.orca-slicer pkgs.nspr pkgs.nss ];
  nativeBuildInputs = [ pkgs.makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin" "$out/resources" "$out/libpython" \
      "$out/share/applications" "$out/share/icons/hicolor"
    cp -a ${app}/bin/. "$out/bin/"
    cp -a ${app}/resources/. "$out/resources/"
    cp -a ${python}/lib/. "$out/libpython/"
    cp ${app}/LICENSE.txt "$out/"

    chmod -R u+w "$out"

    # WebKitGTK is the Linux wxWebView backend for this package. Drop stale
    # CEF payloads left in an install tree that was previously built with CEF.
    rm -rf "$out/bin/Resources" \
      "$out/bin/OrcaSlicer_cef_helper" \
      "$out/bin/chrome-sandbox" \
      "$out/bin/chrome_100_percent.pak" \
      "$out/bin/chrome_200_percent.pak" \
      "$out/bin/icudtl.dat" \
      "$out/bin/libEGL.so" \
      "$out/bin/libGLESv2.so" \
      "$out/bin/libcef.so" \
      "$out/bin/libvk_swiftshader.so" \
      "$out/bin/libvulkan.so.1" \
      "$out/bin/resources.pak" \
      "$out/bin/v8_context_snapshot.bin" \
      "$out/bin/vk_swiftshader_icd.json"

    chmod u+w "$out/bin/orca-slicer"
    mv "$out/bin/orca-slicer" "$out/bin/orca-slicer-unwrapped"
    makeWrapper "$out/bin/orca-slicer-unwrapped" "$out/bin/orca-slicer" \
      --prefix LD_LIBRARY_PATH : "$out/bin:$out/libpython:${runtimeLibs}"

    for size in 32 128 192; do
      install -Dm644 "$out/resources/images/OrcaSlicer_''${size}px.png" \
        "$out/share/icons/hicolor/''${size}x''${size}/apps/OrcaSlicer.png"
    done
    install -Dm644 \
      "$out/resources/applications/com.orcaslicer.OrcaSlicer.desktop" \
      "$out/share/applications/com.orcaslicer.OrcaSlicer.desktop"
    substituteInPlace \
      "$out/share/applications/com.orcaslicer.OrcaSlicer.desktop" \
      --replace-fail 'Exec=orca-slicer' "Exec=$out/bin/orca-slicer" \
      --replace-fail 'Icon=OrcaSlicer' \
        "Icon=$out/share/icons/hicolor/192x192/apps/OrcaSlicer.png"

    runHook postInstall
  '';

  meta = with pkgs.lib; {
    description = "OrcaSlicer with the WebKitGTK webview backend (local build)";
    homepage = "https://github.com/kimseungsu-zzz/OrcaSlicer-CEF";
    license = licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    mainProgram = "orca-slicer";
  };
}
