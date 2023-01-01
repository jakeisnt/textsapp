{
  description = "texts.app";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            libressl
            gcc
            pkg-config
            zlib
            clang

            glibc.out
            glibc.static
            appimage-run
            libuuid # canvas
            libsecret
            libgnome-keyring
            gnome.gnome-keyring
          ];

          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          # this `makeLibraryPath` is necessary to provide `libcrypto` to `hunchentoot`.
          # This allows users to build acl2, which depends on hunchentoot!
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath (with pkgs; [openssl libsecret openssl.dev openssl pkgs.stdenv.cc.cc ])}}/lib:$LD_LIBRARY_PATH";
        };
      }
    );
}


