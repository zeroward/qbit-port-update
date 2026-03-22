FROM alpine:3.21

RUN apk add --no-cache curl jq

WORKDIR /app
COPY update-port.sh .
RUN chmod +x update-port.sh

ENTRYPOINT ["/app/update-port.sh"]