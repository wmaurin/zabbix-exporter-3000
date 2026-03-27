FROM golang:1.21-alpine AS builder

ENV CGO_ENABLED=0

WORKDIR /src
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN go build -o /go/bin/ze3000 main.go

FROM alpine:3.18

EXPOSE 8080
RUN mkdir /main && chmod 777 /main
WORKDIR /main

COPY --from=builder /go/bin/ze3000 /main/ze3000

RUN  \
     apk add --no-cache ca-certificates curl su-exec && \
     echo 'hosts: files mdns4_minimal [NOTFOUND=return] dns mdns4' >> /etc/nsswitch.conf

CMD ["/main/ze3000"]
