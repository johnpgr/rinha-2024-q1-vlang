FROM thevlang/vlang:latest

RUN apk add postgresql-dev
RUN v up

WORKDIR /app
COPY ./src /app/src

#Create a build directory
RUN mkdir /app/bin

RUN v /app/src -d debug -prod -o /app/bin/app

ENTRYPOINT ["/app/bin/app"]
