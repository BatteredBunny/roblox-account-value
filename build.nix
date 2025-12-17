{ pkgs
, makeRustPlatform
,
}:
let
  targetName = "wasm32-unknown-unknown";

  wasm-rust = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "rust-src" ];
    targets = [ targetName ];
  };

  rustPlatformWasm = makeRustPlatform {
    cargo = wasm-rust;
    rustc = wasm-rust;
  };

  wasm-build = rustPlatformWasm.buildRustPackage {
    name = "roblox-account-value";
    cargoLock.lockFile = ./Cargo.lock;

    src = ./.;

    nativeBuildInputs = with pkgs; [
      wasm-bindgen-cli
    ];

    buildInputs = with pkgs; [
      openssl
      pkg-config
      gnumake
    ];

    buildPhase = ''
      cargo build --target ${targetName} --release
      wasm-bindgen target/${targetName}/release/roblox_account_value.wasm --out-dir=$out/pkg
    '';

    installPhase = "echo 'Skipping installPhase'";
  };
in
pkgs.stdenv.mkDerivation (finalAttrs: {
  pname = "roblox-account-value";
  version = "0.1.4";

  src = ./www;

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm_10.configHook
  ];

  buildPhase = ''
    runHook preBuild

    ln -s ${wasm-build}/pkg ../pkg
    pnpm build
    cp -r dist $out

    runHook postBuild
  '';

  pnpmDeps = pkgs.pnpm_10.fetchDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 2;
    hash = "sha256-m2NQiBgbMt/RUvoCkcmZBF7iB4dL2jkT9kK08LSpM/Y=";
  };
})