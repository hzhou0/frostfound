# Frostfound

Frostfound is a collection of scripts for cloning and version-controlling PopOS
systems with GNOME DE. It catalogues all installed applications and their configuration and 
state so that it may be easily cloned onto another system.

## Why use Frostfound
- Small size - typical backups should be less then 1 GB 
- Fast backup and restore
- Version Control - each backup is saved as a git commit

## What's Saved
- All Debs, Snaps, and Flatpaks
- APT software sources and keys
- GNOME settings, themes, and extensions
- Keychains and icon packs
- Application state, logins and configurations

## How to use
- Run ``forget.sh`` to backup your system to a personal remote repository
- Follow the instructions on the generated repository to clone backup
