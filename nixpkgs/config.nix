{
  allowUnfree = true;

  firefox.enableAdobeFlash = true;

  # Needed for Clementine. Remove when possible.
  permittedInsecurePackages = [
    "libplist-1.12"
  ];

  packageOverrides = super: let self = super.pkgs; in with self; {
    pinned = import (fetchFromGitHub {
      rev = "2180d2c1180b04b14877cccad841fdb06941255a";
      sha256 = "0kf5babd9y7r5wz4982m637x65lh8m4qma6gpc9mix1bxp2bvh8q";
      owner = "NixOS";
      repo = "nixpkgs-channels";
    }) { config.packageOverrides = s: {}; };

    #inherit (pinned) AgdaStdlib;

    everything = buildEnv {
      name = "everything";
      paths = [
        #pretty
        abcde
        ag
        AgdaStdlib
        anki
        autossh
        bc
        cabal2nix
        clementineFree
        cmus
        cmusfm
        discord
        #dunst
        emacs
        evince
        feh
        firefox
        flac
        gimp
        git
        gksu
        gnupg
        go-mtpfs
        gtk-engine-murrine
        htop
        ibus-qt
        idris
        imagemagick
        inkscape
        keepassxc
        libnotify
        #libreoffice
        mp3gain
        mpv
        neovim #(neovim.override { withPyGUI = true; })
        neovim-qt
        numix-gtk-theme
        qbittorrent
        qutebrowser
        rlwrap
        rxvt_unicode-with-plugins
        scrot
        smem
        #spotify
        sxiv
        termite
        thunderbird
        tmux
        tree
        unzip
        vlc
        volumeicon
        weechat
        (wine)
        xclip
        xfce.xfce4-hardware-monitor-plugin
        zathura

        gnome3.baobab

        rustChannels.stable.rust
        #rustStable.rustc
        #rustStable.cargo

        xorg.xkbcomp

        default-ghc
        default-tex
        #my-st
        my-hunspell
        #hoq
        #dem-plays
        #tail-lfm
      ];
    };

    # try changing `super' back to `pinned'
    haskellPackages = super.haskellPackages.override {
      overrides = self: super: {
        #Agda = self.callPackage ./Agda-2.5.2.nix {};
        dotenv = self.callPackage ../repos/dotenv-hs/package.nix {};
        liblastfm = self.callPackage ../repos/liblastfm/package.nix {};
        req = haskell.lib.dontCheck super.req;
        xml-html-conduit-lens = self.callPackage ../repos/xml-html-conduit-lens/package.nix {};
      };
    };

    # Note: be more discerning with what is included in Hoogle and what isn't.
    # pkgs/development/haskell-modules/default.nix has the definition of
    # ghcWithHoogle.
    default-ghc = haskellPackages.ghcWithHoogle (h: with h; [
      Agda
      turtle
      #idris
      stack
      Cabal
      cabal-install
    ]);

    default-tex = texlive.combine {
      inherit (texlive) scheme-small;
    };

    my-st = st.override {
      patches = [
        (fetchurl {
          url = "http://st.suckless.org/patches/st-no_bold_colors-20160727-308bfbf.diff";
          sha256 = "1p1rvafj3pfl4rrfkk8696c8qp7v15glrkzxzizhdvbrmbmdp31f";
        })
        (fetchurl {
          url = "http://st.suckless.org/patches/st-solarized-both-20160727-308bfbf.diff";
          sha256 = "00wp1bcygsvf6lx7gipci2brgma24zw1pfzb0717xs3s3fh5pcmp";
        })
      ];

      conf = builtins.readFile ./st-config.h;
      #conf = ''
      #  static char shell[] = "/run/current-system/sw/bin/zsh";
      #  static char termname[] = "st-256color";
      #  static char font[] = "DejaVu Sans Mono:pixelsize=13:antialias=true:hinting=true";
      #'';
    };

    my-hunspell = hunspellWithDicts (with hunspellDicts;
      [ en-gb-ize en-gb-ise ]);

    hoq = callPackage ../Downloads/hoq/default.nix {
      compiler = "ghc802";
    };

    dem-plays = callPackage ../repos/dem_plays/pkg.nix { };

    tail-lfm = haskellPackages.callPackage ../repos/tail-lfm/pkg.nix { };

    cmusfm = callPackage ./cmusfm.nix { };
  };
}
