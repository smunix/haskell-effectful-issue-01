{ inputs, pkgs, ... }:
with pkgs.haskell.lib;
with inputs.nix-utils.lib;
with inputs.nix-filter.lib;

let
  ghc-version = "961";
  hspkgs = fast pkgs.haskell.packages."ghc${ghc-version}" [
    {
      modifiers = [ dontHaddock dontCheck ];
      extension = hfinal: hprevious:
        with hfinal; {
          effectful-core = callCabal2nix "effectful-core"
            (filter { root = "${inputs.effectful}/effectful-core"; }) { };
          effectful-plugin = callCabal2nix "effectful-plugin"
            (filter { root = "${inputs.effectful}/effectful-plugin"; }) { };
          effectful-th = callCabal2nix "effectful-th"
            (filter { root = "${inputs.effectful}/effectful-th"; }) { };
          effectful = callCabal2nix "effectful"
            (filter { root = "${inputs.effectful}/effectful"; }) { };
        };
    }
    {
      modifiers = [ doHaddock dontCheck ];
      extension = hfinal: hprevious:
        with hfinal; {
          graph-effectful = callCabal2nixWithOptions "graph-effectful" (filter {
            root = inputs.self;
            exclude = [ (matchExt "cabal") ];
          }) "" { };
        };
    }
  ];
in with pkgs; {
  env.GREET = "devenv";
  packages = [
    direnv
    nix-direnv-flakes
    git
    hpack
    (with hspkgs;
      ghcWithPackages (p: with p; [ cabal-install graph-effectful base ]))
    toybox
  ];
  scripts.hello.exec = "echo hello from $GREET";
  enterShell = ''
    hello
    git --version
    ${hpack}/bin/hpack -f package.yaml
  '';
  pre-commit.hooks = {
    hpack.enable = true;
    fourmolu.enable = true;
    nixfmt.enable = true;
  };
}
