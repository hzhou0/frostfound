#!/bin/bash
tput clear
URL=$1
cd ~/
REMOTE=$(git remote)
tput smso; tput setaf 7;echo "Starting frostfound backup"
tput setaf 4;echo "Purging history";tput sgr0
rm -rf .git
rm -rf .gitignore
git init
if [[ -n "$URL" ]]; then
	git remote add origin $URL
	tput smso; tput setaf 4;echo "Git remote set as $URL";tput sgr0
elif [[ -n "$REMOTE" ]]; then
	git remote add origin $URL
 	tput smso; tput setaf 4;echo "Using existing remote $REMOTE"
else 
	tput smso; tput setaf 1;echo "Git remote not set"
	echo "Exiting"
	exit
fi
sudo rm -rf .frostfound
mkdir .frostfound -p
dconf dump / > ~/.frostfound/donf-backup.txt
#get deb packeges
apt list --installed --manual-installed | grep -F \[installed\] | awk -F/ '{print $1}'> ~/.frostfound/packagelist.txt
#import keys
sudo cp -R /etc/apt/sources.list.d/ ~/.frostfound/
sudo cp -R /etc/apt/trusted.gpg.d/ ~/.frostfound/
sudo cp /etc/apt/sources.list ~/.frostfound/sources.txt
sudo apt-key exportall > ~/.frostfound/Repo.keys
DIR=$(dirname $0)
#get flatpaks
flatpak list --app --columns application> ~/.frostfound/flatpaklist.txt
#get snapes
snap list | awk '!/disabled/{print $1}' | awk '{if(NR>1)print}'>~/.frostfound/snaplist.txt
echo "**/*Cache*">>.gitignore
echo "**/*cache*">>.gitignore
tput smso; tput setaf 4;echo "Versioning system config files(excluding cache files)"
echo "This might take awhile (~10 minutes)";tput sgr0
git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
.local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap 
if [[ $? -eq '0' ]]; then
	tput smso; tput setaf 2; echo "git add success";tput sgr0 
else 
	tput smso; tput setaf 3; echo $?
	echo "git add failed"
	echo "This sometimes happens when config files change during add"
	echo "Retrying once";tput sgr0 
	git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
	.local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap 
	if [[ $? -eq '0' ]]; then
		tput smso; tput setaf 2;echo "git add success";tput sgr0 
	else
		tput smso; tput setaf 1;echo "Retry unsuccessful"
		echo "Exiting"
		exit
	fi
fi
#create remember.sh script
cd $DIR
cp remember.sh ~/remember.sh
cd ~/
git add remember.sh
tput smso; tput setaf 4;echo "commiting";tput sgr0 
git commit -q -am "auto update"
tput smso; tput setaf 4;echo "Pushing to remote(this might take awhile)";tput sgr0 
git branch -M main
git push -u origin main -f
rm remember.sh
exit


