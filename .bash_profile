#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# start display environment when logged in and configuration exists
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]] && [[ -f ~/.xinitrc ]] && [[ -f /usr/bin/startx ]]; then
  startx
fi
