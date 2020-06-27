FROM debian:buster-slim

ENV LANG C.UTF-8

ARG DEBIAN_FRONTEND=noninteractive

# Install packages
RUN apt-get update -qy && apt-get upgrade -qy
RUN apt-get install nano wget lame build-essential libffi-dev python-pip python-dev python3-dev python3-pip libffi-dev -y

# Download libspotify & compile it
# RUN wget https://developer.spotify.com/download/libspotify/libspotify-12.1.51-Linux-x86_64-release.tar.gz && \
RUN wget -q -O - https://apt.mopidy.com/mopidy.gpg | apt-key add -
RUN wget -q -O /etc/apt/sources.list.d/mopidy.list https://apt.mopidy.com/stretch.list
RUN apt-get update
RUN apt-get install libspotify12 libspotify-dev

# Install required tools for support for AAC (M4A container)
RUN apt-get install pkg-config automake autoconf -y && \
	wget http://ftp.br.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac-dev_0.1.4-2+b1_amd64.deb && \
	wget http://ftp.br.debian.org/debian/pool/non-free/f/fdk-aac/libfdk-aac1_0.1.4-2+b1_amd64.deb && \
	dpkg -i libfdk-aac1_0.1.4-2+b1_amd64.deb && dpkg -i libfdk-aac-dev_0.1.4-2+b1_amd64.deb

# Compile libfdk-aac encoder
RUN wget https://github.com/nu774/fdkaac/archive/v0.6.2.tar.gz && tar xvf v0.6.2.tar.gz && \
	rm -f v0.6.2.tar.gz && cd fdkaac-0.6.2 && \
	autoreconf -i && ./configure && make install

# Install a fork of spotify-ripper
RUN pip3 install spotify-ripper-morgaroth

# Link our download location to /data in the container
VOLUME ["/data"]

# Copy needed files for spotify-ripper
COPY ./spotify_appkey.key /root/.spotify-ripper/spotify_appkey.key
COPY ./config.ini /root/.spotify-ripper/config.ini
