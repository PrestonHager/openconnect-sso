final: prev:
let
  sources = import ./nix/sources.nix;
  # For overlay usage, ensure poetry2nix is available
  poetry2nixOverlay = import "${sources.poetry2nix}/overlay.nix";
  pkgsWithPoetry2nix = if final ? poetry2nix 
    then final
    else final.extend poetry2nixOverlay;
in
{
  inherit (prev.callPackage ./nix { pkgs = pkgsWithPoetry2nix; }) openconnect-sso;
}
