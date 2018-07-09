FROM alpine:latest

RUN apk --no-cache add \
        groff \
        less \
        python \
        py-pip \
 && pip install awscli

RUN apk --no-cache upgrade

ENTRYPOINT ["/usr/bin/aws"]
CMD ["help"]
