# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  imports = [ ./hardware-configuration.nix ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos"; # Define your hostname.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  time.timeZone = "America/Sao_Paulo";

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "br-abnt2";
  };

  fonts = {
    fontDir.enable = true;
    fonts = with pkgs; [
       siji
       (nerdfonts.override { fonts = [ "Meslo" ]; })
    ];
  };

  programs.hyprland = {
      enable = true;
      # xwayland = {
      #     enable = true;
      #     hidpi = true;
      # };
  };

  # services.xserver = {
  #   enable = true;
  #   desktopManager.xterm.enable = false;
  #   windowManager.i3 = {
  #       enable = true;
  #       configFile = /home/renan/.config/i3/config;
  #       extraPackages = with pkgs; [
  #           dmenu
  #           i3status
  #           i3lock
  #       ];
  #   };
  #   displayManager = {
  #       sddm.enable = true;
  #       defaultSession = "none+i3";
  #   };
  #   # Enable touchpad support (enabled default in most desktopManager).
  #   # services.xserver.libinput.enable = true;
  # };

  programs.xss-lock = {
    enable = true;
    lockerCommand = "${pkgs.betterlockscreen}/bin/betterlockscreen";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users = {
    defaultUserShell = pkgs.zsh;
    users.renan = {
      isNormalUser = true;
      extraGroups = [ "wheel" "disk" "docker" "audio" "video" "input" "systemd-journal" "networkmanager" "network" ];
    };
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # General
    bat
    curl
    fd
    fzf
    gtk-engine-murrine
    gtk_engines
    hyprpaper
    man
    openvpn
    ripgrep
    sudo
    sshfs
    unzip
    wget
    wofi
    xsel

    # Git
    git
    gh
    yadm

    # GNU Compiler Collection and more stuff
    libgccjit
    gnumake
    llvmPackages_16.stdenv
    gcc13Stdenv
    gcc

    # Apps
    firefox
    spotify
    # microsoft-edge

    # Terminal/Shell
    kitty
    tmux
    zsh
    zsh-autosuggestions
    zsh-powerlevel10k
    zsh-syntax-highlighting

    # Editors
    neovim
    vim
    helix

    # Programming
    nodejs
    python3
    rustup

    # Customization
    playerctl
    betterlockscreen
    polybar
  ];

  environment.variables = {
    EDITOR = "nvim";
  };

  programs.zsh = {
      enable = true;
      interactiveShellInit = ''
          source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh
          source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
          source ${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
          if [ -f ~/.zsh_aliases ]; then
              . ~/.zsh_aliases
          fi
      '';
      ohMyZsh = {
          enable = true;
          plugins = [
              "autojump"
              "colored-man-pages"
              "colorize"
              "command-not-found"
              "copybuffer"
              "copyfile"
              "copypath"
              "dirhistory"
              "extract" 
              "fancy-ctrl-z"
              "fd"
              "fzf"
              "git"
              "ripgrep"
              "rust"
              "tmux"
          ];
      };
  };

  programs.autojump.enable = true;
  
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It's perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}

