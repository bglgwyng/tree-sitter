{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    cargo2nix.url = "github:cargo2nix/cargo2nix";
  };

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        # To import a flake module
        # 1. Add foo to inputs
        # 2. Add foo as a parameter to the outputs function
        # 3. Add here: foo.flakeModule

      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, ... }:
        let cargo_nix = pkgs.callPackage ./Cargo.nix { };
        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            # overlays = [ inputs'.cargo2nix.overlays.default ];
          };

          # Per-system attributes can be defined here. The self' and inputs'
          # module parameters provide easy access to attributes of the same
          # system.


          # rustPkgs = pkgs.rustBuilder.makePackageSet {
          #   rustVersion = "1.75.0";
          #   packageFun = import ./cli/Cargo.nix;
          # };
          # Equivalent to  inputs'.nixpkgs.legacyPackages.hello;
          packages.default = cargo_nix.workspaceMembers."tree-sitter-cli".build;
        };
      flake = {
        # The usual flake attributes can be defined here, including system-
        # agnostic ones like nixosModule and system-enumerating ones, although
        # those are more easily expressed in perSystem.

      };
    };
}
