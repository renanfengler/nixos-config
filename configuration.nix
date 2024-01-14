# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, lib, ... }:

{
    nixpkgs.config.allowUnfree = true;
    imports = [ ./hardware-configuration.nix ];

    hardware.bluetooth = {
        enable = true;
    };

    nix.settings.experimental-features = ["nix-command" "flakes"];

# Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelModules = ["uinput"];
    services = {
        udev = {
            enable = true;
            extraRules = ''
                KERNEL=="uinput", GROUP="input", TAG+="uaccess"
            '';
        };

        openvpn.servers = {
            awiseVPN = {
                config = '' config /home/renan/src/vpn/client.ovpn '';
            };
        };

        openssh.enable = true; # Enable the OpenSSH daemon.
        printing.enable = true; # Enable CUPS to print documents.
        acpid = {
            enable = true;
        };
    };

    networking = {
        hostName = "nixos"; # Define your hostname.
        networkmanager.enable = true;  # Easiest to use and most distros use this by default.
        networkmanager.dns = "none";
        nameservers = ["8.8.8.8"];
        extraHosts = ''
            127.0.0.1       localhost s3
            127.0.1.1       nixos
            52.216.62.232   s3.amazonaws.com
        '';
    };

    time = {
        timeZone = "America/Sao_Paulo";
        hardwareClockInLocalTime = true;
    };
    i18n = {
        defaultLocale = "en_US.UTF-8";
        supportedLocales = [
            "en_US.UTF-8/UTF-8"
            "pt_BR.UTF-8/UTF-8"
        ];
    };
    console = {
        font = "Lat2-Terminus16";
        keyMap = "br-abnt2";
    };

    fonts = {
        fontDir.enable = true;
        fonts = with pkgs; [
            siji
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
    };

# Enable sound.
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    virtualisation.docker.enable = true;

    users = {
        defaultUserShell = pkgs.zsh;
        users.renan = {
            isNormalUser = true;
            extraGroups = [ "wheel" "disk" "docker" "audio" "video" "input" "systemd-journal" "networkmanager" "network" ];
        };
    };

    security.pam.services.swaylock = {
        text = ''
            auth include login
        '';
    };

    environment.systemPackages = with pkgs; [
# General
        bat
        brightnessctl
        dunst
        eww-wayland
        exa
        fd
        fzf
        grc
        grim # for screenshots
        hyprpaper
        imagemagick
        libnotify
        neofetch
        pamixer # mixer para pulseaudio
        playerctl
        ripgrep
        slurp # for screenshots
        socat
        sudo
        swayidle
        swaylock-effects
        unzip
        wget
        wl-clipboard
        wofi
        xdg-desktop-portal-hyprland
        xdg-utils

# Git
        gh
        git
        lazygit
        yadm

# Linux stuff
        btrfs-progs
        gcc
        gcc13Stdenv
        gnumake
        libgccjit
        llvmPackages_16.stdenv
        util-linux

# Apps
        firefox
        slack
        spotify

# Terminal/Shell
        gum
        kitty
        tmux
        zsh-powerlevel10k

# Editors
        neovim

# Programming
        go
        insomnia
        lefthook
        meld
        nodejs
        php82
        php82Extensions.ds
        php82Packages.composer
        python3
        rustup
        yarn
    ];

    environment.variables = {
        EDITOR = "nvim";
    };

    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        interactiveShellInit = ''
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh

            export PATH=$PATH:$HOME/.local/bin
            export PATH=$PATH:$HOME/.config/yarn/global/node_modules/.bin/
            export PATH=$PATH:$HOME/.cargo/bin/

            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
            fpath+=${ZDOTDIR:-~}/.zsh_functions
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
                "yarn"
            ];
        };
        shellAliases = {
            # General stuff
            lg = "lazygit";
            ly = "lg -w ~ -g ~/.local/share/yadm/repo.git";
            n = "nvim";
            ls = "exa";
            la = "exa -la";
            ll = "exa --long --header --git";
            tree = "exa --tree --git-ignore";
            connectwifi = "sudo nmcli dev wifi connect";
            rmorig = "rm **/*.orig";

            # Kitty
            icat = "kitty +kitten icat";
            s = "kitty +kitten ssh";

            #Git
            gac = "git add ./";
            gca = "git commit --amend --no-edit";
            yl = "yadm pull";
            yp = "yadm push";
            git-get-task = "git log --pretty=format:\"%s\" | fzf | rg -o \"\\[.*\\]\" | xargs wl-copy";

            # Neovim
            nswap = "rm ~/.local/state/nvim/swap/*";
            nff = "nvim '+Telescope find_files'";

            # Docker
            dps = "docker compose ps";
            testerdown = "docker compose -p api-tester down";

            mtester = "sudo mount -t ramfs none /home/renan/src/nova-arquitetura/dev-utils/data/api-tester/mysql";
            umtester = "sudo umount /home/renan/src/nova-arquitetura/dev-utils/data/api-tester/mysql";
        };
        syntaxHighlighting.enable = true;
    };

    programs.autojump.enable = true;

    programs.hyprland = {
        enable = true;
    };

# Permite executar binários "normais" no nix
# https://github.com/Mic92/nix-ld
# https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
    programs.nix-ld.enable = true;

# Some programs need SUID wrappers, can be configured further or are
# started in user sessions.
# programs.mtr.enable = true;
# programs.gnupg.agent = {
#   enable = true;
#   enableSSHSupport = true;
# };

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
