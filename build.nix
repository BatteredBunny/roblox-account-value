{
  stdenvNoCC,
  rustPlatform,
  fetchPnpmDeps,
  nodejs,
  pnpmConfigHook,
  pnpm_10,
  openssl,
  wasm-bindgen-cli_0_2_106,
  pkg-config,
  llvmPackages,
}:
let
  targetName = "wasm32-unknown-unknown";
  pname = "roblox-account-value";
  version = "0.1.4";

  wasm-build = rustPlatform.buildRustPackage {
    inherit pname version;

    cargoLock.lockFile = ./Cargo.lock;

    src = ./.;

    nativeBuildInputs = [
      wasm-bindgen-cli_0_2_106
      pkg-config
      llvmPackages.lld
    ];

    buildInputs = [
      openssl
    ];

    doCheck = false;

    buildPhase = ''
      runHook preBuild

      cargo build --target ${targetName} --release

      mkdir -p $out/pkg
      wasm-bindgen target/${targetName}/release/roblox_account_value.wasm --out-dir=$out/pkg

      runHook postBuild
    '';

    installPhase = "echo 'Skipping installPhase'";
  };
in
stdenvNoCC.mkDerivation (finalAttrs: {
  inherit pname version;

  src = ./www;

  nativeBuildInputs = [
    nodejs
    pnpmConfigHook
    pnpm_10
  ];

  buildPhase = ''
    runHook preBuild

    ln -s ${wasm-build}/pkg ../pkg
    pnpm build
    cp -r dist $out

    runHook postBuild
  '';

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    fetcherVersion = 3;
    hash = "sha256-hH6biSkIPL8dQ8/Sdo8Hq01BG32ALFd0F+j+4rlTFXA=";
  };
})
