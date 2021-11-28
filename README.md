This script will download the [Joplin](https://joplinapp.org/desktop) source and package it into a DEB file.
The DEB file should be installable on relatively modern Debian/Ubuntu like OS'.
Tested on Debian 11, your milage may vary.

Requirements:

Docker installed
```
apt-get install docker.io
sudo gpasswd -a $USER docker
```
Usage:

./joplin-deb.sh joplin-version

Example:
```
./joplin-deb.sh 2.5.12
```

