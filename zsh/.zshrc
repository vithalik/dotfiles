# Periodic auto-update on Zsh startup: 'ask' or 'no'.
# You can manually run `z4h update` to update everything.
zstyle ':z4h:' auto-update      'no'
# Ask whether to auto-update this often; has no effect if auto-update is 'no'.
zstyle ':z4h:' auto-update-days '28'

# Keyboard type: 'mac' or 'pc'.
zstyle ':z4h:bindkey' keyboard  'pc'

# Don't start tmux.
zstyle ':z4h:' start-tmux       no

# Mark up shell's output with semantic information.
zstyle ':z4h:' term-shell-integration 'yes'

# Right-arrow key accepts one character ('partial-accept') from
# command autosuggestions or the whole thing ('accept')?
zstyle ':z4h:autosuggestions' forward-char 'accept'

# Recursively traverse directories when TAB-completing files.
zstyle ':z4h:fzf-complete' recurse-dirs 'no'
# zstyle ':z4h:fzf-complete' fzf-bindings tab:repeat

# Enable direnv to automatically source .envrc files.
zstyle ':z4h:direnv'         enable 'yes'
# Show "loading" and "unloading" notifications from direnv.
zstyle ':z4h:direnv:success' notify 'yes'

# Enable ('yes') or disable ('no') automatic teleportation of z4h over
# SSH when connecting to these hosts.
zstyle ':z4h:ssh:example-hostname1'   enable 'yes'
zstyle ':z4h:ssh:*.example-hostname2' enable 'no'

zstyle ':z4h:ssh:192.168.31.104' enable 'yes'
zstyle ':z4h:ssh:192.168.31.84' enable 'yes'
zstyle ':z4h:ssh:localhost' enable 'yes'

# The default value if none of the overrides above match the hostname.
zstyle ':z4h:ssh:*'                   enable 'no'

# Send these files over to the remote host when connecting over SSH to the
# enabled hosts.
zstyle ':z4h:ssh:*' send-extra-files '~/.nanorc' '~/.env.zsh'

# Install or update core components (fzf, zsh-autosuggestions, etc.) and
# initialize Zsh. After this point console I/O is unavailable until Zsh
# is fully initialized. Everything that requires user interaction or can
# perform network I/O must be done above. Everything else is best done below.
z4h init || return

# Extend PATH.
path=(~/dotfiles/scripts/ $path)

# Export environment variables.
export GPG_TTY=$TTY
export BROWSER=brave-beta
export EDITOR=nvim
export PAGER='moar -style dracula -no-linenumbers'
export MANPAGER='nvim +Man!'
export TERM=xterm-256color
export VISUAL=nvim
export BAT_THEME="Dracula"

export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export ANDROID_HOME="$XDG_DATA_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export GOPATH="$XDG_DATA_HOME/go"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
export LESSHISTFILE="$XDG_CACHE_HOME/less/history"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"
export PARALLEL_HOME="$XDG_CONFIG_HOME/parallel"
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export WINEPREFIX="$XDG_DATA_HOME/wine"

export PATH=$PATH:$HOME/.local/bin:$CARGO_HOME/bin:$PNPM_HOME:$XDG_DATA_HOME/npm/bin:$GOPATH/bin

export SOPS_AGE_RECIPIENTS=age1tnkh972ad6ddm6grzmjjnlcq90247r36ywq220y3ytnkw9aqwcsqzwxxu4

# Source additional local files if they exist.
z4h source ~/.env.zsh

# Define key bindings.
z4h bindkey z4h-backward-kill-word  Ctrl+Backspace     Ctrl+H
z4h bindkey z4h-backward-kill-zword Ctrl+Alt+Backspace

z4h bindkey undo Ctrl+/ Shift+Tab  # undo the last command line change
z4h bindkey redo Alt+/             # redo the last undone command line change

z4h bindkey z4h-cd-back    Alt+Left   # cd into the previous directory
z4h bindkey z4h-cd-forward Alt+Right  # cd into the next directory
z4h bindkey z4h-cd-up      Alt+Up     # cd into the parent directory
z4h bindkey z4h-cd-down    Alt+Down   # cd into a child directory

# Autoload functions.
autoload -Uz zmv

# Define functions and completions.
function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

alias bt='bluetoothctl'
alias drop='dragon-drop -x -a'
alias cat='bat -pp'
alias d='cd ~/dotfiles/'
alias dev='pnpm run dev --host'
alias fd='fd -HI'
alias fm='yazi'
alias fzf='fzf --preview "bat --color=always {}" --preview-window=right:60%:wrap'
alias gc='git clone'
alias gp='git pull'
alias i='paru -S'
alias lg='lazygit'
alias ll='eza -a --icons --group-directories-first -s ext --long'
alias ls='eza -a --icons --group-directories-first -s ext'
alias lsblk='lsblk -o NAME,MODEL,SIZE,FSTYPE,MOUNTPOINTS,FSUSE%'
alias lt='eza -T -L=2 -a --icons --group-directories-first'
alias mkdir='mkdir -p'
alias n='cd ~/projects/newtonlabs'
alias nix='noglob nix'
alias o='z obsidian && nvim todo.md'
alias p='cd ~/projects'
alias pipreqs='python -m pipreqs.pipreqs --force'
alias qalc='qalc -t'
alias r='paru -Rs'
alias rebuild='sudo nixos-rebuild switch --flake ~/dotfiles/nixos/ --quiet --quiet'
alias rg='rg --hidden --no-ignore --no-messages'
alias rmf='rm -rf'
alias ssh-coolify='ssh igor@192.168.31.84'
alias ssh-homelab='ssh igor@192.168.31.104'
alias ssh-kodi='ssh root@192.168.31.26'
alias ssh-mac='ssh -p 22220 igor@localhost'
alias ssh-printer='ssh igor@192.168.31.19'
alias ssh-proxmox='ssh root@192.168.31.151'
alias ssh-racknerd='ssh root@172.245.180.243'
alias ssh-router='ssh root@192.168.31.1'
alias ssh-tv='ssh root@192.168.31.81'
alias stow='stow --no-folding -Rv'
alias sv='sudoedit'
alias udiskmount='udisksctl mount -b'
alias update='sudo nix flake update --flake ~/dotfiles/nixos && rebuild'
alias v.='nvim .'
alias v='nvim'
alias wgdown='basename /proc/sys/net/ipv4/conf/*vpn | xargs sudo wg-quick down'
alias wgup='sudo wg-quick up'

# Set shell options: http://zsh.sourceforge.net/Doc/Release/Options.html.
setopt glob_dots     # no special treatment for file names with a leading dot
setopt auto_menu  # require an extra TAB press to open the completion menu

eval "$(fnm env --use-on-cd)"
eval "$(zoxide init zsh)"
