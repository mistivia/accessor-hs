{
  description = "accessor-hs - A Haskell accessor library";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        haskellPackages = pkgs.haskellPackages;

        package = haskellPackages.callCabal2nix "accessor-hs" ./. {};
      in
      {
        packages = {
          default = package;
          accessor-hs = package;
        };

        devShells.default = haskellPackages.shellFor {
          packages = p: [ package ];
          withHoogle = true;
          buildInputs = with haskellPackages; [
            cabal-install
            ghcid
            haskell-language-server
            hlint
            ormolu
          ];
        };
      });
}
