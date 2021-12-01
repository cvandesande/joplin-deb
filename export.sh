#!/bin/sh

# export DEB file

# Get owner id of Downloads
OWNER=$(stat -c '%u' /usr/src/app/Downloads)
printf "Downloads owner is $OWNER\n"

# Copy package to Downloads and update file owner
cp joplin/packages/app-desktop/dist/installers/joplin_${VERSION}_amd64.deb Downloads/
chown $OWNER:$OWNER Downloads/joplin_${VERSION}_amd64.deb

