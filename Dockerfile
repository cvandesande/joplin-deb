FROM node:lts-bullseye-slim

ARG VERSION

WORKDIR /usr/src/app

RUN set -ex \
    # Install Joplin build dependencies \
    && apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq \
           make \
           g++ \
           fakeroot \
           pkg-config \
           python-is-python2 \
           libsecret-1-dev \
           rsync \
           curl \
    && curl -L -o joplin.tar.gz \
         https://github.com/laurent22/joplin/archive/refs/tags/v"${VERSION}".tar.gz \
    && mkdir joplin \
    && tar -xzf joplin.tar.gz -C joplin/ --strip-components=1 \
    && rm joplin.tar.gz \
    && cd joplin \
    # Workaround for socket timeout errors with lerna \
    && sed -i '0,/--no-ci/s//--no-ci --concurrency=2/' package.json \
    # Remove some things we don't need to build \
    && sed -i '/"releaseAndroid"/d; \
           /"releaseAndroidClean"/d; \
           /"releaseCli"/d; \
           /"releaseClipper"/d; \
           /"releaseIOS"/d;\
           /"releasePluginGenerator"/d; \
           /"releaseServer"/d' package.json \
    # Build Joplin normally \
    && npm install --no-audit --progress=false \
    # Install electron packager tools \
    && npm install --no-audit --progress=false \
           electron-packager \
           electron-installer-debian \
    && export PATH=$(npm bin):$PATH \
    # Package installer has issues with the slash "/" in the name \
    && cd packages/app-desktop \
    && sed -i 's/@joplin\/app-desktop/joplin-desktop/' package.json \
    # Create DEB package \
    && electron-packager . --platform linux --arch x64 --out dist/ \
    && electron-installer-debian \
          --src dist/joplin-desktop-linux-x64 \
          --dest dist/installers/ \
          --arch amd64 \
    # Cleanup \
    && rm -rf /var/lib/apt/lists/*

ADD export.sh /usr/local/bin

