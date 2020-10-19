#!/bin/bash
tput clear
cd ~/ || exit
REMOTE=$(git remote get-url origin)
tput smso; tput setaf 7;echo "Starting frostfound backup"
tput setaf 4;echo "Purging history";tput sgr0
rm -rf .git
rm -rf .gitignore
git init
if [[ -n "$1" ]]; then
	git remote add origin "$1"
	tput smso; tput setaf 4;echo "Git remote set as $1";tput sgr0
elif [[ -n "$REMOTE" ]]; then
	git remote add origin "$REMOTE"
 	tput smso; tput setaf 4;echo "Using existing remote $REMOTE";tput sgr0
else 
	tput smso; tput setaf 1;echo "Git remote not set"
	read -rp "Git remote(url): " REMOTE
	git remote add origin "$REMOTE"
	tput smso; tput setaf 4;echo "Git remote set as $REMOTE";tput sgr0
fi
sudo rm -rf .frostfound
mkdir .frostfound -p
dconf dump / > ~/.frostfound/donf-backup.txt
#get deb packages
apt list --installed --manual-installed | grep -F \[installed\] | awk -F/ '{print $1}'> ~/.frostfound/packagelist.txt
#import keys
sudo cp -R /etc/apt/sources.list.d/ ~/.frostfound/
sudo cp -R /etc/apt/trusted.gpg.d/ ~/.frostfound/
sudo cp /etc/apt/sources.list ~/.frostfound/sources.txt
apt-key exportall > ~/.frostfound/Repo.keys
DIR=$(dirname "$0")
#get flatpaks
flatpak list --app --columns application> ~/.frostfound/flatpaklist.txt
#get snaps
snap list | awk '!/disabled/{print $1}' | awk '{if(NR>1)print}'>~/.frostfound/snaplist.txt
echo "**/*Cache*">>.gitignore
echo "**/*cache*">>.gitignore
tput smso; tput setaf 4;echo "Versioning system config files(excluding cache files)"
echo "This might take awhile (~10 minutes)";tput sgr0
if
git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
.local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap;
then
	tput smso; tput setaf 2; echo "git add success";tput sgr0 
else 
	echo "git add failed"
	echo "This sometimes happens when config files change during add"
	echo "Retrying once";tput sgr0
	if
  git add  .config .var .frostfound .local/share/gnome-shell .local/share/fonts \
  .local/share/backgrounds .local/share/applications .local/share/icons .local/share/keyrings snap;
  then
		tput smso; tput setaf 2;echo "git add success";tput sgr0 
	else
		tput smso; tput setaf 1;echo "Retry unsuccessful"
		echo "Exiting"
		exit
	fi
fi
#create remember.sh script
cd "$DIR" || exit
cp remember.sh ~/remember.sh
cp install_info.md ~/README.md
sed -i "s/(DATE)/$(date)/" ~/README.md
A=""
while IFS= read -r line; do
    A+="- $line\n"
done < /etc/os-release
sed -i "s|(SYSTEM INFO)|${A}|" ~/README.md
cd ~/ || exit
git add ~/remember.sh
git add ~/README.md
tput smso; tput setaf 4;echo "committing";tput sgr0
git commit -qam "auto update"
tput smso; tput setaf 4;echo "Syncing with remote (this might take awhile)";tput sgr0
git fetch origin
BRANCH=$(basename "$(git branch -r)")
git merge -s ours "origin/${BRANCH}" --allow-unrelated-histories -m "Ignore this; Mock merge"
git branch -M "$BRANCH"
git push -u origin "$BRANCH" -f
rm ~/remember.sh
rm ~/README.md
exit


