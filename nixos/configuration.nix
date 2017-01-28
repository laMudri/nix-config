# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  #setLayoutCommands = ''
  #  xkbcomp -I$HOME/.xkb $HOME/.xkb/map.xkb $DISPLAY
  #'';
  relative = s: "/etc/nixos/" + s;
  my-ladspa = lib.overrideDerivation pkgs.ladspaH (self: {
    buildInputs = [ pkgs.ladspaPlugins ];
  });
  ibus-table-shwa = pkgs.callPackage (relative "ibus-table-shwa") {
    ibus-table = pkgs.ibus-engines.table;
  };
in

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    loader.grub = {
      enable = true;
      version = 2;
      device = "/dev/sda";
    };
    tmpOnTmpfs = true;
    extraModprobeConfig = ''
      options snd-hda-intel position_fix=1
    '';
  };

  hardware = {
    #pulseaudio = {
    #  configFile = relative "my.pa";
    #  enable = false;
    #  support32Bit = true;
    #};
    opengl.driSupport32Bit = true;
  };

  sound = {
    enable = true;
    enableOSSEmulation = true;
    extraConfig = ''
      pcm.ladspa {
        type ladspa
        slave.pcm "plughw:0,0";
        path "${pkgs.ladspaPlugins}/lib/ladspa";
        plugins [{
          label dysonCompress
          input {
            # peak limit, release time, fast ratio, ratio
            controls [1.0 0.1 0.1 0.9]
          }
        }]
      }
    '';
  };

  # Enable wireless support via wpa_supplicant.
  networking.wireless.enable = false;
  networking.networkmanager.enable = true;

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "en-latin9";
    defaultLocale = "en_GB.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/London";

  services = {
    printing = {
      enable = true;
      clientConf = ''
        ServerName cups-serv.cl.cam.ac.uk
      '';
      drivers = with pkgs; [ hplipWithPlugin ];
    };

    xserver = {
      enable = true;
      exportConfiguration = true;

      #layout = "james";
      #xkbVariant = "progwide_dh";

      inputClassSections = [''
        Identifier "james"
        MatchIsKeyboard "on"
        Option "XkbRules" "base"
        Option "XkbModel" "pc104"
        Option "XkbLayout" "james"
        Option "XkbVariant" "progwide_dh"
        Option "XkbKeycodes" "james"
        Option "XkbOptions" "terminate:ctrl_alt_bksp"
      ''];

      synaptics = {
        enable = true;
        accelFactor = "0.05";
        palmDetect = true;
        horizEdgeScroll = true;
        vertEdgeScroll = false;
        horizTwoFingerScroll = false;
        vertTwoFingerScroll = true;
        fingersMap = [ 1 3 2 ];
        additionalOptions = ''
          #Option "PressureMotionMinZ" "60"
          Option "FingerHigh" "30"
          Option "EmulateMidButtonTime" "200"
        '';
      };

      windowManager = {
        default = "xmonad";
        xmonad.enable = true;
        xmonad.extraPackages = haskellPackages: with haskellPackages; [
          xmonad-contrib
          xmonad-extras
          regex-posix
          taffybar
          turtle
          #xmonad-screenshot
        ];
        awesome = {
          enable = false;
        };
      };
      desktopManager = {
        #default = "none";
        xfce = {
          enable = true;
          #thunarPlugins = with pkgs.xfce;
          #[ thunar_volman thunar-archive-plugin tumbler ];
        };
        #kde5.enable = true;
      };
      displayManager = {
        lightdm.enable = false;
        sddm.enable = true;
        sessionCommands = ''
          ${pkgs.networkmanagerapplet}/bin/nm-applet &
        ''; # + setLayoutCommands;
      };

      autorun = true;
    };

    upower.enable = true;
    dbus.enable = true;

    redshift = {
      enable = false;
      brightness = { day = "1"; night = "0.9"; };
      latitude = "53.5";
      longitude = "-1.7";
    };

    fcron = {
      enable = true;
      #systab = ''
      #  0 9 * * * cd /home/james/nixpkgs && notify-send "~/nixpkgs" "$(git fetch)"
      #'';
    };
  };

  # Mount home partition
  fileSystems."/sharedhome" = {
    device = "/dev/disk/by-label/home";
    fsType = "ext4";
  };

  environment = {
    systemPackages = with pkgs; [
      dunst
      gnome3.dconf
      xcompmgr
      #taffybar
      volumeicon

      #xfce.xfce4-hardware-monitor-plugin
      xfce.xfce4_xkb_plugin

      kde5.breeze-qt4
      kde5.breeze-qt5
      gnome3.gnome_themes_standard
    ];
    shells = [ "/run/current-system/sw/bin/zsh" ];
    variables = {
      AWT_TOOLKIT = "MToolKit";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    };
  };

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [
      anthy hangul table table-others shwa agda
      # mozc
    ];
    fcitx.engines = with pkgs.fcitx-engines; [ anthy hangul table-other ];
  };

  programs = {
    zsh.enable = true;
  };

  # Add a user
  users.extraUsers.james = {
    shell = "/run/current-system/sw/bin/zsh";
    home = "/home/james";
    extraGroups = [ "wheel" "networkmanager" ];
  };

  fonts = {
    fontconfig.enable = true;
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      #fira-code
      inconsolata
      source-han-sans-japanese
      source-han-sans-korean
      source-han-sans-simplified-chinese
      source-han-sans-traditional-chinese
      #ubuntu-font-family
    ];
  };

  security.sudo.enable = true;

  nix.nixPath = [
    "/home/james"
    "nixos-config=/etc/nixos/configuration.nix"
    "nixpkgs=/home/james/nixpkgs"
  ];

  #virtualisation.virtualbox.host.enable = true;

  nixpkgs.config = {
    allowUnfree = true;
    virtualbox.enableExtensionPack = true;
    packageOverrides = super: rec {
      ibus-engines = {
        inherit (super.ibus-engines) anthy hangul table;
        table-others = pkgs.callPackage (relative "ibus-table-others") {
          ibus-table = pkgs.ibus-engines.table;
        };
        shwa = pkgs.callPackage (relative "ibus-table-shwa") {
          ibus-table = pkgs.ibus-engines.table;
        };
        agda = pkgs.callPackage (relative "ibus-table-agda") {
          ibus-table = pkgs.ibus-engines.table;
        };
      };
      #xfce = super.xfce // {
      #  xfce4panel = super.xfce.xfce4panel_gtk3;
      #};
      xorg = super.xorg // rec {
        xkeyboardconfig-james =
        lib.overrideDerivation super.xorg.xkeyboardconfig (old: rec {
          name = "xkeyboard-config-james-${version}";
          version = "20161017.0";
          patches = [ (relative "xkeyboard-config-james.patch") ];
        });
        xorgserver = lib.overrideDerivation super.xorg.xorgserver (old: {
          postInstall = ''
            rm -fr $out/share/X11/xkb/compiled
            ln -s /var/tmp $out/share/X11/xkb/compiled
            wrapProgram $out/bin/Xephyr \
              --set XKB_BINDIR "${xkbcomp}/bin" \
              --add-flags "-xkbdir ${xkeyboardconfig-james}/share/X11/xkb"
            wrapProgram $out/bin/Xvfb \
              --set XKB_BINDIR "${xkbcomp}/bin" \
              --set XORG_DRI_DRIVER_PATH ${super.mesa}/lib/dri \
              --add-flags "-xkbdir ${xkeyboardconfig-james}/share/X11/xkb"
            ( # assert() keeps runtime reference xorgserver-dev in
              # xf86-video-intel and others
              cd "$dev"
              for f in include/xorg/*.h; do # */
                sed "1i#line 1 \"${old.name}/$f\"" -i "$f"
              done
            )
          '';
        });
        setxkbmap = lib.overrideDerivation super.xorg.setxkbmap (old: {
          postInstall = ''
            mkdir -p $out/share
            ln -sfn ${xkeyboardconfig-james}/etc/X11 $out/share/X11
          '';
        });
        xkbcomp = lib.overrideDerivation super.xorg.xkbcomp (old: {
          configureFlags =
          "--with-xkb-config-root=${xkeyboardconfig-james}/share/X11/xkb";
        });
      };
    };
  };
}
