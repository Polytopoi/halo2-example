{ inputs =
    { cargo2nix.url = "github:cargo2nix/cargo2nix";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      utils.url = "github:ursi/flake-utils/8";
    };

  outputs = { cargo2nix, rust-overlay, utils, ... }@inputs:
    utils.apply-systems
      { inherit inputs;

        overlays =
          [ (import "${cargo2nix}/overlay")
            rust-overlay.overlay
          ];
      }
      ({ cargo2nix, pkgs, system, ... }:
         let
           rustChannel = "1.58.1";
           rustPkgs =
             pkgs.rustBuilder.makePackageSet'
               { rustChannel = rustChannel;
                 packageFun = import ./Cargo.nix;
               };
         in
         { inherit rustPkgs;
           defaultPackage = rustPkgs.workspace.halo2-example {};

           devShell =
             let
               help = "cat ${help-file}";

               help-file =
                 pkgs.writeText "help"
                 ''
                 Commands:
                   gen_proof a b    a and b are numbers and the proof is written
                                    to ./proof
                   verify c         c = a * b and the proof is read from ./proof
                   help             show this message
                 '';
             in
             rustPkgs.workspaceShell {
               nativeBuildInputs = with pkgs; [ rust-analyzer rustup ];
               shellHook =
                   ''
                   echo '[toolchain]
                   channel = "${rustChannel}"
                   components = [ "rustc", "rust-src", "cargo", "clippy", "rust-docs" ]' > rust-toolchain.toml

                   export RUST_SRC_PATH=~/.rustup/toolchains/${rustChannel}-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/

                   ${help}

                   alias gen_proof="cargo run --bin gen_proof"
                   alias help="${help}"
                   alias verify="cargo run --bin verify"
                   '';
               };
         }
      );
}
