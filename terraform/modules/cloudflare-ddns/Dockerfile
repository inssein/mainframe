FROM alpine

LABEL org.opencontainers.image.source https://github.com/inssein/mainframe

RUN apk add --no-cache curl
RUN apk add --no-cache bind-tools

ENTRYPOINT ["/usr/bin/curl"]