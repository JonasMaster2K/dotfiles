if status is-interactive

    # ── Greeting ──────────────────────────────────────────────────────────────
    set fish_greeting

    # ── Prompt ────────────────────────────────────────────────────────────────
    starship init fish | source

    # ── Kitty: sequences für AGS theme sync ───────────────────────────────────
    if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    end

    # ── Umgebung ───────────────────────────────────────────────────────────────
    set -gx EDITOR nvim
    set -gx VISUAL nvim
    set -gx PAGER less

    # ── PATH ───────────────────────────────────────────────────────────────────
    fish_add_path ~/.local/bin

    # ── Farben (fish built-in syntax highlighting) ─────────────────────────────
    set -g fish_color_command        blue
    set -g fish_color_param          normal
    set -g fish_color_error          red --bold
    set -g fish_color_comment        brblack
    set -g fish_color_autosuggestion brblack

    # ── Aliases ────────────────────────────────────────────────────────────────
    # clear: kitty-kompatibel (scrollback + sichtbaren Buffer leeren)
    alias clear "printf '\033[2J\033[3J\033[1;1H'"

    # ls: eza mit Icons
    alias ls  'eza --icons'
    alias ll  'eza --icons -la'
    alias lt  'eza --icons --tree --level=2'

    # ── Abbreviations (werden im Terminal sichtbar expandiert) ─────────────────
    # pacman
    abbr -a pS  'sudo pacman -S'        # installieren
    abbr -a pSs 'pacman -Ss'            # suchen
    abbr -a pSu 'sudo pacman -Syu'      # system update
    abbr -a pRs 'sudo pacman -Rns'      # entfernen inkl. deps
    abbr -a pQo 'pacman -Qo'            # welches paket besitzt datei?
    abbr -a pQl 'pacman -Ql'            # dateien eines pakets

    # git
    abbr -a g    git
    abbr -a gs   'git status'
    abbr -a ga   'git add'
    abbr -a gc   'git commit -m'
    abbr -a gca  'git commit --amend --no-edit'
    abbr -a gp   'git push'
    abbr -a gpl  'git pull'
    abbr -a gl   'git log --oneline --graph --decorate -15'
    abbr -a gd   'git diff'
    abbr -a gds  'git diff --staged'
    abbr -a gco  'git checkout'
    abbr -a gsw  'git switch'
    abbr -a gb   'git branch'
    abbr -a gst  'git stash'
    abbr -a gstp 'git stash pop'

    # quickshell
    abbr -a q 'qs -c ii'

    # typos
    abbr -a pamcan pacman
    abbr -a celar  clear
    abbr -a claer  clear

end