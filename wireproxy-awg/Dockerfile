ARG BUILD_FROM

# --- builder: собираем ровно так же, как в апстриме ---
FROM docker.io/golang:1.26 AS builder

ARG WIREPROXY_VERSION=v1.0.18
WORKDIR /usr/src/wireproxy

RUN git clone --branch ${WIREPROXY_VERSION} --depth 1 \
      https://github.com/artem-russkikh/wireproxy-awg.git .
RUN make

# --- финальный образ: HA base, не distroless ---
FROM ${BUILD_FROM}

COPY --from=builder /usr/src/wireproxy/wireproxy /usr/local/bin/wireproxy
RUN chmod +x /usr/local/bin/wireproxy

COPY run.sh /
RUN chmod a+x /run.sh

CMD [ "/run.sh" ]