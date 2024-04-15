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
    vimPlugins.nvim-web-devicons

    # telescope
    vimPlugins.telescope-nvim
    vimPlugins.telescope-fzy-native-nvim
    
    # treesitter
    vimPlugins.nvim-treesitter.withAllGrammars
    vimPlugins.nvim-treesitter-textobjects
    vimPlugins.nvim-treesitter-context
    vimPlugins.nvim-ts-context-commentstring 
    vimPlugins.nvim-ts-autotag

    # git
    vimPlugins.diffview-nvim
    vimPlugins.neogit
    vimPlugins.gitsigns-nvim
    vimPlugins.vim-fugitive
    
    # lsp
    vimPlugins.nvim-lspconfig
    vimPlugins.vim-just

    # cmp
    vimPlugins.nvim-cmp # <https://github.com/hrsh7th/nvim-cmp>
    vimPlugins.cmp_luasnip # snippets autocompletion extension for nvim-cmp | <https://github.com/saadparwaiz1/cmp_luasnip/>
    vimPlugins.lspkind-nvim # vscode-like LSP pictograms | <https://github.com/onsails/lspkind.nvim/>
    vimPlugins.cmp-nvim-lsp # LSP as completion source | <https://github.com/hrsh7th/cmp-nvim-lsp/>
    vimPlugins.cmp-nvim-lsp-signature-help # <https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/>
    vimPlugins.cmp-buffer # current buffer as completion source | <https://github.com/hrsh7th/cmp-buffer/>
    vimPlugins.cmp-path # file paths as completion source | <https://github.com/hrsh7th/cmp-path/>
    vimPlugins.cmp-nvim-lua # neovim lua API as completion source | <https://github.com/hrsh7th/cmp-nvim-lua/>
    vimPlugins.cmp-cmdline # cmp command line suggestions
    vimPlugins.cmp-cmdline-history # cmp command line history suggestions

    # dap
    vimPlugins.nvim-dap
    vimPlugins.nvim-dap-ui
    vimPlugins.nvim-dap-python
    vimPlugins.nvim-dap-virtual-text
    vimPlugins.nvim-jdtls

    # theme
    vimPlugins.tokyonight-nvim

    # file manager
    vimPlugins.oil-nvim

    # bufferline
    vimPlugins.bufferline-nvim

    # statusline
    vimPlugins.lualine-nvim
    vimPlugins.lualine-lsp-progress

    # extras
    vimPlugins.vim-tmux-navigator
    vimPlugins.mini-nvim
    vimPlugins.comment-nvim
    vimPlugins.todo-comments-nvim
    vimPlugins.vim-sleuth
    vimPlugins.conform-nvim
    vimPlugins.indent-blankline-nvim
    vimPlugins.vim-be-good
    vimPlugins.harpoon2
    vimPlugins.vim-floaterm
    vimPlugins.fidget-nvim
    vimPlugins.neodev-nvim
    vimPlugins.which-key-nvim

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
    nodePackages."prettier"
    pkgs.lua-language-server
    pkgs.nil
    pkgs.gopls

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
