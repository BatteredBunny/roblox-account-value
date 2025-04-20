{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
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

      overlays = [ (import rust-overlay) ];

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system overlays;
      });
    in
    {
      overlays.default = final: prev: {
        roblox-account-value = final.callPackage ./build.nix { };
      };

      packages = forAllSystems (system:
        let
          pkgs = nixpkgsFor.${system};
          overlay = lib.makeScope pkgs.newScope (final: self.overlays.default final pkgs);
        in
        {
          inherit (overlay) roblox-account-value;
          default = overlay.roblox-account-value;
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
