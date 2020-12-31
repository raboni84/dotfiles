#
# ~/.xinitrc
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

xset -b
xdg_menu --format awesome --root-menu /etc/xdg/menus/arch-applications.menu | awk -F, '{if (a!=$1) print $a; a=$1}' >~/.config/awesome/archmenu.lua
redshift -l 51:10 -t 6500:3500 &
xautolock -time 10 -locker slock_run -nowlocker slock &
flameshot &
exec awesome --no-argb
