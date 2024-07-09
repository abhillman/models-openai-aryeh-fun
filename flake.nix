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
              openaiApiKeyPath = mkOption {
                type = types.path;
                example = "/secrets/openai-api-key";
                description = "Path to a valid OpenAI API key";
              };
            };
            config = mkIf cfg.enable {
              users.users."models-openai-aryeh-fun" = {
                isSystemUser = true;
                group = "models-openai-aryeh-fun";
              };
              users.groups."models-openai-aryeh-fun" = { };

              systemd.services."models-openai-aryeh-fun" = {
                wantedBy = [ "multi-user.target" ];
                serviceConfig = {
                  ExecStart = "${pkg}/bin/models-openai-aryeh-fun";
                  User = "models-openai-aryeh-fun";
                  Group = "models-openai-aryeh-fun";
                  Environment = "OPENAI_API_KEY="
                    + (builtins.readFile cfg.openaiApiKeyPath);
                };
                description =
                  "Server that lists currently available OpenAI models.";
              };
            };
          };
      };
}
