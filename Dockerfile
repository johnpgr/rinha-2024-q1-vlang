FROM ubuntu

RUN apt-get update
RUN apt-get -y install gcc make git libpq-dev \
 && apt-get clean \
 && git clone https://github.com/vlang/v --depth=1

WORKDIR /v
RUN make
RUN /v/v up

WORKDIR /app
COPY *.v /app

RUN mkdir /app/bin

RUN /v/v /app -prod -o /app/bin/app

ENTRYPOINT ["/app/bin/app"]
