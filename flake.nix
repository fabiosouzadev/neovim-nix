{
  description = "Neovim configuration for fabiosouzadev (Fabio Souza) as a  plugin";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
  

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        lib = import ./lib;
      };

      systems = ["aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: 
      {
        apps = {
          nvim = {
            program = "${config.packages.neovim}/bin/nvim";
            type = "app";
          };
        };

        devShells = {
          default = pkgs.mkShell {
            name = "nvim-devShell";
            buildInputs =  with pkgs;[
              just
              # Tools for Lua and Nix development, useful for editing files in this repo
              lua-language-server
              nil
              stylua
              luajitPackages.luacheck
            ];
          };
        };

        formatter = pkgs.alejandra;

        packages = {
          default = self.lib.mkVimPlugin {inherit system;};
          neovim = self.lib.mkNeovim {inherit system;};
        };
      };
    };
}
