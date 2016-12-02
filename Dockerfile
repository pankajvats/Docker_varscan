FROM ubuntu:16.04
FROM buildpack-deps:jessie-curl

MAINTAINER Pankaj Vats

RUN apt-get update && apt-get install -y \
        wget \
        git \
        build-essential \
        zlib1g-dev \
        ncurses-dev \
        g++ \
        python-dev \
        bzip2 \
        unzip \
        xz-utils \
	cmake \
	vim 
RUN alias vi=vim
        
ENV LANG C.UTF-8

RUN mkdir /opt/varscan && mkdir /opt/samtools

RUN { \
		echo '#!/bin/sh'; \
		echo 'set -e'; \
		echo; \
		echo 'dirname "$(dirname "$(readlink -f "$(which javac || which java)")")"'; \
	} > /usr/local/bin/docker-java-home \
	&& chmod +x /usr/local/bin/docker-java-home

ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/jre

ENV JAVA_VERSION 7u111
ENV JAVA_DEBIAN_VERSION 7u111-2.6.7-1~deb8u1

RUN set -x \
	&& apt-get update \
	&& apt-get install -y \
		openjdk-7-jre-headless="$JAVA_DEBIAN_VERSION" \
	&& rm -rf /var/lib/apt/lists/* \
&& [ "$JAVA_HOME" = "$(docker-java-home)" ]


WORKDIR /opt/samtools
RUN wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2
#RUN wget https://github.com/samtools/samtools.git
RUN tar xvjf samtools-1.3.1.tar.bz2
RUN cd /opt/samtools/samtools-1.3.1 && make && make install

WORKDIR /opt/Varscan
RUN git clone https://github.com/dkoboldt/varscan.git

WORKDIR /opt/Varscan
RUN git clone https://github.com/genome/bam-readcount
Run cd /opt/Varscan/bam-readcount && cmake /opt/Varscan/bam-readcount && make

WORKDIR /opt/
copy init.sh /opt/
RUN  /opt/init.sh 



RUN date

