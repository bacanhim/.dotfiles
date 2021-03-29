<div align="center">
    <h1>Dotfiles</h1>
    <blockquote>
        <p>My Arch Linux dotfiles.</p>
    </blockquote>
</div>

![do be added](./screenshots/desktop1.png)

## Installation

You can use [GNU Stow](https://www.gnu.org/software/stow/) to install the
dotfiles contained in this repository. Simply `cd` into your clone of this
repository and run the following command:

```
$ stow --target="$HOME" --no-folding .
```

By default, GNU Stow symlinks directories that don't exist in the target
directory, but with the `--no-folding` flag, GNU Stow will _create_ those
directories in your home directory, and only symlink actual files.

## Details

#### Graphical environment

- Window manager: [i3-gaps](https://github.com/Airblader/i3)
- Compositor: [picom](https://github.com/yshui/picom)
- Bar: [Polybar](https://github.com/polybar/polybar)
- Notification daemon: [Dunst](https://github.com/dunst-project/dunst)
- Program launcher: [Rofi](https://github.com/davatorium/rofi)
- Screen locker: [betterlockscreen](https://github.com/pavanjadhaw/betterlockscreen)

#### Fonts

- Sans-serif font: [Noto Sans](https://www.google.com/get/noto/)
- Serif font: [Noto Serif](https://www.google.com/get/noto/)
- Monospace font: [Consolas](https://aur.archlinux.org/packages/consolas-font)
- Icon font for bar: [Font Awesome](https://fontawesome.com/)

#### Command-line

- Shell: [Zsh](https://github.com/zsh-users/zsh)
- Terminal emulator: [Alacritty](https://github.com/jwilm/alacritty)

#### Development environment

- Primary code editor: [Visual Studio Code](https://github.com/microsoft/vscode)
- Secondary code editor: [Atom](https://github.com/atom/atom)
- Java IDE: [IntelliJ IDEA Community Edition](https://github.com/JetBrains/intellij-community)

#### Miscellaneous

- Web browser: [Firefox](https://www.mozilla.org/en-US/firefox/new/)
- File manager: [TERMINAL: ranger](https://github.com/ranger/ranger) [GUI: Thunar](https://github.com/xfce-mirror/thunar)
- Document viewer: [zathura](https://github.com/pwmt/zathura)
- Video player: [vlc](https://github.com/videolan/vlc)
- Screenshot tool: [Flameshot](https://github.com/lupoDharkael/flameshot)

#### Theme

- GTK theme: [Materia](https://github.com/nana-4/materia-theme)
- Cursor theme: [Capitaine cursors](https://github.com/keeferrourke/capitaine-cursors)
- [Wallpaper](https://unsplash.com/photos/ybw-0_Hfk1I)

![to be added](./screenshots/desktop2.png)

Inspired by: [OverMighty](https://github.com/OverMighty/dotfiles)