FROM ubuntu:14.04

ENV LANGUAGE "en_US.UTF-8"
ENV LC_ALL "en_US.UTF-8"
ENV LANG "en_US.UTF-8"
ENV DEBIAN_FRONTEND noninteractive

COPY source /source
COPY bin /bin
RUN /bin/build

WORKDIR /source
RUN phpize7.2
RUN /source/configure
RUN make
RUN make install