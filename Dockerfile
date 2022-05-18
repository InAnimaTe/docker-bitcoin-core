## Can't use alpine since it seems bitcoin core is linked against musl
## Source: https://github.com/kylemanna/docker-bitcoind/blob/master/Dockerfile#L2
## Picked the next best thing, latest debian/ubuntu images are much smaller than before!
FROM debian:bullseye-slim

## Set a nice clean working directory
WORKDIR /app

## Set some variables to use solely during build process
ENV BITCOIN_CORE_VERSION 22.0
ENV BITCOIN_SUMS_FILE SHA256SUMS
ENV APPUSER bitcoin-core

RUN apt update && \
    ## Install our required packages and cleanup
    apt install -y --no-install-recommends ca-certificates wget tini && \
    apt clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    find / -xdev -name '*apt*' -print0 | xargs rm -rf && \
    ## Get packages and checksum
    wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/${BITCOIN_SUMS_FILE} && \
    wget https://bitcoincore.org/bin/bitcoin-core-${BITCOIN_CORE_VERSION}/bitcoin-${BITCOIN_CORE_VERSION}-x86_64-linux-gnu.tar.gz && \
    sha256sum --ignore-missing --check ${BITCOIN_SUMS_FILE} && \
    tar xzf bitcoin-${BITCOIN_CORE_VERSION}-x86_64-linux-gnu.tar.gz && \
    ln -s bitcoin-${BITCOIN_CORE_VERSION} bitcoin-core && \
    rm -rf *.tar.gz ${BITCOIN_SUMS_FILE} && \
    ## Disable Root
    passwd -d root && \
    ## Setup dropuser
    useradd --no-create-home --shell /bin/false ${APPUSER} && \
    passwd -d ${APPUSER} && \
    chown -R ${APPUSER}:${APPUSER} ./bitcoin-${BITCOIN_CORE_VERSION} && \
    ## Harden the image - See more at iron-debian: https://github.com/ironpeakservices/iron-debian/blob/master/Dockerfile
    ## Remove dangerous commands
    find /bin /etc /lib /sbin /usr -xdev \( \
        -name hexdump -o \
        -name chgrp -o \
        -name chown -o \
        -name ln -o \
        -name od -o \
        -name strings -o \
        -name su \
        -name sudo \
        \) -delete && \
    ## Remove suid and sgid
    find /bin /etc /lib /sbin /usr -xdev -type f -a \( -perm /4000 -o -perm /2000 \) -delete && \
    # rm kernel tunables
    rm -rf /etc/sysctl* && \
    rm -rf /etc/modprobe.d && \
    rm -rf /etc/modules && \
    rm -rf /etc/mdev.conf && \
    rm -rf /etc/acpi

## Set our unprivileged app user
USER ${APPUSER}

## The most used ports when running a node
EXPOSE 8332 8333

## Use a proper init process https://github.com/krallin/tini protecting from zombies and handling signals
ENTRYPOINT ["/usr/bin/tini", "--"]
## Launch daemon
CMD ["/app/bitcoin-core/bin/bitcoind"]

## Note: Critical Vuln found with openssl/libssl1.1 via docker scan. No patch currently available!
## Info: https://snyk.io/vuln/SNYK-DEBIAN11-OPENSSL-2807596