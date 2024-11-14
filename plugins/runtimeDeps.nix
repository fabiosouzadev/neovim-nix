{pkgs}: let
  nodepkgs = with pkgs.nodePackages; [
    typescript
    typescript-language-server
  ];
in
  with pkgs;
    [
      # language servers
      lua-language-server
      nil

      # formatters
      alejandra
      stylua

      lazygit
      # packages with results in /lib/node_modules/.bin must come at the end
    ]
    ++ nodepkgs
