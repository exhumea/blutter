FROM debian:trixie-slim

RUN DEBIAN_FRONTEND=noninteractive

# Update and upgrade the system
RUN apt update && apt upgrade -yqq

# Install necessary packages (and remove cache)
RUN apt install -yqq bash unzip git cmake ninja-build build-essential pkg-config \
    python3-pyelftools python3-requests python3-capstone libicu-dev libcapstone-dev \
    && apt autoclean && rm -rf /var/lib/apt/lists/*

# Create blutter user and its home path
ARG UID=1000
ARG GID=$UID
RUN groupadd --gid $GID blutter
RUN useradd -N --gid $GID --uid $UID --shell /bin/bash --home-dir /blutter blutter

# Copy the archive of the local git repository (with proper rights)
ADD dist/blutter.tar.gz /blutter

# Rootless container with volumes
# /blutter/{bin,packages}: volumes to share builds across disposable containers
RUN chown -R blutter:blutter /blutter
USER blutter
VOLUME ["/blutter/bin", "/blutter/packages"]

# Automatically run the tool
WORKDIR /blutter
ENTRYPOINT ["./blutter.py"]
