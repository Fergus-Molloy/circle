{
  description = "An X the everything app clone for self-hosters";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      with pkgs;
      {
        devShells = {
          default = mkShell {
            buildInputs = [
              elixir
              elixir-ls
              libnotify
              inotify-tools
              watchexec
              erlang
              nodejs
              nodePackages."vscode-langservers-extracted"
              nil
              nixpkgs-fmt
              tailwindcss_4
              esbuild
              watchman
              (pkgs.writeShellScriptBin "pg-connect" ''
                ${pkgs.postgresql}/bin/psql postgresql://postgres:postgres@localhost:5432/circle_dev
              '')
            ];
          };
        };
      }
    );
}
