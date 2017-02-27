{
  allowUnfree = true;

  firefox.enableAdobeFlash = true;

  packageOverrides = super: let self = super.pkgs; in with self; {
    everything = buildEnv {
      name = "everything";
      paths = [
        ag
        AgdaStdlib
        autossh
        bc
        clementine
        dunst
        emacs
        evince
        feh
        firefox
        gimp
        git
        gnupg
        gtk-engine-murrine
        htop
        keepassx2
        libnotify
        libreoffice
        qbittorrent
        neovim
        numix-gtk-theme
        rxvt_unicode-with-plugins
        scrot
        spotify
        sxiv
        thunderbird
        tmux
        tree
        unzip
        vlc
        volumeicon
        weechat
        xclip
        zathura

        gnome3.baobab

        xorg.xkbcomp

        default-ghc
        default-tex
        #my-st
        my-hunspell
        #hoq
      ];
    };

    #haskellPackages = super.haskellPackages.override {
    #  overrides = self: super: {
    #    Agda = self.callPackage ./Agda-2.5.2.nix {};
    #  };
    #};

    # Note: be more discerning with what is included in Hoogle and what isn't.
    # pkgs/development/haskell-modules/default.nix has the definition of
    # ghcWithHoogle.
    default-ghc = haskellPackages.ghcWithHoogle (h: with h; [
      Agda
      turtle
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

    hoq = callPackage ../Downloads/hoq/default.nix { };
  };
}
