DIR="${0%/*}"
cd $DIR
#import keys
sudo apt-key add Repo.keys
sudo cp -R trusted.gpg.d /etc/apt/trusted.gpg.d/ 
sudo cp -R sources.list.d /etc/apt/sources.list.d/
sudo cp sources.txt /etc/apt/sources.list 

# sudo rm -r trusted.gpg.d sources.list.d

#install packages
sudo xargs -a packagelist.txt apt-get install --ignore-missing -y -q
#install flatpaks
cat flatpaklist.txt | while read line; do
    flatpak install flathub $line -y --noninteractive
done
#install snaps
cat snaplist.txt | while read line; do
    snap install $line --classic
done
#replace configs
cd ..
FOLDERS=$(git ls-tree --name-only HEAD)
for i in $FOLDERS; do
    HOME=~
    #TARGET="${HOME}/${i}"
    #sudo rm $TARGET -rf
    #mv $i ~ -f
    if [[ -f "$i" ]]; then
        mv -f "${i}" "${HOME}"
    else
        rsync --recursive "${i}/" "${HOME}/${i}/"
    fi
done
cd $DIR
dconf load / < donf-backup.txt
