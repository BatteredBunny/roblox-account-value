{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , rust-overlay
    , ...
    }:
    let
      inherit (nixpkgs) lib;

      systems = lib.systems.flakeExposed;

      forAllSystems = lib.genAttrs systems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;

        overlays = [
          rust-overlay.overlays.default
        ];
      });
    in
    {
      overlays.default = final: prev: {
        roblox-account-value = self.packages.${final.stdenv.system}.roblox-account-value;
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
        in
        rec {
          roblox-account-value = default;
          default = pkgs.callPackage ./build.nix { };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};

          wasm-rust = pkgs.rust-bin.stable.latest.default.override {
            extensions = [ "rust-src" ];
            targets = [ "wasm32-unknown-unknown" ];
          };
        in
        {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              openssl
              pkg-config
              gnumake
              wasm-rust
              yarn
              wasm-bindgen-cli
            ];
          };
        });
    };
}
