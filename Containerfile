FROM ubuntu:26.04 AS source

ARG APP_SHA256=ac77363a599109194ba2af3caa695348d199f515cf1d0fde091beb629e0c3103

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    curl --fail --location --output /tmp/xemu-0.8.136-x86_64.AppImage "https://github.com/xemu-project/xemu/releases/download/v0.8.136/xemu-0.8.136-x86_64.AppImage" && \
    echo "${APP_SHA256}  /tmp/xemu-0.8.136-x86_64.AppImage" | sha256sum --check

FROM ghcr.io/containerpak/mesa:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/xemu"

COPY --from=source /tmp/xemu-0.8.136-x86_64.AppImage /tmp/xemu-0.8.136-x86_64.AppImage
COPY xemu /usr/bin/xemu
COPY app.xemu.xemu.desktop /usr/share/applications/app.xemu.xemu.desktop

RUN apt-get update && \
    apt-get install -y --no-install-recommends squashfs-tools && \
    chmod +x /tmp/xemu-0.8.136-x86_64.AppImage && \
    /tmp/xemu-0.8.136-x86_64.AppImage --appimage-extract && \
    mv squashfs-root /opt/xemu && \
    chmod 0755 /usr/bin/xemu && \
    if [ -e /opt/xemu/.DirIcon ]; then install -Dm644 /opt/xemu/.DirIcon /usr/share/icons/hicolor/256x256/apps/app.xemu.xemu.png; fi && \
    rm -rf /tmp/xemu-0.8.136-x86_64.AppImage /tmp/archive && \
    cpak-clean-junk

