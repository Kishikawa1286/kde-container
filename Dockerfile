FROM nvidia/cuda:12.3.2-base-ubuntu22.04

# This file is based on the following source code:
# https://github.com/selkies-project/docker-nvidia-egl-desktop/blob/main/Dockerfile
# 
# The original source code form is subject to 
# the terms of the Mozilla Public License, v. 2.0.
# If a copy of the MPL was not distributed with this file,
# You can obtain one at https://mozilla.org/MPL/2.0/.

ENV DEBIAN_FRONTEND=noninteractive

# System defaults that should not be changed
ENV DISPLAY :0
ENV XDG_RUNTIME_DIR /tmp/runtime-user
ENV PULSE_SERVER unix:/run/pulse/native

USER root

# Common utils
# Set non-interactive timezone configuration
RUN ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime && \
    apt-get update && \
    apt-get install -y tzdata && \
    dpkg-reconfigure --frontend noninteractive tzdata
# Install fundamental packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        apt-transport-https \
        apt-utils \
        build-essential \
        ca-certificates \
        curl \
        gnupg \
        locales \
        make \
        software-properties-common \
        wget && \
    rm -rf /var/lib/apt/lists/* && \
    locale-gen en_US.UTF-8
# Set locales
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Install operating system libraries or packages
RUN dpkg --add-architecture i386 && \
    apt-get update && apt-get install --no-install-recommends -y \
        alsa-base \
        alsa-utils \
        cups-browsed \
        cups-bsd \
        cups-common \
        cups-filters \
        printer-driver-cups-pdf \
        file \
        bzip2 \
        gzip \
        xz-utils \
        unar \
        rar \
        unrar \
        zip \
        unzip \
        zstd \
        gcc \
        git \
        jq \
        python3 \
        python3-cups \
        python3-numpy \
        ssl-cert \
        nano \
        vim \
        htop \
        fakeroot \
        fonts-dejavu \
        fonts-freefont-ttf \
        fonts-hack \
        fonts-liberation \
        fonts-noto \
        fonts-noto-cjk \
        fonts-noto-cjk-extra \
        fonts-noto-color-emoji \
        fonts-noto-extra \
        fonts-noto-ui-extra \
        fonts-noto-hinted \
        fonts-noto-mono \
        fonts-noto-unhinted \
        fonts-opensymbol \
        fonts-symbola \
        fonts-ubuntu \
        lame \
        less \
        libavcodec-extra \
        libpulse0 \
        pulseaudio \
        supervisor \
        net-tools \
        packagekit-tools \
        pkg-config \
        mesa-utils \
        va-driver-all \
        va-driver-all:i386 \
        i965-va-driver-shaders \
        i965-va-driver-shaders:i386 \
        intel-media-va-driver-non-free \
        intel-media-va-driver-non-free:i386 \
        libva2 \
        libva2:i386 \
        vainfo \
        vdpau-driver-all \
        vdpau-driver-all:i386 \
        vdpauinfo \
        mesa-vulkan-drivers \
        mesa-vulkan-drivers:i386 \
        libvulkan-dev \
        libvulkan-dev:i386 \
        vulkan-tools \
        ocl-icd-libopencl1 \
        clinfo \
        dbus-user-session \
        dbus-x11 \
        libdbus-c++-1-0v5 \
        xkb-data \
        xauth \
        xbitmaps \
        xdg-user-dirs \
        xdg-utils \
        xfonts-base \
        xfonts-scalable \
        xinit \
        xsettingsd \
        libxrandr-dev \
        x11-xkb-utils \
        x11-xserver-utils \
        x11-utils \
        x11-apps \
        xserver-xorg-input-all \
        xserver-xorg-input-wacom \
        xserver-xorg-video-all \
        xserver-xorg-video-intel \
        xserver-xorg-video-qxl \
        # Install OpenGL libraries
        libxau6 \
        libxau6:i386 \
        libxdmcp6 \
        libxdmcp6:i386 \
        libxcb1 \
        libxcb1:i386 \
        libxext6 \
        libxext6:i386 \
        libx11-6 \
        libx11-6:i386 \
        libxv1 \
        libxv1:i386 \
        libxtst6 \
        libxtst6:i386 \
        libglvnd0 \
        libglvnd0:i386 \
        libgl1 \
        libgl1:i386 \
        libglx0 \
        libglx0:i386 \
        libegl1 \
        libegl1:i386 \
        libgles2 \
        libgles2:i386 \
        libglu1 \
        libglu1:i386 \
        libsm6 \
        libsm6:i386 && \
    rm -rf /var/lib/apt/lists/* && \
    echo "/usr/local/nvidia/lib" >> /etc/ld.so.conf.d/nvidia.conf && \
    echo "/usr/local/nvidia/lib64" >> /etc/ld.so.conf.d/nvidia.conf && \
    # Configure OpenCL manually
    mkdir -pm755 /etc/OpenCL/vendors && echo "libnvidia-opencl.so.1" > /etc/OpenCL/vendors/nvidia.icd && \
    # Configure Vulkan manually
    VULKAN_API_VERSION=$(dpkg -s libvulkan1 | grep -oP 'Version: [0-9|\.]+' | grep -oP '[0-9]+(\.[0-9]+)(\.[0-9]+)') && \
    mkdir -pm755 /etc/vulkan/icd.d/ && echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libGLX_nvidia.so.0\",\n\
        \"api_version\" : \"${VULKAN_API_VERSION}\"\n\
    }\n\
}" > /etc/vulkan/icd.d/nvidia_icd.json && \
    # Configure EGL manually
    mkdir -pm755 /usr/share/glvnd/egl_vendor.d/ && echo "{\n\
    \"file_format_version\" : \"1.0.0\",\n\
    \"ICD\": {\n\
        \"library_path\": \"libEGL_nvidia.so.0\"\n\
    }\n\
}" > /usr/share/glvnd/egl_vendor.d/10_nvidia.json
# Expose NVIDIA libraries and paths
ENV PATH /usr/local/nvidia/bin:${PATH}
ENV LD_LIBRARY_PATH /usr/lib/x86_64-linux-gnu:/usr/lib/i386-linux-gnu${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}:/usr/local/nvidia/lib:/usr/local/nvidia/lib64
# Make all NVIDIA GPUs visible by default
ENV NVIDIA_VISIBLE_DEVICES all
# All NVIDIA driver capabilities should preferably be used, check `NVIDIA_DRIVER_CAPABILITIES` inside the container if things do not work
ENV NVIDIA_DRIVER_CAPABILITIES all
# Disable VSYNC for NVIDIA GPUs
ENV __GL_SYNC_TO_VBLANK 0

# Default environment variables (password is "mypasswd")
ENV TZ UTC
ENV SIZEW 1920
ENV SIZEH 1080
ENV REFRESH 60
ENV DPI 96
ENV CDEPTH 24
ENV VGL_DISPLAY egl
ENV PASSWD mypasswd
ENV NOVNC_ENABLE false
ENV WEBRTC_ENCODER nvh264enc
ENV WEBRTC_ENABLE_RESIZE false
ENV ENABLE_BASIC_AUTH true

# Set versions for components that should be manually checked before upgrading, other component versions are automatically determined by fetching the version online
ARG VIRTUALGL_VERSION=3.1
ARG NOVNC_VERSION=1.4.0

# Install Xvfb
RUN apt-get update && apt-get install --no-install-recommends -y \
        xvfb && \
    rm -rf /var/lib/apt/lists/*

# Install VirtualGL and make libraries available for preload
RUN curl -fsSL -O "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl_${VIRTUALGL_VERSION}_amd64.deb" && \
    curl -fsSL -O "https://github.com/VirtualGL/virtualgl/releases/download/${VIRTUALGL_VERSION}/virtualgl32_${VIRTUALGL_VERSION}_amd64.deb" && \
    apt-get update && apt-get install -y --no-install-recommends ./virtualgl_${VIRTUALGL_VERSION}_amd64.deb ./virtualgl32_${VIRTUALGL_VERSION}_amd64.deb && \
    rm -f "virtualgl_${VIRTUALGL_VERSION}_amd64.deb" "virtualgl32_${VIRTUALGL_VERSION}_amd64.deb" && \
    rm -rf /var/lib/apt/lists/* && \
    chmod u+s /usr/lib/libvglfaker.so && \
    chmod u+s /usr/lib/libdlfaker.so && \
    chmod u+s /usr/lib32/libvglfaker.so && \
    chmod u+s /usr/lib32/libdlfaker.so && \
    chmod u+s /usr/lib/i386-linux-gnu/libvglfaker.so && \
    chmod u+s /usr/lib/i386-linux-gnu/libdlfaker.so

# Install KDE and other GUI packages
ENV XDG_CURRENT_DESKTOP KDE
ENV XDG_SESSION_DESKTOP KDE
ENV XDG_SESSION_TYPE x11
ENV DESKTOP_SESSION plasma
ENV KDE_FULL_SESSION true
ENV KWIN_COMPOSE N
ENV KWIN_X11_NO_SYNC_TO_VBLANK 1
# Use sudoedit to change protected files instead of using sudo on kate
ENV SUDO_EDITOR kate
# Set input to fcitx
ENV GTK_IM_MODULE fcitx
ENV QT_IM_MODULE fcitx
ENV XIM fcitx
ENV XMODIFIERS "@im=fcitx"
# Enable AppImage execution in containers
ENV APPIMAGE_EXTRACT_AND_RUN 1
RUN mkdir -pm755 /etc/apt/preferences.d && echo "Package: firefox*\n\
Pin: version 1:1snap*\n\
Pin-Priority: -1" > /etc/apt/preferences.d/firefox-nosnap && \
    mkdir -pm755 /etc/apt/trusted.gpg.d && curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x0AB215679C571D1C8325275B9BDB3D89CE49EC21" | gpg --dearmor -o /etc/apt/trusted.gpg.d/mozillateam-ubuntu-ppa.gpg && \
    mkdir -pm755 /etc/apt/sources.list.d && echo "deb https://ppa.launchpadcontent.net/mozillateam/ppa/ubuntu $(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"') main" > "/etc/apt/sources.list.d/mozillateam-ubuntu-ppa-$(grep UBUNTU_CODENAME= /etc/os-release | cut -d= -f2 | tr -d '\"').list" && \
    apt-get update && apt-get install --no-install-recommends -y \
        kde-plasma-desktop \
        adwaita-icon-theme-full \
        appmenu-gtk3-module \
        ark \
        aspell \
        aspell-en \
        breeze \
        breeze-cursor-theme \
        breeze-gtk-theme \
        breeze-icon-theme \
        debconf-kde-helper \
        desktop-file-utils \
        dolphin \
        dolphin-plugins \
        dbus-x11 \
        enchant-2 \
        fcitx \
        fcitx-config-common \
        fcitx-config-gtk \
        fcitx-frontend-gtk2 \
        fcitx-frontend-gtk3 \
        fcitx-frontend-qt5 \
        fcitx-module-dbus \
        fcitx-module-kimpanel \
        fcitx-module-lua \
        fcitx-module-x11 \
        fcitx-tools \
        fcitx-hangul \
        fcitx-libpinyin \
        fcitx-m17n \
        fcitx-mozc \
        fcitx-sayura \
        fcitx-unikey \
        filelight \
        frameworkintegration \
        gwenview \
        haveged \
        hunspell \
        im-config \
        kate \
        kcalc \
        kcharselect \
        kdeadmin \
        kde-config-fcitx \
        kde-config-gtk-style \
        kde-config-gtk-style-preview \
        kdeconnect \
        kdegraphics-thumbnailers \
        kde-spectacle \
        kdf \
        kdialog \
        kget \
        kimageformat-plugins \
        kinfocenter \
        kio \
        kio-extras \
        kmag \
        kmenuedit \
        kmix \
        kmousetool \
        kmouth \
        ksshaskpass \
        ktimer \
        kwayland-integration \
        kwin-addons \
        kwin-x11 \
        libdbusmenu-glib4 \
        libdbusmenu-gtk3-4 \
        libgail-common \
        libgdk-pixbuf2.0-bin \
        libgtk2.0-bin \
        libgtk-3-bin \
        libkf5baloowidgets-bin \
        libkf5dbusaddons-bin \
        libkf5iconthemes-bin \
        libkf5kdelibs4support5-bin \
        libkf5khtml-bin \
        libkf5parts-plugins \
        libqt5multimedia5-plugins \
        librsvg2-common \
        media-player-info \
        mozc-utils-gui \
        okular \
        okular-extra-backends \
        partitionmanager \
        plasma-browser-integration \
        plasma-calendar-addons \
        plasma-dataengines-addons \
        plasma-discover \
        plasma-integration \
        plasma-runners-addons \
        plasma-widgets-addons \
        policykit-desktop-privileges \
        polkit-kde-agent-1 \
        print-manager \
        qapt-deb-installer \
        qml-module-org-kde-runnermodel \
        qml-module-org-kde-qqc2desktopstyle \
        qml-module-qtgraphicaleffects \
        qml-module-qtquick-xmllistmodel \
        qt5-gtk-platformtheme \
        qt5-image-formats-plugins \
        qt5-style-plugins \
        qtspeech5-flite-plugin \
        qtvirtualkeyboard-plugin \
        software-properties-qt \
        sonnet-plugins \
        sweeper \
        systemsettings \
        ubuntu-drivers-common \
        vlc \
        vlc-l10n \
        vlc-plugin-access-extra \
        vlc-plugin-notify \
        vlc-plugin-samba \
        vlc-plugin-skins2 \
        vlc-plugin-video-splitter \
        vlc-plugin-visualization \
        xdg-desktop-portal-kde \
        xdg-user-dirs \
        firefox \
        pavucontrol-qt \
        transmission-qt && \
    apt-get install --install-recommends -y \
        libreoffice \
        libreoffice-kf5 \
        libreoffice-plasma \
        libreoffice-style-breeze && \
    rm -rf /var/lib/apt/lists/* && \
    # Ensure Firefox is the default web browser
    update-alternatives --set x-www-browser /usr/bin/firefox && \
    # Fix KDE startup permissions issues in containers
    cp -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit /tmp/ && \
    rm -f /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    cp -r /tmp/start_kdeinit /usr/lib/x86_64-linux-gnu/libexec/kf5/start_kdeinit && \
    rm -f /tmp/start_kdeinit && \
    # KDE disable screen lock, double-click to open instead of single-click
    echo "[Daemon]\n\
Autolock=false\n\
LockOnResume=false" > /etc/xdg/kscreenlockerrc && \
    echo "[KDE]\n\
SingleClick=false\n\
\n\
[KDE Action Restrictions]\n\
action/lock_screen=false\n\
logout=false" > /etc/xdg/kdeglobals

# ORIGINAL CODE BELOW

# Create a user
RUN useradd -m admin

# Give sudo permission to the user "admin"
RUN apt-get update && apt-get install -y sudo
RUN echo "admin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
RUN chown -R admin:admin /home/admin

USER admin

WORKDIR /home/admin

# Docker
# https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository
RUN sudo install -m 0755 -d /etc/apt/keyrings && \
    sudo wget -O /etc/apt/keyrings/docker.asc \
        https://download.docker.com/linux/ubuntu/gpg && \
    echo "deb \
        [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] \
        https://download.docker.com/linux/ubuntu \
        $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
        sudo tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    sudo apt-get update && \
    sudo apt-get install -y \
        docker-ce \
        docker-ce-cli \
        containerd.io \
        docker-buildx-plugin \
        docker-compose-plugin && \
    # https://docs.docker.com/engine/install/linux-postinstall/
    sudo usermod -aG docker admin

# VS Code
# https://code.visualstudio.com/docs/setup/linux
RUN sudo wget -qO- https://packages.microsoft.com/keys/microsoft.asc | \
        sudo gpg --dearmor > packages.microsoft.gpg && \
    sudo install -D -o root -g root -m 644 packages.microsoft.gpg \
        /etc/apt/keyrings/packages.microsoft.gpg && \
    sudo sh -c 'echo "deb \
        [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] \
        https://packages.microsoft.com/repos/code stable main" > \
        /etc/apt/sources.list.d/vscode.list' && \
    rm -f packages.microsoft.gpg && \
    sudo apt-get update && \
    sudo apt-get install -y code

# Google Chrome
# https://zenn.dev/shimtom/articles/55fd2eb3d55c48
RUN sudo wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | \
    sudo gpg --dearmour -o /usr/share/keyrings/google-keyring.gpg && \
    sudo sh -c 'echo "deb \
        [arch=amd64 signed-by=/usr/share/keyrings/google-keyring.gpg] \
        http://dl.google.com/linux/chrome/deb/ stable main" >> \
        /etc/apt/sources.list.d/google-chrome.list' && \
    sudo apt-get update && \
    sudo apt-get install -y google-chrome-stable

# Chrome Remote Desktop
RUN sudo wget https://dl.google.com/linux/direct/chrome-remote-desktop_current_amd64.deb && \
    sudo DEBIAN_FRONTEND=noninteractive \
        apt-get install -y ./chrome-remote-desktop_current_amd64.deb && \
    rm -f chrome-remote-desktop_current_amd64.deb

CMD ["tail", "-f", "/dev/null"]
