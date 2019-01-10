FROM golang:alpine as build

RUN apk add --no-cache git
RUN go get github.com/gozap/cclean
RUN go install -ldflags "-w -s" github.com/gozap/cclean

FROM alpine:latest as dist

COPY --from=build /go/bin/cclean /usr/local/bin/
