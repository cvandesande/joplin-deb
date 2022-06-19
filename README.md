This script will download the [Joplin](https://joplinapp.org/desktop) source and package it into a DEB file.
The DEB file should be installable on relatively modern Debian/Ubuntu like OS'.
Tested on Debian 11, your mileage may vary.

Requirements:

Podman installed (for Ubuntu 20.10 and newer)

```
apt install podman
```

or

Docker installed
```
apt install docker.io
sudo gpasswd -a $USER docker
```

Usage:

./joplin-deb.sh -j joplin-version

Example:
```
./joplin-deb.sh -j 2.8.8
```
If the build is successful, it will create a DEB file in the current $HOME/tmpdir folder by default. You can define output directory by -o argument. 

Install it with:
```
sudo apt install ~/tmpdir/joplin-desktop_*.deb
```

