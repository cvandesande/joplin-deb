FROM node:lts-bookworm-slim

ARG VERSION

ENV NODE_OPTIONS=--openssl-legacy-provider

WORKDIR /usr/src

RUN set -ex \
    # Install Joplin build dependencies
    && apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq \
         make \
         g++ \
         fakeroot \
         pkg-config \
         libsecret-1-dev \
         libvips-dev \
         rsync \
         curl \
    && curl -fsSL -o joplin.tar.gz \
         https://github.com/laurent22/joplin/archive/refs/tags/v"${VERSION}".tar.gz

RUN set -ex \
    # Compile Joplin
    && mkdir joplin \
    && tar -xzf joplin.tar.gz -C joplin/ --strip-components=1 \
    && rm joplin.tar.gz \
    && cd joplin \
    # Workaround for socket timeout errors with lerna
    && sed -i '0,/--no-ci/s//--no-ci --concurrency=2/' package.json \
    # Remove some things we don't need to build
    && sed -i '/"releaseAndroid"/d; \
         /"releaseAndroidClean"/d; \
         /"releaseCli"/d; \
         /"releaseClipper"/d; \
         /"releaseIOS"/d; \
         /"releasePluginGenerator"/d; \
         /"releasePluginRepoCli"/d; \
         /"releaseServer"/d' package.json \
    # Build Joplin normally \
    && yarn install

RUN set -ex \
    # Install electron packager tools
    && yarn add \
      electron-packager \
      electron-installer-debian \
    && cd joplin \
    # Package installer has issues with the slash "/" in the name \
    && sed -i 's/@joplin\/app-desktop/joplin/' packages/app-desktop/package.json \
    # Create DEB package \
    && cd packages/app-desktop \
    && /usr/src/node_modules/electron-packager/bin/electron-packager.js . --platform linux --arch x64 --out dist/ \
    && /usr/src/node_modules/.bin/electron-installer-debian \
         --src dist/joplin-linux-x64 \
         --dest dist/installers/ \
         --arch amd64

ADD export.sh /usr/local/bin

