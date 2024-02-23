FROM ubuntu:latest

RUN apt update
RUN apt install git -y
RUN apt install gcc -y
RUN apt install make -y
RUN apt install libpq-dev -y
RUN git clone https://github.com/vlang/v --depth=1
WORKDIR /v
RUN make
RUN /v/v up

WORKDIR /app
COPY ./src /app/src

#Create a build directory
RUN mkdir /app/bin

RUN /v/v /app/src -prod -o /app/bin/app

ENTRYPOINT ["/app/bin/app"]
