FROM golang:1.15.3-alpine3.12 as build
WORKDIR /build
ENV CGO_ENABLED=0
ENV USER=disco
ENV UID=12345
ENV GID=23456

# download all imports and prebuild in cache
COPY go.mod go.sum ./
# no cache
COPY . .
RUN go build .

ENTRYPOINT ["./k8gb-discovery","listen"]