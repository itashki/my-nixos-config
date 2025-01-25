{ pkgs, ... }: {
  home.stateVersion = "23.11";

  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  xsession = {
    numlock.enable = false;
  };

  home = {
    pointerCursor = {
      x11.enable = true;
      gtk.enable = true;
      name = "Nordzy-cursors";
      package = pkgs.nordzy-cursor-theme;
      size = 24;
    };
  };

  gtk = {
    theme = {
      name = "Adwaita-dark";
    };
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  xsession = {
    enable = true;
  };

  programs = {
    thefuck.enable = true;
    fzf = {
      enable = true;
      enableZshIntegration = true;
    };
    # vscode = {
    #   enable = true;
    #   package = pkgs.vscodium.fhs;
    # };
    zsh = {
      enable = true;
      oh-my-zsh = {
        enable = true;
        theme = "agnoster";
      };
      syntaxHighlighting = {
        enable = true;
      };
      envExtra = "ZSH_DISABLE_COMPFIX=true";
    };

    rofi = {
      enable = true;
      terminal = "kitty";
      theme = "gruvbox-dark-soft";
    };
  };

  services = {
    mpris-proxy.enable = true; #bluetooth buttons
    picom = {
      enable = true;
      vSync = true;
      # backend = "glx";
      # settings = {
      # experimental-backends = true;
      # inactive-dim = 0.1;
      # mark-overdir-focused = false;
      # mark-wmwin-focused = false;
      # };
    };
    kdeconnect = {
      enable = true;
      package = pkgs.kdePackages.kdeconnect-kde;
      indicator = true;
    };
  };

  xdg = {
    userDirs = {
      enable = true;
      createDirectories = true;
      desktop = null;
      documents = "Documents";
      download = "Downloads";
      music = "Music";
      pictures = "Pictures";
      publicShare = null;
      templates = null;
      videos = "Videos";
    };
    desktopEntries =
      {
        editConfig = {
          name = "Edit system config";
          terminal = false;
          exec = "kitty --hold -e bash ${./editConfig.sh}";
        };

        reloadConfig = {
          name = "Rebuild system";
          terminal = false;
          exec = "kitty --hold -e sudo nixos-rebuild --upgrade switch";
        };

        headPhonesBluetooth = {
          name = "Connect bluetooth headphones";
          terminal = false;
          exec = "bluetoothctl connect E8:EE:CC:AB:34:92";
        };
      };
  };

}
