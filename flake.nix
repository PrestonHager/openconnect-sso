{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, flake-utils, nixpkgs }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        openconnect-sso = (import ./nix { inherit pkgs; }).openconnect-sso;
      in {
        packages = {
          inherit openconnect-sso;
          default = openconnect-sso;
        };

        # For nix run support
        apps = {
          openconnect-sso = {
            type = "app";
            program = "${openconnect-sso.out}/bin/openconnect-sso";
          };
          default = self.apps.${system}.openconnect-sso;
        };

        # Development shell
        devShells.default = (import ./nix { inherit pkgs; }).shell;
      }) // {
        # NixOS overlay
        overlays.default = import ./overlay.nix;
        # Legacy support
        overlay = self.overlays.default;
      });
}
