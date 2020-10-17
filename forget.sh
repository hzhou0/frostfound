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
dpkg-query -f '${binary:Package}\n' -W > ~/.frostfound/packagelist.txt
LOCAL=$(aptitude search -F "%p" '~o')
for i in $LOCAL; do
    sed -i "/${i}/d" ~/.frostfound/packagelist.txt
done
#import keys
sudo cp -R /etc/apt/sources.list.d/ ~/.frostfound/
sudo cp -R /etc/apt/trusted.gpg.d/ ~/.frostfound/
sudo cp /etc/apt/sources.list ~/.frostfound/sources.txt
sudo apt-key exportall > ~/.frostfound/Repo.keys
#get flatpaks
flatpak list --app --columns application> ~/.frostfound/flatpaklist.txt
#get snapes
snap list | awk '!/disabled/{print $1}' | awk '{if(NR>1)print}'>~/.frostfound/snaplist.txt
echo "Exclude cache files"
echo "**/*Cache*">>.gitignore
echo "**/*cache*">>.gitignore
echo "versioning system config files"
echo "This might take awhile (~10 minutes)"
git add  .config .var .frostfound Pictures .local/share/gnome-shell .local/share/evolution .local/share/backgrounds Public Templates Videos snap Music taskbar.dconf 
if [[ $? -eq '0' ]]; then
	echo "git add success"
else 
	echo $?
	echo "git add failed"
	echo "This sometimes happens when config files change during add"
	echo "Retrying once"
	git add  .config .var .frostfound Pictures .local/share/gnome-shell .local/share/evolution .local/share/backgrounds Public Templates Videos snap Music taskbar.dconf 
	if [[ $? -eq '0' ]]; then
		echo "git add success"
	else
		echo "Retry unsuccessful"
		echo "Exiting"
		exit
	fi
fi
echo "commiting"
git commit -q -am "auto update"
echo "pushing to remote"
echo "this might take awhile"
git branch -M main
git push -u origin main -f
exit

