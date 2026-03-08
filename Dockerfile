# syntax=docker/dockerfile:1.6

ARG BASE_IMAGE=debian:trixie-slim

# ==============================================================
# Stage 1 — Builder (only downloads & extracts s6 overlay)
# ==============================================================

FROM ${BASE_IMAGE} AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        xz-utils \
        tar && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /tmp

ARG S6_OVERLAY_VERSION=v3.2.2.0

# Download s6-overlay
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp
ADD https://github.com/just-containers/s6-overlay/releases/download/${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp

# Extract into /s6-root (isolated from runtime root)
RUN mkdir /s6-root && \
    tar -C /s6-root -Jxpf s6-overlay-noarch.tar.xz && \
    tar -C /s6-root -Jxpf s6-overlay-x86_64.tar.xz


# ==============================================================
# Stage 2 — Runtime (lean + hardened)
# ==============================================================

FROM ${BASE_IMAGE}

LABEL org.opencontainers.image.title="postfix"
LABEL org.opencontainers.image.description="Production-ready mail relay with Postfix"
LABEL org.opencontainers.image.vendor="Jaipongchang"
LABEL org.opencontainers.image.licenses="MIT"
LABEL org.opencontainers.image.source="https://github.com/jaipongchang/postfix"

ENV DEBIAN_FRONTEND=noninteractive \
    TZ=Europe/Paris \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_CMD_WAIT_FOR_SERVICES_MAXTIME=0

# Install runtime packages in ONE layer
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        tzdata \
        postfix \
        libsasl2-2 \
        libsasl2-modules \
        sasl2-bin \
        openssl && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get clean

# --------------------------------------------------------------
# Create dedicated non-root user (fixed UID/GID for K8s)
# --------------------------------------------------------------
ARG APP_UID=1000
ARG APP_GID=1000

# --------------------------------------------------------------
# Copy s6-overlay from builder
# --------------------------------------------------------------
COPY --from=builder /s6-root/ /

# --------------------------------------------------------------
# Filesystem preparation
# --------------------------------------------------------------
RUN mkdir -p \
      /var/spool/postfix \
      /var/log/mail && \
    chown -R root:root /var/spool/postfix

# --------------------------------------------------------------
# Copy service definitions
# --------------------------------------------------------------
COPY rootfs/ /

RUN chmod +x /etc/services.d/*/run

# --------------------------------------------------------------
# Security hardening
# --------------------------------------------------------------

# Drop default shell for safety
# RUN chsh -s /usr/sbin/nologin rspamd || true

# --------------------------------------------------------------
# Healthcheck (SMTP STARTTLS probe)
# --------------------------------------------------------------
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
  CMD openssl s_client -starttls smtp -connect localhost:587 -servername localhost \
      </dev/null 2>/dev/null | grep -q "250" || exit 1

# --------------------------------------------------------------
# Exposed ports
# --------------------------------------------------------------
EXPOSE 25 587

# s6 must run as root (to start postfix properly)
ENTRYPOINT ["/init"]