{
  description = "fabiosouzadev's Neovim flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awesome-neovim-plugins.url = "github:m15a/flake-awesome-neovim-plugins";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };

    ## pluginsFromGithub
    avante-src = {
      url = "github:yetone/avante.nvim";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    neovim-nightly-overlay,
    awesome-neovim-plugins,
    nixneovimplugins,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      system = "x86_64-linux";
      overlayNightlyNeovim = prev: final: {
        neovim = neovim-nightly-overlay.packages.${system}.neovim;
        vimPlugins =
          final.vimPlugins
          // import ./plugins/pluginsFromGithub.nix {
            inherit inputs;
            pkgs = prev;
          };
      };
      overlayMyCustomNeovim = prev: final: {
        myCustomNeovim = import ./mkCustomNeovim.nix {pkgs = prev;};
      };

      pkgs = import nixpkgs {
        system = system;
        overlays = [overlayNightlyNeovim awesome-neovim-plugins.overlays.default nixneovimplugins.overlays.default overlayMyCustomNeovim];
      };
    in {
      packages = rec {
        nvim = pkgs.myCustomNeovim;
        default = nvim;
      };

      apps = rec {
        nvim = flake-utils.lib.mkApp {drv = self.packages.${system}.nvim;};
        default = nvim;
      };
    });
}
