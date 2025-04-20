{ inputs, pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) system;
  # umu = inputs.umu.packages.${system}.umu.override {
  #   version = inputs.umu.shortRev;
  #   truststore = true;
  #   cbor2 = true;
  # };
in
{
  imports = [
    ./hardware-configuration.nix # Include the results of the hardware scan.
    inputs.home-manager.nixosModules.home-manager
  ];

  boot.kernelParams = [
    # "preempt=full"
    # "acpi_rev_override"
    # "mem_sleep_default=deep"
    # "intel_iommu=igfx_off"
    # "nvidia-drm.modeset=1"
  ];

  # boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  # boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  environment.sessionVariables = {
    GTK2_RC_FILES = "$HOME/.config/gtk-2.0/gtkrc-2.0";
    QT_QPA_PLATFORMTHEME = "qt5ct";
    EM_CACHE = "$HOME/.emscripten_cache";
  };

  environment.localBinInPath = true;

  environment.variables = {
    VISUAL = "emacsclient -r -a emacs";
    EDITOR = "emacsclient -r -a emacs";
  };

  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };

  # nixpkgs.config.pulseaudio = true;

  hardware.graphics = with pkgs; {
    enable = true;
    enable32Bit = true;
    extraPackages = [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  powerManagement.cpuFreqGovernor = "performance";

  services.xserver.videoDrivers = [ "nvidia" ];

  # services.printing.enable = true;
  # services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];

  hardware.nvidia = {
    # Modesetting is needed for most Wayland compositors
    modesetting.enable = true;

    # Use the open source version of the kernel module
    # Only available on driver 515.43.04+
    open = false;

    # Enable the nvidia settings menu
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  virtualisation.libvirtd.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;
  services.spice-autorandr.enable = true;
  virtualisation.podman.enable = true;
  programs.dconf.enable = true;
  virtualisation.docker.enable = true;

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 5029 ];
    allowedUDPPorts = [ 5029 ];
    allowedTCPPortRanges = [
      { from = 1714; to = 1764; }
    ];
    allowedUDPPortRanges = [
      { from = 1714; to = 1764; } #kdeconnect ports
    ];
  };

  # Enable network manager applet
  programs.nm-applet.enable = true;

  # Set your time zone.
  #time.timeZone = "Asia/Yekaterinburg";
  services.automatic-timezoned.enable = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the LXQT Desktop Environment.
  # services.xserver.desktopManager.lxqt.enable = true;


  # Configure keymap in X11
  services.xserver = {
    config = ''
      Section "Device"
          Identifier  "Intel Graphics"
          Driver      "intel"
          #Option      "AccelMethod"  "sna" # default
          #Option      "AccelMethod"  "uxa" # fallback
          Option      "TearFree"        "true"
          Option      "SwapbuffersWait" "true"
          BusID       "PCI:0:2:0"
          #Option      "DRI" "2"             # DRI3 is now default
      EndSection

      Section "Device"
          Identifier "nvidia"
          Driver "nvidia"
          BusID "PCI:1:0:0"
          Option "AllowEmptyInitialConfiguration"
      EndSection
    '';

    screenSection = ''
      Option         "metamodes" "nvidia-auto-select +0+0 {ForceFullCompositionPipeline=On}"
      Option         "AllowIndirectGLXProtocol" "off"
      Option         "TripleBuffer" "on"
    '';

    xkb.layout = "us,ru,il";
    xkb.variant = "";
    xkb.options = "grp:caps_toggle,terminate:ctrl_alt_bksp,lv3:ralt_switch_multikey,";

    desktopManager = {
      xterm.enable = false;
      xfce = {
        enable = true;
        enableXfwm = false;
      };
    };

    windowManager = {
      # bspwm = {
      #   enable = true;
      # };
      awesome = {
        enable = true;
        noArgb = true;
      };
      xmonad = {
        enable = true;
        enableContribAndExtras = true;
        extraPackages = haskellPackages: [
          haskellPackages.xmonad-contrib
          haskellPackages.xmonad-extras
          haskellPackages.xmonad
        ];
        haskellPackages = pkgs.haskell.packages.ghc98.override {
          overrides = self: super: {
            xmonad-contrib = self.callHackageDirect
              {
                pkg = "xmonad-contrib";
                ver = "0.18.1";
                sha256 = "sha256-3N85ThXu3dhjWNAKNXtJ8rV04n6R+/rGeq5C7fMOefY=";
              }
              { };
          };
        };
      };
    };
  };

  services.displayManager = {
    ly = {
      enable = true;
      settings = {
        animation = "matrix";
        # hide_borders = true;
        clear_password = true;
        vi_mode = true;
        vi_default_mode = "insert";
      };
    };
  };

  environment.xfce.excludePackages = with pkgs.xfce; [
    parole
    mousepad
    xfdesktop
    xfce4-terminal
  ];

  # Enable sound with pipewire.
  # sound.enable = true;
  # hardware.pulseaudio = {
  #   enable = false;
  #   package = pkgs.pulseaudioFull;
  # };
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  hardware.bluetooth.enable = true;

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  services.ratbagd.enable = true;

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [ zsh ];

  programs.gamemode.enable = true;
  programs.java.enable = true;

  programs.steam = {
    enable = true;
    package = with pkgs; steam.override {
      extraPkgs = pkgs: [
        jq
        cabextract
        wget
        pkgsi686Linux.libpulseaudio
      ];
    };
  };

  programs.firefox = {
    enable = true;
    # nativeMessagingHosts.ff2mpv = true;
    nativeMessagingHosts.packages = [ pkgs.ff2mpv ];
  };

  services.zerotierone = {
    port = 9993;
    enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.ktrd = {
    isNormalUser = true;
    description = "ktrd";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" "docker" ];
    packages = with pkgs; [
      wineWowPackages.staging
      winetricks
      protontricks
      distrobox
    ];
  };

  # Enable automatic login for the user.
  # services.displayManager.autoLogin.enable = false;
  # services.xserver.displayManager.autoLogin.user = "ktrd";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  nixpkgs.overlays = [
    (self: super: {
      mpv = super.mpv.override {
        scripts = [ self.mpvScripts.mpris ];
      };
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    virt-manager
    virtiofsd
    cifs-utils

    anydesk

    #doom emacs dependencies
    ((emacsPackagesFor emacs).emacsWithPackages (epkgs: [
      epkgs.vterm
    ]))
    cmake
    gcc
    nodejs
    gnumake
    libtool
    fd
    ripgrep
    aspell
    aspellDicts.en
    aspellDicts.ru
    aspellDicts.he
    shellcheck # shell
    shfmt
    multimarkdown # markdown
    dockfmt # docker
    clang-tools # c/c++
    nixfmt-rfc-style
    libxml2 # xml
    python313Packages.grip # markdown
    html-tidy # html
    stylelint # css
    jsbeautifier # js
    python3Full # python

    vim
    vscode.fhs
    git
    htop
    xkb-switch

    ffmpeg
    libsForQt5.qt5ct

    xwinwrap
    xfce.xfce4-pulseaudio-plugin
    xfce.xfce4-weather-plugin
    xfce.xfce4-xkb-plugin
    xfce.thunar-archive-plugin
    xfce.xfce4-clipman-plugin
    xarchiver
    pavucontrol

    gimp3
    chromium
    tor-browser
    librewolf
    telegram-desktop
    discord
    betterdiscordctl
    zoom-us
    element-desktop
    hexchat

    qbittorrent
    obs-studio
    evince
    coolreader
    mpv
    mpvScripts.mpris

    nitrogen
    shotgun
    slop

    kitty
    kitty-themes
    fastfetch

    libsForQt5.breeze-icons

    prismlauncher
    gzdoom
    lutris
    umu-launcher
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.symbols-only
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?

  system.autoUpgrade = {
    enable = true;
    dates = "weekly";
  };

  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 28d";
    };
  };

}
