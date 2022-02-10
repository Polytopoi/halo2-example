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
           rustPkgs =
             pkgs.rustBuilder.makePackageSet'
               { rustChannel = "1.56.1";
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
             pkgs.mkShell
               { buildInputs =
                   with pkgs;
                   [ cargo
                     cargo2nix
                     rustfmt
                   ];

                 shellHook =
                   ''
                   ${help}

                   alias gen_proof="cargo run --bin gen_proof"
                   alias help="${help}"
                   alias verify="cargo run --bin verify"
                   '';
               };
         }
      );
}
