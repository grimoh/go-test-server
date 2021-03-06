ARG PACKAGE=github.com/grimoh/test-server 

# build
FROM golang:1.13-alpine3.10 as builder

COPY . /go/src/$PACKAGE
WORKDIR /go/src/$PACKAGE

RUN apk add --update --no-cache \
    git

ENV \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

COPY go.mod go.sum ./
RUN GO111MODULE=on go mod download

RUN go build -o /opt/test-server

# run
FROM alpine:3.10 as executor

WORKDIR /opt
COPY --from=builder /opt /opt
COPY --from=builder /etc/ssl/certs /etc/ssl/certs
COPY --from=builder /go/src /go/src

ENV \
	PATH=/opt:$PATH

CMD ["test-server"]
