FROM ubuntu

RUN apt-get update
RUN apt-get -y install gcc make git libpq-dev \
 && apt-get clean \
 && git clone https://github.com/vlang/v --depth=1

WORKDIR /v
RUN make
RUN /v/v up

WORKDIR /app
COPY ./src /app/src

RUN mkdir /app/bin

RUN /v/v /app/src -prod -o /app/bin/app

ENTRYPOINT ["/app/bin/app"]
