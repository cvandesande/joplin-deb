FROM node:lts-trixie-slim

ARG VERSION

WORKDIR /usr/src

RUN set -ex \
    # Install Joplin build dependencies
    && apt-get update \
    && apt-get upgrade -yq \
    && apt-get install -yq \
         git \
         make \
         g++ \
         fakeroot \
         pkg-config \
         libsecret-1-dev \
         libvips-dev \
         rsync


ENV SHARP_IGNORE_GLOBAL_LIBVIPS=1

RUN set -ex \
    # Compile Joplin
    && git clone --depth 1 --branch v"${VERSION}" \
        https://github.com/laurent22/joplin.git joplin \
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
         /"releaseServer"/d; \
         /"releaseTranscribe"/d' package.json \
    # Build Joplin normally \
    && rm -rf node_modules \
    && yarn install --immutable || \
    (echo "Build failed, dumping logs:" \
     find /tmp -type f -name "*.log" -exec sh -c 'echo "=== {} ===" && cat {}' \; && \
     exit 1) \
    && cd packages/app-desktop \
    && yarn run dist

ADD export.sh /usr/local/bin

