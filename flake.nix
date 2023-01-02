{
  description = "texts.app";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        build = pkgs.appimageTools.wrapType2 rec {
          pname = "texts-dot-com";
          version = "1.0"; # TODO

          # Can the AppImage be pinned?
          src = pkgs.fetchurl {
            url = "https://texts.com/api/install/linux/x64/latest.AppImage";
            sha256 = "1y3c5pn395v9vzck2g3vpcg3x82ql1agxpp824r6k5yxgbybg0r5";
          };

          meta = with pkgs.lib; {
            description = "A texts app";
            homepage = "https://texts.com/";
            maintainers = with maintainers; [ jakeisnt ];
            # license = licenses.unfree; TODO
            platforms = platforms.linux;
          };
        };
      in {
        defaultPackage.${system} = build;
        packages."texts-dot-com" = build;

        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            openssl
            libressl
            gcc
            pkg-config
            zlib
            clang

            build

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


