# dotfiles

Catppuccin **Macchiato** everywhere: hyprland, hyprlock, waybar, swaync, rofi, kitty,
wezterm, i3, polybar, yazi, cava, bashtop, neovim, VS Code, fish, zsh and bash prompts.

Each top-level directory is a [GNU stow](https://www.gnu.org/software/stow/) package that
mirrors `$HOME` (e.g. `waybar/.config/waybar/...` → `~/.config/waybar/...`).

## Setup
1. Install `stow` (`sudo pacman -S stow` / `sudo apt install stow` / `brew install stow`).
2. Clone and stow the packages you want:
   ```sh
   git clone https://github.com/isGoodSoup/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   stow -vt ~ hypr waybar rofi kitty swaync yazi neovim bashrc zshrc
   ```

`nitch.sh` builds and installs [nitch](https://github.com/unxsh/nitch).
