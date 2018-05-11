FROM alpine:latest

RUN apk add --no-cache \
        ansible

ENTRYPOINT ["/usr/bin/ansible"]
CMD ["--help"]
