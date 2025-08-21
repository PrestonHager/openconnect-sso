{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, flake-utils, nixpkgs }: (flake-utils.lib.eachDefaultSystem (
    system:
    let
      sources = import ./nix/sources.nix;
      pkgs = nixpkgs.legacyPackages.${system}.extend (import "${sources.poetry2nix}/overlay.nix");
      openconnect-sso = (import ./nix { inherit pkgs; }).openconnect-sso;
    in
    {
      packages = { inherit openconnect-sso; };
      defaultPackage = openconnect-sso;
    }
  ) // {
      overlay = import ./overlay.nix;
  });
}
