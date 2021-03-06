cd "$(dirname "$0")" || exit
cd .frostfound || exit
#import keys
sudo apt-key add Repo.keys
sudo cp -R trusted.gpg.d /etc/apt/trusted.gpg.d/ 
sudo cp -R sources.list.d /etc/apt/sources.list.d/
sudo cp sources.txt /etc/apt/sources.list 
sudo apt update
# sudo rm -r trusted.gpg.d sources.list.d

#install packages
if sudo xargs -a packagelist.txt apt-get install --ignore-missing -y -q; then
    echo "Apt installed failed"
    exit
fi
#install flatpaks
while IFS= read -r line; do
    flatpak install flathub "$line" -y --noninteractive
done < flatpaklist.txt
#install snaps
while IFS= read -r line; do
    sudo snap install "$line" --classic
done < snaplist.txt
#replace configs
cd ..
FOLDERS=$(find "$PWD" -maxdepth 1 -type d)
for i in $FOLDERS; do
    HOME=~
    #TARGET="${HOME}/${i}"
    #sudo rm $TARGET -rf
    #mv $i ~ -f
    BASE=${i##*/}
    rsync --recursive "${i}/" "${HOME}/${BASE}/"
done
cd .frostfound || exit
dconf load / < donf-backup.txt
sudo reboot