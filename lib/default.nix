{inputs}: let
  inherit (inputs.nixpkgs) legacyPackages;
in rec {

  mkVimPlugin = {system}: let
    inherit (pkgs) vimUtils;
    inherit (vimUtils) buildVimPlugin;
    pkgs = legacyPackages.${system};
  in
    buildVimPlugin {
      name = "fabiosouzadev-new";
      src = ../nvim;
    };

  mkNeovimPlugins = {system}: let
    inherit (pkgs) vimPlugins;
    pkgs = legacyPackages.${system};
    fabiosouzadev-new-nvim = mkVimPlugin {inherit system;};
  in [
    # languages
    vimPlugins.nvim-lspconfig

    # theme
    vimPlugins.tokyonight-nvim

    # extras

    # configuration
    fabiosouzadev-new-nvim
  ];

  mkExtraPackages = {system}: let
    inherit (pkgs) nodePackages ocamlPackages python3Packages;
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in [
    # language servers
    pkgs.lua-language-server
    pkgs.nil

    # formatters
  ];
  mkExtraConfig = 
  ''
  lua << EOF
    require "core"
    require("core.utils").load_mappings()

    -- {{{ Auto install lazy.nvim if when needed.
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not vim.loop.fs_stat(lazypath) then
      require("core.bootstrap").lazy(lazypath)
    end
    -- ------------------------------------------------------------------------- }}}
    vim.opt.rtp:prepend(lazypath)
    require "plugins"
  EOF
  '';

  mkNeovim = {system}: let
    inherit (pkgs) lib neovim;
    extraPackages = mkExtraPackages {inherit system;};
    pkgs = legacyPackages.${system};
    start = mkNeovimPlugins {inherit system;};
  in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = {inherit start;};
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = {system}: let
    extraConfig = mkExtraConfig;
    extraPackages = mkExtraPackages {inherit system;};
    plugins = mkNeovimPlugins {inherit system;};
  in {
    inherit extraConfig extraPackages plugins;
    defaultEditor = true;
    enable = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = true;
  };
}
