FROM golang:1.15.3-alpine3.12 as build
WORKDIR /build

# download all imports and prebuild in cache
COPY go.mod go.sum ./
# no cache
COPY . .
RUN go build .

ENTRYPOINT ["./k3d-test"]