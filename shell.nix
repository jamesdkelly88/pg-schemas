{ pkgs ? import <nixpkgs> {
    config.allowUnfree = true;
} }:

pkgs.mkShell {
  packages = with pkgs; [
    pgadmin4-desktopmode
    pgschema
    postgresql_18
    powershell
    terraform
  ];

  shellHook = ''
    # todo
  '';
}