#!/bin/bash -e

# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.

# Source environment for GStreamer
source /opt/gstreamer/gst-env

# Set default display
export DISPLAY="${DISPLAY:-:0}"

# Configure joystick interposer
sudo mkdir -pm755 /dev/input
sudo touch /dev/input/{js0,js1,js2,js3}

# Show debug logs for GStreamer
export GST_DEBUG="${GST_DEBUG:-*:2}"
# Set password for basic authentication
if [ "${ENABLE_BASIC_AUTH,,}" = "true" ] && [ -z "$BASIC_AUTH_PASSWORD" ]; then export BASIC_AUTH_PASSWORD="$PASSWD"; fi

# Wait for X11 to start
echo "Waiting for X socket"
until [ -S "/tmp/.X11-unix/X${DISPLAY/:/}" ]; do sleep 1; done
echo "X socket is ready"

# Write Progressive Web App (PWA) configuration
export PWA_APP_NAME="Selkies WebRTC"
export PWA_APP_SHORT_NAME="selkies"
export PWA_START_URL="/index.html"
sudo sed -i \
    -e "s|PWA_APP_NAME|${PWA_APP_NAME}|g" \
    -e "s|PWA_APP_SHORT_NAME|${PWA_APP_SHORT_NAME}|g" \
    -e "s|PWA_START_URL|${PWA_START_URL}|g" \
/opt/gst-web/manifest.json && \
sudo sed -i \
    -e "s|PWA_CACHE|${PWA_APP_SHORT_NAME}-webrtc-pwa|g" \
/opt/gst-web/sw.js

# Clear the cache registry
rm -rf "${HOME}/.cache/gstreamer-1.0"

# Start the selkies-gstreamer WebRTC HTML5 remote desktop application
selkies-gstreamer \
    --addr="0.0.0.0" \
    --port="8080" \
    $@
