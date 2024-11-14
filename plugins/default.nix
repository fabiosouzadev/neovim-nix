{pkgs}: let
  vimPlugins = with pkgs.vimPlugins; [
    avante
    telescope-nvim
    # extras
    vim-tmux-navigator
  ];
  awesomeNeovimPlugins = with pkgs.awesomeNeovimPlugins; [
    codecompanion-nvim
  ];
in [
  vimPlugins
  awesomeNeovimPlugins
]
