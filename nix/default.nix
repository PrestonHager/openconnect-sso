{ sources ? import ./sources.nix
, pkgs ? import <nixpkgs> {}
}:

let
  # Ensure poetry2nix is available by applying the overlay
  poetry2nixOverlay = import "${sources.poetry2nix}/overlay.nix";
  pkgsWithPoetry2nix = pkgs.extend poetry2nixOverlay;

  qtLibsFor = with pkgsWithPoetry2nix.lib; dep:
    let
      qtbase = head (filter (d: getName d.name == "qtbase") dep.nativeBuildInputs);
      version = splitVersion qtbase.version;
      majorMinor = concatStrings (take 2 version);
    in
    pkgsWithPoetry2nix."libsForQt${majorMinor}";

  inherit (qtLibsFor pkgsWithPoetry2nix.python3Packages.pyqt5) callPackage;
  pythonPackages = pkgsWithPoetry2nix.python3Packages;

  # Use poetry2nix approach with proper error handling
  openconnect-sso = callPackage ./openconnect-sso.nix {
    inherit (pkgsWithPoetry2nix) python3Packages poetry2nix qt5;
  };

  shell = pkgsWithPoetry2nix.mkShell {
    buildInputs = with pkgsWithPoetry2nix; [
      # For Makefile
      gawk
      git
      gnumake
      which
      niv # Dependency manager for Nix expressions
      nixpkgs-fmt # To format Nix source files
      poetry # Dependency manager for Python
    ] ++ (
      with pythonPackages; [
        pre-commit # To check coding style during commit
      ]
    ) ++ (
      # only install those dependencies in the shell env which are meant to be
      # visible in the environment after installation of the actual package.
      # Specifying `inputsFrom = [ openconnect-sso ]` introduces weird errors as
      # it brings transitive dependencies into scope.
      openconnect-sso.propagatedBuildInputs
    );
    shellHook = ''
      # Python wheels are ZIP files which cannot contain timestamps prior to
      # 1980
      export SOURCE_DATE_EPOCH=315532800
      # Helper for tests to find Qt libraries
      export NIX_QTWRAPPER=${qtwrapper}/bin/wrap-qt

      echo "Run 'make help' for available commands"
    '';
  };

  niv = if pkgsWithPoetry2nix ? niv then pkgsWithPoetry2nix.nim else pkgsWithPoetry2nix.haskellPackages.niv;

  qtwrapper = pkgsWithPoetry2nix.stdenv.mkDerivation {
    name = "qtwrapper";
    dontWrapQtApps = true;
    makeWrapperArgs = [
      "\${qtWrapperArgs[@]}"
    ];
    unpackPhase = ":";
    nativeBuildInputs = [ pkgsWithPoetry2nix.qt5.wrapQtAppsHook ];
    installPhase = ''
      mkdir -p $out/bin
      cat > $out/bin/wrap-qt <<'EOF'
      #!/bin/sh
      "$@"
      EOF
      chmod +x $out/bin/wrap-qt
      wrapQtApp $out/bin/wrap-qt
    '';
  };
in
{
  inherit openconnect-sso shell;
}
