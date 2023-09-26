# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

{
    nixpkgs.config.allowUnfree = true;
    imports = [ ./hardware-configuration.nix ];

    nix.settings.experimental-features = ["nix-command" "flakes"];

# Permite executar binários "normais" no nix
# https://github.com/Mic92/nix-ld
# https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
    programs.nix-ld.enable = true;

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
    };

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

    environment.systemPackages = with pkgs; [
# General
        acpi # bateria
        bat #cat melhoradi
        curl
        exa # ls melhorado
        fd
        fzf
        hyprpaper
        openvpn
        ripgrep
        sudo
        unzip
        wget
        wofi # launcher
        wl-clipboard

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
        pamixer #mixer para pulseaudio
        betterlockscreen
        eww-wayland
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
            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
            if [ -f ~/.zsh_aliases ]; then
                . ~/.zsh_aliases
            fi
        '';
        ohMyZsh = {
            enable = true;
            plugins = [
                "autojump"
                "colored-man-pages"
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

