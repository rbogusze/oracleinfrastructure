# Version 1.0
FROM dockerfile/nodejs
MAINTAINER Shrikrishna Holla <s**a@gmail.com>
WORKDIR /home
RUN git clone \ https://github.com/shrikrishnaholla/code.it.git
WORKDIR code.it
RUN git submodule update --init --recursive
RUN npm install
EXPOSE 8000
WORKDIR /home
CMD ["/usr/bin/node", "/home/code.it/app.js"]
