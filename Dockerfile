FROM ghcr.io/linuxserver/baseimage-alpine:3.13

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MSTREAM_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

ENV HOME="/config"

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    curl \
    git && \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    nodejs \
    npm \
    openssl && \
  echo "**** install app ****" && \
  mkdir -p \
    /opt/mstream && \
  if [ -z ${MSTREAM_RELEASE+x} ]; then \
    MSTREAM_RELEASE=$(curl -sX GET "https://api.github.com/repos/IrosTheBeggar/mStream/releases/latest" \
      | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/mstream.tar.gz -L \
    "https://github.com/IrosTheBeggar/mStream/archive/${MSTREAM_RELEASE}.tar.gz" && \
  tar xzf \
    /tmp/mstream.tar.gz -C \
    /opt/mstream/ --strip-components=1 && \
  cd /opt/mstream && \
  npm install --only=production && \
  npm link && \
  echo "**** cleanup ****" && \
  npm cache clean --force && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    /tmp/*

# add local files
COPY root/ /

# ports and volumes
EXPOSE 3000
VOLUME /config /music
