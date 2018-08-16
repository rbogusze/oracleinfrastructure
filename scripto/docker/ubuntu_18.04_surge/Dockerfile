FROM ubuntu:18.04

MAINTAINER remik <remigiusz.boguszewicz@gmail.com>

WORKDIR /app

ENV DEBIAN_FRONTEND noninteractive

CMD echo "Europe/Warsaw" > /etc/timezone

RUN apt-get -y update && apt-get install -y fortunes npm expect

RUN npm install --global surge

RUN apt-get -y update && apt-get install -y fortunes npm expect

RUN apt-get clean

CMD /usr/games/fortune -a | cowsay

