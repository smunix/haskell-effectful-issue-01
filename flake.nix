{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    nix-utils.url = "github:smunix/nix-utils";
    nix-filter.url = "github:numtide/nix-filter";
    effectful.url = "github:haskell-effectful/effectful";
    effectful.flake = false;
  };

  outputs = { self, nixpkgs, devenv, systems, ... }@inputs:
    let forEachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      devShells = forEachSystem (system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = devenv.lib.mkShell {
            inherit inputs pkgs;
            modules = [ (import ./devenv.nix { inherit inputs pkgs; }) ];
          };
        });
    };
}
