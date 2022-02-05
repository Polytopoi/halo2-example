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
             pkgs.mkShell
               { buildInputs =
                   with pkgs;
                   [ cargo
                     cargo2nix
                     rustfmt
                   ];
               };
         }
      );
}
