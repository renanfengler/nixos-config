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
    };
    environment.sessionVariables = { LIBVA_DRIVER_NAME = "iHD"; };

# Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.kernelModules = ["uinput"];
    services = {
        cron = {
            enable = true;
            systemCronJobs = [ ];
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

        tlp = {
            enable = true;
            settings = {
                CPU_SCALING_GOVERNOR_ON_AC = "performance";
                CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

                CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
                CPU_ENERGY_PERF_POLICY_ON_AC = "performance";

                CPU_MIN_PERF_ON_AC = 0;
                CPU_MAX_PERF_ON_AC = 100;
                CPU_MIN_PERF_ON_BAT = 0;
                CPU_MAX_PERF_ON_BAT = 40;

                #Optional helps save long term battery health
                START_CHARGE_THRESH_BAT0 = 40; # 40 and bellow it starts to charge
                STOP_CHARGE_THRESH_BAT0 = 80; # 80 and above it stops charging
            };
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
            nerd-fonts.dejavu-sans-mono
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
        hyprsome
        imagemagick
        libnotify
        p7zip
        playerctl
        pwvucontrol
        pyprland
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
        cmake
        egl-wayland
        gcc11
        gcc11Stdenv
        glibc
        glibc.out
        gnumake
        llvmPackages_17.stdenv
        util-linux

# Apps
        firefox
        mpv
        qbittorrent
        spotify

# Terminal/Shell
        gum
        httpie
        kitty
        oh-my-posh
        tmux
        zoxide

# Editors
        neovim

# Programming
        atlas
        cargo
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
            H = "Hyprland";

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
    };
    services.hypridle.enable = true;

# Permite executar binários "normais" no nix
# https://github.com/Mic92/nix-ld
# https://unix.stackexchange.com/questions/522822/different-methods-to-run-a-non-nixos-executable-on-nixos/522823#522823
    programs.nix-ld = {
        enable = true;
        libraries = [
            pkgs.stdenv.cc.cc.lib
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
