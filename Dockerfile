# Use the official Ubuntu 24.04 base image
FROM ubuntu:24.04

# Set environment variables to avoid prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install basic packages
RUN apt-get update && apt-get install -y \
    apt-utils \
    software-properties-common \
    curl \
    git \
    build-essential \
    pkg-config \
    libssl-dev \
    libx264-dev \
    libvpx-dev \
    libopus-dev \
    libcairo2-dev \
    libpango1.0-dev \
    libgdk-pixbuf2.0-dev \
    libgtk-3-dev \
    nodejs \
    npm \
    && add-apt-repository universe \
    && apt-get update \
    && apt-get install -y \
    gstreamer1.0-tools \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-ugly \
    gstreamer1.0-libav \
    gstreamer1.0-x \
    gstreamer1.0-alsa \
    gstreamer1.0-gl \
    gstreamer1.0-gtk3 \
    gstreamer1.0-qt5 \
    gstreamer1.0-pulseaudio \
    libgstrtspserver-1.0-dev \
    libgstreamer1.0-dev \
    libgstreamer-plugins-base1.0-dev \
    libgstreamer-plugins-bad1.0-dev \
    libnice-dev \
    gstreamer1.0-nice \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install cargo-c
RUN apt-get update && \
    cargo install cargo-c && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone the gst-plugins-rs repository
RUN git clone https://gitlab.freedesktop.org/gstreamer/gst-plugins-rs.git /app/gst-plugins-rs

# Set environment variables
ENV GST_PLUGIN_PATH=/app/gst-plugins-rs/target/debug:$GST_PLUGIN_PATH
ENV PKG_CONFIG_PATH="/usr/lib/x86_64-linux-gnu/pkgconfig:$PKG_CONFIG_PATH"

# Clone and setup webrtc
WORKDIR /app/gst-plugins-rs/net/webrtc
RUN npm install --save-dev webpack webpack-cli html-webpack-plugin ts-loader typescript && \
    cd gstwebrtc-api && \
    npm init -y && \
    npm install --save-dev typescript @types/node && \
    npm run build

# Build the Rust components and WebRTC API
RUN cargo build && \
    npm --prefix gstwebrtc-api/ run build

# Set the working directory
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

CMD ["bash"]