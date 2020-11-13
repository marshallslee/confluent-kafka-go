#=================================
# librdkafka + golang base container image build
#=================================
FROM golang:1.14.2-alpine3.11 as base
ARG LIBRDKAFKA_VERSION=v1.0.0
ENV LIBRDKAFKA_VERSION=$LIBRDKAFKA_VERSION
RUN echo "librdkafka :$LIBRDKAFKA_VERSION"
RUN apk add --no-cache --virtual .fetch-deps ca-certificates tar
RUN mkdir -p /root/librdkafka

WORKDIR /root/librdkafka

RUN wget -O "librdkafka.tar.gz" "https://github.com/edenhill/librdkafka/archive/$LIBRDKAFKA_VERSION.tar.gz" &&\
  mkdir -p librdkafka

RUN tar \
  --extract \
  --file "librdkafka.tar.gz" \
  --directory "librdkafka" \
  --strip-components 1

RUN apk add --no-cache --virtual .build-deps \
  bash \
  make \
  pkgconfig \
  g++ \
  zstd-static \
  git

RUN cd "librdkafka" && \
  STATIC_LIB_zstd=/usr/lib/libzstd.a ./configure --enable-static --prefix=/usr && \
  make -j "$(getconf _NPROCESSORS_ONLN)" && \
  make install && make clean && ./configure --clean && apk del .fetch-deps && cd / && \
  rm -rf /root/librdkafka && \
  mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2