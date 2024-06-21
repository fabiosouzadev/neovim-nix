{ inputs }:
rec {
  mkVimPlugin = { system }:
    let
      inherit (pkgs) vimUtils;
      inherit (vimUtils) buildVimPlugin;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
    in
    buildVimPlugin {
      name = "fabiosouzadev-new";
      src = ../nvim;
    };

  mkNeovimPlugins = { system }:
    let
      inherit (pkgs) vimPlugins;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config = { allowUnfree = true; };
      };
      fabiosouzadev-new-nvim = mkVimPlugin { inherit system; };
    in
    [
      # dependecies
      vimPlugins.plenary-nvim
      vimPlugins.nvim-web-devicons

      # telescope
      vimPlugins.telescope-nvim
      vimPlugins.telescope-fzf-native-nvim
      vimPlugins.telescope-ui-select-nvim

      # treesitter
      vimPlugins.nvim-treesitter.withAllGrammars
      vimPlugins.nvim-treesitter-context

      # git
      vimPlugins.gitsigns-nvim

      # lsp
      vimPlugins.fidget-nvim
      vimPlugins.neodev-nvim
      vimPlugins.nvim-lspconfig
      vimPlugins.vim-just

      # cmp
      vimPlugins.nvim-cmp # <https://github.com/hrsh7th/nvim-cmp>
      vimPlugins.cmp_luasnip # snippets autocompletion extension for nvim-cmp | <https://github.com/saadparwaiz1/cmp_luasnip/>
      vimPlugins.luasnip # https://github.com/l3mon4d3/luasnip/
      vimPlugins.lspkind-nvim # vscode-like LSP pictograms | <https://github.com/onsails/lspkind.nvim/>
      vimPlugins.cmp-nvim-lsp # LSP as completion source | <https://github.com/hrsh7th/cmp-nvim-lsp/>
      vimPlugins.cmp-nvim-lsp-signature-help # <https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/>
      vimPlugins.cmp-buffer # current buffer as completion source | <https://github.com/hrsh7th/cmp-buffer/>
      vimPlugins.cmp-path # file paths as completion source | <https://github.com/hrsh7th/cmp-path/>
      vimPlugins.cmp-nvim-lua # neovim lua API as completion source | <https://github.com/hrsh7th/cmp-nvim-lua/>
      #vimPlugins.cmp-cmdline # cmp command line suggestions
      #vimPlugins.cmp-cmdline-history # cmp command line history suggestions

      #IA
      vimPlugins.codeium-nvim

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
      #vimPlugins.bufferline-nvim

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
      vimPlugins.which-key-nvim

      # configuration
      fabiosouzadev-new-nvim
    ];

  mkExtraPackages = { system }:
    let
      inherit (pkgs) nodePackages python3Packages python312Packages php83Packages;
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    [
      # language servers
      nodePackages.bash-language-server
      nodePackages.diagnostic-languageserver
      nodePackages.dockerfile-language-server-nodejs
      nodePackages.typescript
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted
      nodePackages.yaml-language-server
      nodePackages.prettier
      nodePackages.intelephense
      pkgs.lua-language-server
      pkgs.nil
      pkgs.gopls
      pkgs.emmet-ls
      pkgs.pyright
      pkgs.phpactor

      # formatters
      pkgs.alejandra
      pkgs.nixpkgs-fmt
      pkgs.stylua
      pkgs.prettierd
      python3Packages.black
      python312Packages.isort
      php83Packages.php-cs-fixer
    ];
  mkExtraConfig = ''
    lua << EOF
      require 'core'
      require 'plugins'
    EOF
  '';

  mkNeovim = { system }:
    let
      inherit (pkgs) lib neovim;
      extraPackages = mkExtraPackages { inherit system; };
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      start = mkNeovimPlugins { inherit system; };
    in
    neovim.override {
      configure = {
        customRC = mkExtraConfig;
        packages.main = { inherit start; };
      };
      extraMakeWrapperArgs = ''--suffix PATH : "${lib.makeBinPath extraPackages}"'';
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };

  mkHomeManager = { system }:
    let
      extraConfig = mkExtraConfig;
      extraPackages = mkExtraPackages { inherit system; };
      plugins = mkNeovimPlugins { inherit system; };
    in
    {
      inherit extraConfig extraPackages plugins;
      defaultEditor = true;
      enable = true;
      withNodeJs = true;
      withPython3 = true;
      withRuby = true;
    };
}
