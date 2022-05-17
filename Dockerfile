FROM alpine:3.15

WORKDIR /app

ENV BITCOIN_CORE_VERSION 22.0

RUN apk --update --no-cache add add curl && \
    curl -L https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/SHA256SUMS.asc && \
    curl -L https://bitcoin.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-x86_64-linux-gnu.tar.gz && \
    sha256sum --ignore-missing --check SHA256SUMS.asc && \
    tar xzf *.tar.gz
    
