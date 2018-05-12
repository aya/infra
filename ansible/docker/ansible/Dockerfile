FROM alpine:latest

RUN apk --no-cache add \
        ansible

RUN apk --no-cache upgrade

ENTRYPOINT ["/usr/bin/ansible"]
CMD ["--help"]
