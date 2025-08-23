{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: (flake-utils.lib.eachDefaultSystem (
    system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      openconnect-sso = (import ./nix { inherit pkgs; }).openconnect-sso;
    in
    {
      packages = { inherit openconnect-sso; };
      defaultPackage = openconnect-sso;
      devShell = (import ./nix { inherit pkgs; }).shell;
    }
  ) // {
      overlay = import ./overlay.nix;
  });
}
