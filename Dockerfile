FROM --platform=${BUILDPLATFORM} golang:1.22.5 as builder

WORKDIR /app

COPY . .

RUN go mod download && go mod verify

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /app/cert-manager-sync cmd/cert-manager-sync/*.go

FROM --platform=${BUILDPLATFORM} alpine:3.6 as alpine

RUN apk add -U --no-cache ca-certificates

FROM --platform=${TARGETPLATFORM} scratch as app

WORKDIR /app

COPY --from=builder /app/cert-manager-sync /app/cert-manager-sync
COPY --from=alpine /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

ENTRYPOINT [ "/app/cert-manager-sync" ]
