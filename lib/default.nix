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
    # dependecies
    vimPlugins.plenary-nvim
    
    # languages
    vimPlugins.nvim-lspconfig
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.vim-just

    # theme
    vimPlugins.tokyonight-nvim

    # extras
    vimPlugins.vim-tmux-navigator
    vimPlugins.todo-comments-nvim

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
    nodePackages."bash-language-server"
    nodePackages."diagnostic-languageserver"
    nodePackages."dockerfile-language-server-nodejs"
    nodePackages."pyright"
    nodePackages."typescript"
    nodePackages."typescript-language-server"
    nodePackages."vscode-langservers-extracted"
    nodePackages."yaml-language-server"
    pkgs.lua-language-server
    pkgs.nil

    # formatters
    pkgs.alejandra
    python3Packages.black
  ];
  mkExtraConfig = 
  ''
  lua << EOF
    require 'core'
    require 'plugins'
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
