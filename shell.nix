with import <nixpkgs> {};
mkShell {
    NIX_LD_LIBRARY_PATH = lib.makeLibraryPath [
        stdenv.cc.cc
        stdenv.cc.cc.lib
        openssl
        gcc-unwrapped.lib
        libgccjit.out
    ];

    NIX_LD = lib.fileContents "${stdenv.cc}/nix-support/dynamic-linker";
}
