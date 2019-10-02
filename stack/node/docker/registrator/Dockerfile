FROM golang:1.9.4-alpine3.7 AS builder
LABEL maintainer 1001Pharmacies <technique+docker@1001pharmacies.com>

arg GIT_AUTHOR_NAME
arg GIT_AUTHOR_EMAIL

env GIT_AUTHOR_NAME=${GIT_AUTHOR_NAME:-1001Pharmacies}
env GIT_AUTHOR_EMAIL=${GIT_AUTHOR_EMAIL:-technique+docker@1001pharmacies.com}
env GIT_COMMITTER_NAME=${GIT_AUTHOR_NAME}
env GIT_COMMITTER_EMAIL=${GIT_AUTHOR_EMAIL}

WORKDIR /go/src/github.com/gliderlabs/registrator/
RUN \
    apk add --no-cache curl git \
    && git clone https://github.com/gliderlabs/registrator/ . \
    # -useIpFromNetwork command line option \
    && git fetch origin pull/596/head \
    && git merge --no-edit 8d904c60949e310893a25c8af3636b0151334dd4 \
    # convert check.Script to check.Args \
    && git fetch origin pull/627/head \
    && git merge --no-edit ed053c364e3ba941aeca9ab0d8791b051ff4dede \
    # skip tls verification \
    && git fetch origin pull/661/head \
    && git merge --no-edit 38fc83ac07b4a070be71079cb810429d94a60205 \
    # handle udp/tcp services \
    && git fetch origin pull/668/head \
    && git merge --no-edit 1c84c313b441cc61fd98ec648c52735bc5b00afb \
    && curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh \
    && dep ensure -vendor-only \
    && CGO_ENABLED=0 GOOS=linux go build \
        -a -installsuffix cgo \
        -ldflags "-X main.Version=$(cat VERSION)" \
        -o bin/registrator \
        .

FROM alpine:3.7
RUN apk add --no-cache ca-certificates
COPY --from=builder /go/src/github.com/gliderlabs/registrator/bin/registrator /bin/registrator

ENTRYPOINT ["/bin/registrator"]
