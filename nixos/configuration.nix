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
      extraEntries = ''
        menuentry "Windows" {
          insmod chain
          insmod msdos
          set root=(hd0,msdos2)
          chainloader +1
        }
      '';
    };
    tmpOnTmpfs = false;
    extraModprobeConfig = ''
      options snd-hda-intel position_fix=1
    '';
  };

  hardware = {
    pulseaudio = {
      #configFile = relative "my.pa";
      enable = true;
      support32Bit = true;
    };
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
      enable = false;
      drivers = with pkgs; [ hplipWithPlugin ];
    };
    dictd.enable = true;

    sshd.enable = true;

    illum.enable = true;

    tor = {
      enable = false;
      extraConfig = ''
        ExitNodes (jp)
        StrictNodes 1
      '';
      torsocks.enable = true;
    };

    urxvtd.enable = true;

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
        xmonad.enableContribAndExtras = true;
        xmonad.extraPackages = haskellPackages: with haskellPackages; [
          #xmonad-contrib
          #xmonad-extras
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
          #enableXfwm = false;
          #thunarPlugins = with pkgs.xfce;
          #[ thunar_volman thunar-archive-plugin tumbler ];
        };
        xterm.enable = false;
      };
      displayManager = {
        lightdm.enable = false;
        sddm.enable = true;
        sessionCommands = ''
          ${pkgs.networkmanagerapplet}/bin/nm-applet &
        '';
      };

      autorun = true;
    };

    upower.enable = true;
    dbus.enable = true;

    redshift = {
      enable = true;
      brightness = { day = "0.1"; night = "0.06"; };
      #latitude = "53.5";
      #longitude = "-1.7";
      provider = "geoclue2";
    };

    fcron = {
      enable = false;
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

      xfce.xfce4-hardware-monitor-plugin
      #xfce.xfce4_xkb_plugin

      breeze-qt5
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
      anthy hangul table table-others mozc
      shwa agda
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
      emojione
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
    packageOverrides = super: let self = super.pkgs; in with self; rec {
      pinned = import (fetchFromGitHub {
        rev = "96457d26dded05bcba8e9fbb9bf0255596654aab";
        sha256 = "0qv8c60n9vyn1wsviwyxz6d0ayd1cy92jz9f59wgklss059kpzdp";
        owner = "NixOS";
        repo = "nixpkgs-channels";
      }) { config.packageOverrides = s: { }; };

      #inherit (pinned) ibus;

      ibus-engines = super.ibus-engines // {
        table-others = callPackage (relative "ibus-table-others") {
          ibus-table = ibus-engines.table;
        };
        shwa = callPackage (relative "ibus-table-shwa") {
          ibus-table = ibus-engines.table;
        };
        agda = callPackage (relative "ibus-table-agda") {
          ibus-table = ibus-engines.table;
        };
      };

      xorg = super.xorg // rec {
        xkeyboardconfig-james =
        lib.overrideDerivation super.xorg.xkeyboardconfig (old: rec {
          name = "xkeyboard-config-james-${version}";
          version = "20161017.0";
          patches = [ (relative "xkeyboard-config-james.patch") ];
        });
        xorgserver = lib.overrideDerivation super.xorg.xorgserver (old: {
          #patches = [ (relative "xkeyboard-config-james.patch") ];
          # See nixpkgs/pkgs/servers/x11/xorg/overrides.nix
          configureFlags = [
            "--enable-kdrive"
            "--enable-xephyr"
            "--enable-xcsecurity"
            "--with-default-font-path="
            "--with-xkb-bin-directory=${xorg.xkbcomp}/bin"
            "--with-xkb-path=${xorg.xkeyboardconfig-james}/share/X11/xkb"
            "--with-xkb-output=$out/share/X11/xkb/compiled"
            "--enable-glamor"
          ];
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
