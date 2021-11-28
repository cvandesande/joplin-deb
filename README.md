This script will download the Joplin source and package it into a DEB file.
The DEB file should be installable on relatively modern Debian/Ubuntu like OS'.
Tested on Debian 11, your milage may vary.

Requirements:

docker installed
```
apt-get install docker.io
sudo gpasswd -a $USER docker
```
Run joplin-deb.sh $VERSION ie: 2.5.12

