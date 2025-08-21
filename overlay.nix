final: prev:
let
  sources = import ./nix/sources.nix;
  # Ensure poetry2nix is available by applying its overlay if needed
  pkgsWithPoetry2nix = if final ? poetry2nix 
    then final
    else final.extend (import "${sources.poetry2nix}/overlay.nix");
in
{
  inherit (prev.callPackage ./nix { pkgs = pkgsWithPoetry2nix; }) openconnect-sso;
}
