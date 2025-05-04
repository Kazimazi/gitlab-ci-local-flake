{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    gitlab-ci-local.url = "github:firecow/gitlab-ci-local";
    gitlab-ci-local.flake = false;
  };

  outputs = { self, nixpkgs, gitlab-ci-local }:
    let
      allSystems = [ "x86_64-linux" ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f {
        pkgs = import nixpkgs { inherit system; };
      });
    in
    {
      packages = forAllSystems ({ pkgs }: {
        default = pkgs.buildNpmPackage {
          name = "gitlab-ci-local";
          src = gitlab-ci-local;

          buildInputs = with pkgs; [
            nodejs
          ];

          # Skipping git command in npm run build script
          buildPhase = ''
            runHook preBuild

            ${pkgs.typescript}/bin/tsc

            runHook postBuild
          '';

          npmDepsHash = "sha256-EfXkCe+5DHDXbfdc7pXbgJpHp275QG+X5r8UyTcLPc8=";
        };
      });
    };
}
