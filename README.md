# automated-install-linux-mint
This bash script will auto install selected desktop programs on Linux Mint - Tested with 20.2 Uma.

"chmod +x automated-install-linux-mint.sh" the file before starting, and make sure you run as root!

It will auto install the selected apps below: 

apt-transport-https, authy, backup (Déjà Dup), balena etcher, bleachbit, brave browser, chrome, curl, dconf-editor, dialog, deluge, filezilla, firefox, gdebi, gimp, git, gnupg, gparted, gufw, htop, libreoffice (calc & writer), mat2, nordpass, openvpn, plex, rkhunter, snap (package manager), snapd, synaptic, tilix, telegram, unrar, veracrypt, virtualbox, visual studio code, vlc, webtorrent, wget, y-ppa-manager, zip, zsh.

Get's my other scripts's (rkhunter-script & auto-update-ubuntu.sh)

oh my zsh is a great add-on to zsh: https://github.com/ohmyzsh/ohmyzsh

Also installs rkhunter (a rootkit hunter) which can be configured with the below link:

https://kifarunix.com/how-to-install-rkhunter-rootkit-hunter-on-ubuntu-18-04/

Remember to setup zsh, and add this to your root zshrc file (nano ~/.zshrc) & in your user home folder (/home/$USER/.zshrc).

alias l='ls'  
alias la='ls -a'  
alias ll='ls -al'   
alias aptupdate='dpkg --configure -a && apt update && apt upgrade -y && apt install -f && apt clean && apt autoclean && apt autoremove -y'      
alias sudo='sudo -s'  
alias servicestat='service --status-all'  
#alias plexstart='snap start plexmediaserver'    
#alias stopplex='snap stop plexmediaserver'    

then (source /root/.zshrc) & (source /home/$USER/.zshrc) to apply changes.
