#!/bin/sh

# export DEB file

# Get owner id of Downloads
OWNER=$(stat -c '%u' /usr/src/Downloads)
printf "Downloads owner is $OWNER\n"

# Copy package to Downloads and update file owner
find / -name Downloads
mv /usr/src/joplin/packages/app-desktop/dist/installers/*.deb /usr/src/Downloads/
chown $OWNER:$OWNER Downloads/joplin_${VERSION}_amd64.deb

