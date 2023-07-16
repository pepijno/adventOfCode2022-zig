{
  description = "Advent of Code 2022 in zig";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    utils.url = github:numtide/flake-utils;
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages."${system}";

        buildInputs = with pkgs; [
          zig
          valgrind
        ];
      in
      rec {
        # `nix develop`
        devShell = pkgs.mkShell {
          inherit buildInputs;
        };
      });
}
