#!/bin/bash
URL=$1
cd ~/
REMOTE=$(git remote)
echo "Purging history"
rm -rf .git
rm -rf .gitignore
git init
if [[ -n "$URL" ]]; then
	git remote add origin $URL
	echo "Git remote set as $URL"
elif [[ -n "$REMOTE" ]]; then
	git remote add origin $URL
 	echo "Using existing remote $REMOTE"
else 
	echo "Git remote not set"
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
echo "Exclude cache files"
echo "**/*Cache*">>.gitignore
echo "**/*cache*">>.gitignore
echo "versioning system config files"
echo "This might take awhile (~10 minutes)"
git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
.local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap 
if [[ $? -eq '0' ]]; then
	echo "git add success"
else 
	echo $?
	echo "git add failed"
	echo "This sometimes happens when config files change during add"
	echo "Retrying once"
	git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
	.local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap 
	if [[ $? -eq '0' ]]; then
		echo "git add success"
	else
		echo "Retry unsuccessful"
		echo "Exiting"
		exit
	fi
fi
#create remember.sh script
cd $DIR
cp remember.sh ~/remember.sh
cd ~/
git add remember.sh
echo "commiting"
git commit -q -am "auto update"
echo "pushing to remote"
echo "this might take awhile"
git branch -M main
git push -u origin main -f
rm remember.sh
exit


