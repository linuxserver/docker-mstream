# syntax=docker/dockerfile:1

FROM ghcr.io/linuxserver/baseimage-alpine:3.19

# set version label
ARG BUILD_DATE
ARG VERSION
ARG MSTREAM_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chbmb"

ENV HOME="/config"

RUN \
  echo "**** install runtime packages ****" && \
  apk add --no-cache --upgrade \
    nodejs \
    openssl && \
  apk add --no-cache --upgrade --virtual=build-dependencies \
    npm && \
  echo "**** install app ****" && \
  mkdir -p \
    /app/mstream && \
  if [ -z ${MSTREAM_RELEASE+x} ]; then \
    MSTREAM_RELEASE=$(curl -sX GET "https://api.github.com/repos/IrosTheBeggar/mStream/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/mstream.tar.gz -L \
    "https://github.com/IrosTheBeggar/mStream/archive/${MSTREAM_RELEASE}.tar.gz" && \
  tar xzf \
    /tmp/mstream.tar.gz -C \
    /app/mstream/ --strip-components=1 && \
  cd /app/mstream && \
  chown -R abc:abc ./ && \
  su -s /bin/sh abc -c 'HOME=/tmp npm install --omit=dev' && \
  npm link && \
  echo "**** cleanup ****" && \
  rm -rf /app/mstream/save/sync && \
  ln -s /config/sync /app/mstream/save/sync && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.npm \
    /tmp/* \
    /tmp/.npm

# add local files
COPY root/ /

# ports and volumes
EXPOSE 3000
VOLUME /config
