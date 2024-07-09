# Local development

`cargo run`. Make sure `OPENAI_API_KEY` is set.

# Deployment as a service on `nixos` 

> ✨ **Tip**<br/>
> If you are not using flakes to manage your `nixos` installation, see [this useful guide](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/nixos-with-flakes-enabled).


Add the following to the `inputs` section of `/etc/nixos/flake.nix`:

```nix
models-openai-aryeh-fun = {
  url = "github:abhillman/models-openai-aryeh-fun?rev=bad2e94f0e89a1840aad79538a8455e073af6c44";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Add the following to the `outputs` section:

```nix
models-openai-aryeh-fun
```

And the following to the `modules` section:

```nix
models-openai-aryeh-fun.nixosModules
{
  services.models-openai-aryeh-fun = {
    enable = false;
    openaiApiKeyPath = /path/to/openai-api-key; # eg /secrets/openai-api-key
  };
}
```

Then, run `nixos-rebuild`. Access the server at [`http://localhost:8000`](http://localhost:8000).
