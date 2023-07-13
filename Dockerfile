FROM ubuntu:20.04

LABEL maintainer "Jan De Dobbeleer"

ENV NDK_VERSION "r25"
ENV ANDROID_NDK_HOME /opt/android-ndk
ENV GO_VERSION "1.20.6"

ARG DEBIAN_FRONTEND=noninteractive

# Dependencies
RUN apt-get update \
    && apt-get install build-essential wget unzip -y

RUN wget https://go.dev/dl/go1.19.4.linux-amd64.tar.gz \
    && tar -C /usr/local -xzf go1.19.4.linux-amd64.tar.gz

ENV PATH /usr/local/go/bin:$PATH
ENV GOROOT /usr/local/go

# Download, uncompress and finalize location
RUN mkdir /opt/android-ndk-tmp && cd /opt/android-ndk-tmp \
    && wget -q https://dl.google.com/android/repository/android-ndk-${NDK_VERSION}-linux.zip \
    && unzip ./android-ndk-${NDK_VERSION}-linux.zip \
    && mv ./android-ndk-${NDK_VERSION} /opt/android-ndk \
    && rm -rf /opt/android-ndk-tmp

# Setup Golang
RUN export NDK_CC=$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi32-clang \
    && wget -O go.tgz https://dl.google.com/go/go${GO_VERSION}.src.tar.gz \
    && tar -C /opt -xzf go.tgz \
    && cd /opt/go/src/ \
    && export GOROOT_BOOTSTRAP="$(go env GOROOT)" \
    && CC_FOR_TARGET=$NDK_CC GOOS=android GOARCH=arm GOARM=7 ./make.bash

ENV PATH /opt/go/bin:$PATH
ENV CC $NDK_CC
ENV GOOS android
ENV GOARCH arm
ENV GOARM 7
ENV CGO_ENABLED 1

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
