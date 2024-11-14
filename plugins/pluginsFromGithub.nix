{
  inputs,
  pkgs,
}: {
  avante = pkgs.vimUtils.buildVimPlugin {
    name = "avante";
    src = inputs.avante-src;
  };
}
