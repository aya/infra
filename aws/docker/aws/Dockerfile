FROM alpine:latest

RUN apk add --no-cache \
        groff \
        less \
        python \
        py-pip \
 && pip install awscli

ENTRYPOINT ["/usr/bin/aws"]
CMD ["help"]
