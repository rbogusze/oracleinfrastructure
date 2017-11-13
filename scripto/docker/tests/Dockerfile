FROM ubuntu:16.04
RUN apt-get update
RUN apt-get -y install cowsay
RUN apt-get -y install fortune
ENTRYPOINT ["/usr/games/cowsay"]
CMD ["Docker is so awesomoooooooo!"]
ONBUILD RUN /usr/games/fortune | /usr/games/cowsay
