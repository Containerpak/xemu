FROM ubuntu:26.04 AS source

ADD --checksum=sha256:ac77363a599109194ba2af3caa695348d199f515cf1d0fde091beb629e0c3103 https://github.com/xemu-project/xemu/releases/download/v0.8.136/xemu-0.8.136-x86_64.AppImage /tmp/source

RUN chmod 0755 /tmp/source && \
    cd /tmp && \
    ./source --appimage-extract >/dev/null && \
    mkdir -p /stage && \
    cp -a /tmp/squashfs-root/. /stage/

FROM ghcr.io/containerpak/mesa64:main

LABEL org.opencontainers.image.source="https://github.com/Containerpak/xemu"

COPY --from=source /stage/ /opt/xemu/
COPY xemu /usr/bin/xemu
COPY app.xemu.xemu.desktop /usr/share/applications/app.xemu.xemu.desktop

RUN chmod 0755 /usr/bin/xemu && \
    if [ -e /opt/xemu/.DirIcon ]; then install -Dm644 /opt/xemu/.DirIcon /usr/share/icons/hicolor/256x256/apps/app.xemu.xemu.png; fi && \
    cpak-clean-junk
