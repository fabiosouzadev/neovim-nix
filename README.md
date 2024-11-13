# neovim-nix
fabiosouzadev's Neovim flake;
## WIP
:with
### Run in shell

- Run `neovim` directly from directory with:

```shell
$ nix run
```

- Run `neovim` directly with:

```shell
$ nix run github:fabiosouzadev/neovim-nix
```

- Run `neovim` in new shell with:

```shell
$ nix shell github:fabiosouzadev/neovim-nix
$ neovim
```

## To use the overlay

### with Flakes

If you are using [flakes] to configure your system, you can either reference the
package provided by this flake directly, e.g. for nixos:

```nix
{ inputs, pkgs, ... }:
{
  programs.neovim = {
    enable = true;
    package = inputs.fabiosouzadev-nvim.packages.${pkgs.system}.default;
  };

  # or

  environment.systemPackages = [
    inputs.fabiosouzadev-nvim.packages.${pkgs.system}.default
  ];
}
```

or you can apply the overlay to your package set, e.g for home-manager:

```nix
{
  inputs = {
    ...
    fabiosouzadev-nvim.url = "github:fabiosouzadev/neovim-nix";
  };

  outputs = { self, ... }@inputs:
    let
      overlays = [
        inputs.fabiosouzadev-nvim.overlays.default
      ];
    in
      homeConfigurations = {
        macbook-pro = inputs.home-manager.lib.homeManagerConfiguration {
          modules = [
            {
              nixpkgs.overlays = overlays;
            };
          ];
        };
      };
}
```
### without Flakes

Add the overlay to your home.nix (home-manager) or configuration.nix (nixos):

```nix
{
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/fabiosouzadev/neovim-nix/archive/master.tar.gz";
    }))
  ];
}
```
Due to some nixpkgs breaking changes if you are using NixOS 24.05 use the overlay below <br/>
*also requires that you have the nixpkgs-unstable `nix-channel`*
```nix
{
  nixpkgs.config = {
    packageOverrides = pkgs: let
      pkgs' = import <nixpkgs-unstable> {
        inherit (pkgs) system;
        overlays = [
          (import (builtins.fetchTarball {
            url = "https://github.com/fabiosouzadev/neovim-nix/archive/master.tar.gz";
          }))
        ];
      };
    in {
      inherit (pkgs') neovim;
    };
  };
}
```
