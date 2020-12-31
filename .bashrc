#
# ~/.bashrc
#

# general global definitions
export EDITOR=nano
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export WINEPREFIX="$HOME/.local/wine"
export WINEDEBUG=fixme-all,warn-all,err-all

# append dotnet tools to user paths
if ! [[ "$PATH" =~ ":$HOME/.dotnet/tools" ]]; then
  export PATH="$PATH:$HOME/.dotnet/tools"
fi

# append local bin to user paths
if ! [[ "$PATH" =~ ":$HOME/.local/bin" ]]; then
  export PATH="$PATH:$HOME/.local/bin"
fi

# install/update AUR package(s)
function aur() {
    [[ -d "$HOME/.local/build" ]] || mkdir "$HOME/.local/build"
    while (( "$#" )); do
        if [[ $(git ls-remote "https://aur.archlinux.org/$1.git" | wc -l) -gt 0 ]]; then
            git clone "https://aur.archlinux.org/$1.git" "$HOME/.local/build/$1.aur" || true
            pushd "$HOME/.local/build/$1.aur"
            git pull --no-rebase || true
            makepkg -si --needed --noconfirm
            popd
        else
            echo "AUR package $1 not found."
        fi
        shift
    done
}
export -f aur

# update all AUR packages
function aur_upd() {
    [[ -d "$HOME/.local/build" ]] || mkdir "$HOME/.local/build"
    find "$HOME/.local/build" -maxdepth 1 -name "*.aur" -type d | while read -r line; do
        pushd "$line"
        git pull --no-rebase || true
        makepkg -si --needed --noconfirm
        popd
    done
}
export -f aur_upd

# open manual as pdf
function manpdf() {
  man -t "$1" | ps2pdf - /tmp/"$1.pdf"
  firefox -new-window /tmp/"$1.pdf" &
}
export -f manpdf

# weather forecast as shell output
# pro tip: write ".png" at the end of the city name
#          to get the result as image and pipe it to
#          a file or process
function wttr()
{
    local request="wttr.in/${1-}?2FAQ"
    [ "$(tput cols)" -lt 125 ] && request+='n'
    curl -H "Accept-Language: ${LANG%_*}" --compressed "$request"
}
export -f wttr

# alias and color stuff
alias ls='ls --color=auto'
alias ll='ls -l --color=auto'
alias la='ls -la --color=auto'
alias diff='diff --color=auto'
alias grep='grep --color=auto'
alias ip='ip -color=auto'
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias newpasswd='xkcdpass -w ger-anlx -n 4'
if [[ $(id -u) -eq 0 ]]; then
  PS1='\[\e[;31m\][\u@\h \W]\$\[\e[m\] '
else
  PS1='\[\e[;32m\][\u@\h \W]\$\[\e[m\] '
fi
