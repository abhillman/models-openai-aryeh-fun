{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    naersk.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils, naersk }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        naersk-lib = pkgs.callPackage naersk { };
      in {
        packages.default = naersk-lib.buildPackage ./.;
        devShells.default = with pkgs;
          mkShell {
            buildInputs =
              [ cargo rustc rustfmt pre-commit rustPackages.clippy ];
            RUST_SRC_PATH = pkgs.rustPlatform.rustLibSrc;
          };
      }) // {
        nixosModules = { config, lib, pkgs, system, ... }:
          with lib;
          let
            cfg = config.services.models-openai-aryeh-fun;
            pkg = self.packages.${system}.default;
          in {
            options.services.models-openai-aryeh-fun = {
              enable = mkEnableOption "Enables models-openai-aryeh-fun";
            };
            config = mkIf cfg.enable {
              systemd.services."models-openai-aryeh-fun" = {
                wantedBy = [ "multi-user.target" ];
                serviceConfig = let pkg = self.packages.${system}.default;
                in {
                  ExecStart = "${pkg}/bin/models-openai-aryeh-fun";
                };
                description =
                  "Server that lists currently available OpenAI models.";
              };
            };
          };
      };
}
