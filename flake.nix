{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: (flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      overlay = import ./overlay.nix;
      pkgsWithOverlay = pkgs.extend overlay;
    in
    {
      packages = { inherit (pkgsWithOverlay) openconnect-sso; };
      defaultPackage = pkgsWithOverlay.openconnect-sso;
    }
  ) // {
      overlay = import ./overlay.nix;
  });
}
