{ inputs =
    { cargo2nix.url = "github:cargo2nix/cargo2nix";
      nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      utils.url = "github:ursi/flake-utils/6";
    };

  outputs = { cargo2nix, nixpkgs, rust-overlay, utils, ... }@inputs:
    utils.for-default-systems
      ({ system, ... }:
         let
           pkgs =
             import nixpkgs
               { inherit system;

                 overlays =
                   [ (import "${cargo2nix}/overlay")
                     rust-overlay.overlay
                   ];
               };

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
                     cargo2nix.defaultPackage.${system}
                     gcc
                     rustc
                     rustfmt
                   ];
               };
         }
      )
      inputs;
}
