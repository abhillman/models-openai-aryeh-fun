For a demo, visit [models.openai.aryeh.fun](https://models.openai.aryeh.fun/)

# Local development

`cargo run`. Make sure `OPENAI_API_KEY` is set.

# Deployment as a service on `nixos` 

> ✨ **Tip**<br/>
> If you are not using flakes to manage your `nixos` installation, see [this useful guide](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled).

Update the `inputs`, `ouptuts`, `modules` sections of your `/etc/nixos/flake.nix`. Take care to add the `specialArgs` section with your appropriate platform.

```nix
{
  description = "NixOS Configuration Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    models-openai-aryeh-fun = {
      url = "github:abhillman/models-openai-aryeh-fun?rev=13dc73bbe3a286a8122a7c731b4eca1c9d2724e8";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, models-openai-aryeh-fun, ... }: {
    nixosConfigurations."compute-aryeh-fun" = nixpkgs.lib.nixosSystem {
      specialArgs = {
        system = "x86_64-linux";
      };
      modules = [
        ./configuration.nix
        models-openai-aryeh-fun.nixosModules
        {
          services.models-openai-aryeh-fun = {
            enable = true;
            openaiApiKeyPath = ./openai-api-key;
          };
        }
      ];
    };
  };
}
```

Then, run `nixos-rebuild`. Access the server at [`http://localhost:8000`](http://localhost:8000).
