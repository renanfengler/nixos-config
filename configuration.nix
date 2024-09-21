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

    hardware.opengl.enable = true;
    services.xserver.videoDrivers = ["nvidia"];
    hardware.nvidia = {
        modesetting.enable = true;
        powerManagement.enable = false;
        powerManagement.finegrained = false;
        open = false;
        nvidiaSettings = true;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
    };

# Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelModules = ["uinput"];
    services = {
        cron = {
            enable = true;
            systemCronJobs = [
                "25 12 * * * docker exec nova-arquitetura-subscriptions-api-1 sh -c \"bin/console subscriptions:cancel-subscription\""
            ];
        };
        flatpak.enable = true;
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
        # networkmanager.dns = "none";
        # nameservers = ["8.8.8.8"];
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
        packages = with pkgs; [
            siji
            (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
        ];
    };

# Enable sound.
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
        bottom
        brightnessctl
        dunst
        eww
        eza
        fastfetch
        fd
        fzf
        grc
        grim # for screenshots
        gtypist
        hyprpaper
        imagemagick
        libnotify
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
        waybar

# Git
        gh
        git
        lazygit
        yadm

# Linux stuff
        alsa-lib.out
        at-spi2-atk.out
        btrfs-progs
        cairo.out
        cmake
        cups.lib
        dbus.lib
        egl-wayland
        expat.out
        gcc11
        gcc11Stdenv
        glib
        glibc
        glibc.out
        gnumake
        gtk3.out
        libdrm.out
        libstdcxx5
        libxkbcommon.out
        llvmPackages_17.stdenv
        mesa.out
        nspr.out
        nss.out
        pango.out
        util-linux
        xorg.libX11.out
        xorg.libXcomposite.out
        xorg.libXdamage.out
        xorg.libXext.out
        xorg.libXfixes.out
        xorg.libXrandr.out
        xorg.libxcb.out

# Apps
        firefox
        libreoffice
        slack
        spotify

# Terminal/Shell
        gum
        httpie
        kitty
        thefuck
        tmux
        zoxide
        zsh-powerlevel10k

# Editors
        neovim

# Programming
        fnm
        go
        insomnia
        lefthook
        lua
        meld
        php83
        php83Extensions.ds
        php83Packages.composer
        python3
        python312Packages.pip
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
            source ${pkgs.oh-my-zsh}/share/oh-my-zsh/plugins/zsh-interactive-cd/zsh-interactive-cd.plugin.zsh
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme

            export PATH=$PATH:$HOME/.local/bin
            export PATH=$PATH:$HOME/.config/yarn/global/node_modules/.bin/
            export PATH=$PATH:$HOME/.cargo/bin/
            export PATH=$PATH:$HOME/go/bin/

            [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
            fpath+=${ZDOTDIR:-~}/.zsh_functions

            eval "$(zoxide init --cmd cd zsh)"
            eval $(thefuck --alias)
            export PATH="/home/renan/.local/share/fnm:$PATH"
            eval "`fnm env`"
        '';
        ohMyZsh = {
            enable = true;
            plugins = [
                "colored-man-pages"
                "copybuffer"
                "copyfile"
                "copypath"
                "dirhistory"
                "extract" 
                "fancy-ctrl-z"
                "fzf"
                "git"
                "rust"
                "tmux"
                "zoxide"
            ];
        };
        shellAliases = {
            # General stuff
            lg = "lazygit";
            ly = "lg -w ~ -g ~/.local/share/yadm/repo.git";
            n = "nvim";
            connectwifi = "sudo nmcli dev wifi connect";
            rmorig = "rm **/*.orig";
            ls = "eza --icons='always'";
            ll = "ls --long --header --git";
            la = "ll -a";
            tree = "ls --tree --git-ignore";
            t = "tmux";

            # Kitty
            icat = "kitty +kitten icat";
            s = "kitty +kitten ssh";

            #Git
            gac = "git add ./";
            gca = "git commit --amend --no-edit";
            yl = "yadm pull";
            yp = "yadm push";
            git-get-task = "git log --pretty=format:\"%s\" --author=\"renan*\" | fzf | rg -o \"\\[.*\\]\" | xargs wl-copy";

            # Neovim
            nswap = "rm ~/.local/state/nvim/swap/*";
            nff = "nvim '+Telescope find_files'";

            # Docker
            dps = "docker compose ps";
            dcup = "docker compose up -d";
            ddown = " docker compose down";
            testerdown = "docker compose -p api-tester down";

            mtester = "sudo mount -t ramfs none /home/renan/src/nova-arquitetura/dev-utils/data/api-tester/mysql";
            umtester = "sudo umount /home/renan/src/nova-arquitetura/dev-utils/data/api-tester/mysql";
            stester = "rm -f /home/renan/src/nova-arquitetura/dev-utils/data/api-tester/snapshots/*";
        };
        syntaxHighlighting.enable = true;
    };

    programs.hyprland = {
        enable = true;
    };

# Permite executar binários "normais" no nix
# https://github.com/Mic92/nix-ld
# https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
    programs.nix-ld = {
        enable = true;
        libraries = [
            pkgs.stdenv.cc.cc.lib
            pkgs.glib
            pkgs.nss
            pkgs.nspr
            pkgs.at-spi2-atk
            pkgs.cups
            pkgs.dbus
            pkgs.libdrm
            pkgs.gtk3
            pkgs.pango
            pkgs.cairo
            pkgs.xorg.libX11
            pkgs.xorg.libXcomposite
            pkgs.xorg.libXdamage
            pkgs.xorg.libXext
            pkgs.xorg.libXfixes
            pkgs.xorg.libXrandr
            pkgs.mesa
            pkgs.expat
            pkgs.xorg.libxcb
            pkgs.libxkbcommon
            pkgs.alsa-lib
        ];
    };

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
