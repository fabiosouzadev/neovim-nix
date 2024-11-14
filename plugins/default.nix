{pkgs}: let
  vimPlugins = with pkgs.vimPlugins; [
    avante
    telescope-nvim
    # extras
    vim-tmux-navigator
    mini-nvim
    comment-nvim
    todo-comments-nvim
    which-key-nvim
  ];
  # awesomeNeovimPlugins = with pkgs.awesomeNeovimPlugins; [
  #   codecompanion-nvim
  # ];
in [
  vimPlugins
  # awesomeNeovimPlugins
]
