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
        graphics = {
            enable = true;
            enable32Bit = true;
        };
    };

    boot = {
        plymouth = {
            enable = true;
            theme = "spin";
            themePackages = with pkgs; [
                # By default we would install all themes
                (adi1090x-plymouth-themes.override {
                    selected_themes = [ "spin" ];
                })
            ];
        };

        # Enable "Silent boot"
        consoleLogLevel = 3;
        initrd.verbose = false;
        kernelParams = [
            "quiet"
            "splash"
            "boot.shell_on_fail"
            "udev.log_priority=3"
            "rd.systemd.show_status=auto"
        ];
        # Hide the OS choice for bootloaders.
        # It's still possible to open the bootloader list by pressing any key
        # It will just not appear on screen unless a key is pressed
        loader.timeout = 0;

        # Use the systemd-boot EFI boot loader.
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;

        kernelModules = ["uinput"];
        kernelPackages = pkgs.linuxPackages_zen;
    };

    services = {
        cron = {
            enable = false;
            systemCronJobs = [ ];
        };

        flatpak.enable = false;

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
            wireplumber = {
                enable = true;
            };
        };

        ratbagd = {
            enable = true;
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
            nerd-fonts.geist-mono
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

        # Veio da página do pipewire do nixos
        rtkit.enable = true;
    };

    # $ nix search <package name>
    environment.systemPackages = with pkgs; [
# General
        bat
        bc
        bottom
        brightnessctl
        cliphist
        dust
        dunst
        evince # pdf reader
        eza
        fastfetch
        fd
        fzf
        grc
        grim # for screenshots
        gtypist
        imagemagick
        jq
        libnotify
        p7zip
        playerctl
        pwvucontrol
        pyprland
        ripgrep
        rofi
        libqalculate # calculator
        slurp # for screenshots
        socat
        sudo
        swww
        tealdeer
        unrar
        unzip
        waybar
        wev
        wget
        wl-clipboard
        xdg-utils
        xremap
        yazi

#Hyprland stuff
        # hyprpaper
        # hyprsome
        hyprcursor
        hyprlock
        hyprpanel
        hyprpolkitagent
        hyprsunset

# Git
        gh
        git
        lazygit
        yadm

# Linux stuff
        at
        cmake
        egl-wayland
        gcc
        gccStdenv
        glibc
        glibc.out
        libGL
        libGL.out
        gnumake
        SDL2
        util-linux
        wine-wayland

# Apps
        dsda-doom
        firefox
        heroic-unwrapped
        mpv
        pcsx2
        qbittorrent
        rpcs3
        spotify
        uzdoom

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
            bindkey -v
            export PATH=$PATH:$HOME/.local/bin
            export PATH=$PATH:$HOME/.yarn/bin/
            export PATH=$PATH:$HOME/.cargo/bin/
            export PATH=$PATH:$HOME/go/bin/

            fpath+=${ZDOTDIR:-~}/.zsh_functions

            eval "$(zoxide init --cmd cd zsh)"
            export PATH="$HOME/.local/share/fnm:$PATH"
            eval "`fnm env`"
            eval "$(oh-my-posh init zsh --config ~/.config/oh-my-posh/main.toml)"

            export DOOM_WAD=$HOME/doom/iwads/DOOM.WAD
            export DOOM2_WAD=$HOME/doom/iwads/DOOM2.WAD
            export PLUTONIA_WAD=$HOME/doom/iwads/PLUTONIA.WAD
            export TNT_WAD=$HOME/doom/iwads/TNT.WAD
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
            H = "start-hyprland";
            nnix = "nvim /etc/nixos/configuration.nix";

            # Kitty
            icat = "kitty +icat";
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
            pkgs.glibc
            pkgs.libGL
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
    system.stateVersion = "25.11"; # Did you read the comment?
}
