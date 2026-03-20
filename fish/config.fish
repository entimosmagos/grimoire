# CachyOS base config
source /usr/share/cachyos-fish-config/cachyos-config.fish

# Disable greeting (silence on entry)
function fish_greeting
    fastfetch
end

# Aliases
alias hx='helix'

# --- COLOR SYSTEM (muted, ink-like) ---

# Core palette
set -g fish_color_command cba6f7
set -g fish_color_param b39ddb
set -g fish_color_error f38ba8
set -g fish_color_quote a6e3a1
set -g fish_color_redirection cba6f7
set -g fish_color_end cba6f7
set -g fish_color_operator cba6f7
set -g fish_color_escape cba6f7
set -g fish_color_autosuggestion 3a3445

# Optional: make directories softer
set -g fish_color_cwd d6d1c4

# --- PROMPT (your "voice") ---

function fish_prompt
    set_color 7a5cff
    echo -n "∴ "

    set_color d6d1c4
    echo -n (basename (pwd))

    set_color normal
    echo -n " "
end

# --- OPTIONAL: subtle startup (keep or remove) ---
# comment this out if you want full silence
python3 ~/.config/fastfetch/animate.py
