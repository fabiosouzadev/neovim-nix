{
  description = "@fabiosouzadev's Neovim flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    awesome-neovim-plugins.url = "github:m15a/flake-awesome-neovim-plugins";
    nixneovimplugins.url = "github:jooooscha/nixpkgs-vim-extra-plugins";
  };

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  outputs = {
    self,
    nixpkgs,
    neovim-nightly-overlay,
    awesome-neovim-plugins,
    nixneovimplugins,
  }: let
    overlayFlakeInputs = prev: final: {
      neovim = neovim-nightly-overlay.packages.x86_64-linux.neovim;
    };
    pkgs = import nixpkgs {
      system = "x86_64-linux";
      overlays = [overlayFlakeInputs];
    };
  in {
    packages.x86_64-linux.default = pkgs.neovim;
    apps.x86_64-linux.default = {
      type = "app";
      program = "${pkgs.neovim}/bin/nvim";
    };
  };
}
