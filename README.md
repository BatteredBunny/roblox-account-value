<h1 align="center">Roblox account value</h1>

<p align="center">WebApp that displays account value in robux and euro</p>

This webapp is pretty much an api wrapper for [roblox-account-value-api](https://github.com/BatteredBunny/roblox-account-value-api) so main functionality is on the server side

# Hosting the webapp on nixos with caddy

```nix
# flake.nix
roblox-account-value.url = "github:BatteredBunny/roblox-account-value";
```

```nix
# configuration.nix
services.caddy.virtualHosts = {
    "roblox-account-value.sly.ee".extraConfig = ''
        root * ${inputs.roblox-account-value.packages.${system}.default}
        file_server
    '';
};
```

# Development

### Normal way to build the project is with nix

```
nix build
```

### Get development dependencies easily
(or if you have direnv they already get auto installed)

```
nix develop
```

### Build the web app locally

```
make
```

### Start live version at localhost

```
make dev
```

### Start production version at localhost

```
make start
```
