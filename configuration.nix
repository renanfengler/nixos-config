# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running `nixos-help`).

{ config, pkgs, ... }:

{
    nixpkgs.config.allowUnfree = true;
    imports = [ ./hardware-configuration.nix ];

    nix.settings.experimental-features = ["nix-command" "flakes"];

    fileSystems."/mnt/externo" = {
        device = "/dev/sdc1";
        fsType = "ntfs";
        options = [
            "users"
            "nofail"
        ];
    };

    hardware = {
        bluetooth = {
            enable = true;
        };
        graphics.enable = true;
        nvidia = {
            modesetting.enable = true;
            powerManagement.enable = false;
            powerManagement.finegrained = false;
            open = false;
            nvidiaSettings = true;
            package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
                # Igual ao production
                version = "550.127.05";
                sha256_64bit = "sha256-04TzT10qiWvXU20962ptlz2AlKOtSFocLuO/UZIIauk=";
                sha256_aarch64 = "sha256-3wsGqJvDf8io4qFSqbpafeHHBjbasK5i/W+U6TeEeBY=";
                openSha256 = "sha256-r0zlWPIuc6suaAk39pzu/tp0M++kY2qF8jklKePhZQQ=";
                settingsSha256 = "sha256-cUSOTsueqkqYq3Z4/KEnLpTJAryML4Tk7jco/ONsvyg=";
                persistencedSha256 = "sha256-8nowXrL6CRB3/YcoG1iWeD4OCYbsYKOOPE374qaa4sY=";

                # version = "550.40.07";
                # sha256_64bit = "sha256-KYk2xye37v7ZW7h+uNJM/u8fNf7KyGTZjiaU03dJpK0=";
                # sha256_aarch64 = "sha256-AV7KgRXYaQGBFl7zuRcfnTGr8rS5n13nGUIe3mJTXb4=";
                # openSha256 = "sha256-mRUTEWVsbjq+psVe+kAT6MjyZuLkG2yRDxCMvDJRL1I=";
                # settingsSha256 = "sha256-c30AQa4g4a1EHmaEu1yc05oqY01y+IusbBuq+P6rMCs=";
                # persistencedSha256 = "sha256-11tLSY8uUIl4X/roNnxf5yS2PQvHvoNjnd2CB67e870=";

                # version = "555.58.02";
                # sha256_64bit = "sha256-xctt4TPRlOJ6r5S54h5W6PT6/3Zy2R4ASNFPu8TSHKM=";
                # sha256_aarch64 = "sha256-wb20isMrRg8PeQBU96lWJzBMkjfySAUaqt4EgZnhyF8=";
                # openSha256 = "sha256-8hyRiGB+m2hL3c9MDA/Pon+Xl6E788MZ50WrrAGUVuY=";
                # settingsSha256 = "sha256-ZpuVZybW6CFN/gz9rx+UJvQ715FZnAOYfHn5jt5Z2C8=";
                # persistencedSha256 = "sha256-a1D7ZZmcKFWfPjjH1REqPM5j/YLWKnbkP9qfRyIyxAw=";

            };
        };
    };

    services.xserver.videoDrivers = ["nvidia"];

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

        openssh.enable = true;

        acpid = {
            enable = true;
        };

        pipewire = {
            enable = true;
            alsa = {
                enable = true;
                support32Bit = true;
            };
            pulse.enable = true;
        };
    };

    networking = {
        hostName = "nixos"; # Define your hostname.
        networkmanager.enable = true;  # Easiest to use and most distros use this by default.
        # networkmanager.dns = "none";
        # nameservers = ["8.8.8.8"];
        extraHosts = ''
            127.0.0.1       localhost
            127.0.1.1       nixos
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

    virtualisation.docker.enable = true;

    users = {
        defaultUserShell = pkgs.zsh;
        users.renan = {
            isNormalUser = true;
            extraGroups = [ "wheel" "disk" "docker" "audio" "video" "input" "systemd-journal" "networkmanager" "network" ];
        };
    };

    security = {
        pam.services.swaylock = {
            text = ''
            auth include login
            '';
        };
        rtkit.enable = true;
    };

    # $ nix search <package name>
    environment.systemPackages = with pkgs; [
# General
        bat
        bottom
        brightnessctl
        du-dust
        dunst
        eww
        eza
        fastfetch
        fd
        fzf
        grc
        grim # for screenshots
        gtypist
        hyprcursor
        hyprpaper
        imagemagick
        libnotify
        p7zip
        playerctl
        pyprland
        pwvucontrol
        ripgrep
        slurp # for screenshots
        socat
        sudo
        unrar
        unzip
        waybar
        wget
        wl-clipboard
        wofi
        xdg-utils

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
        duckstation
        dsda-doom
        firefox
        heroic-unwrapped
        mpv
        pcsx2
        qbittorrent
        spotify

# Terminal/Shell
        gum
        httpie
        kitty
        oh-my-posh
        thefuck
        tmux
        zoxide

# Editors
        neovim

# Programming
        fnm
        go
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
    environment.sessionVariables.NIXOS_OZONE_WL = "1";

    programs.zsh = {
        enable = true;
        autosuggestions.enable = true;
        interactiveShellInit = ''
            export PATH=$PATH:$HOME/.local/bin
            export PATH=$PATH:$HOME/.config/yarn/global/node_modules/.bin/
            export PATH=$PATH:$HOME/.cargo/bin/
            export PATH=$PATH:$HOME/go/bin/

            fpath+=${ZDOTDIR:-~}/.zsh_functions

            eval "$(zoxide init --cmd cd zsh)"
            eval $(thefuck --alias)
            export PATH="$HOME/.local/share/fnm:$PATH"
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
        };
        syntaxHighlighting.enable = true;
    };

    programs.hyprland = {
        enable = true;
        xwayland.enable = true;
    };
    services.hypridle.enable = true;

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

    programs.steam = {
        enable = true;
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
