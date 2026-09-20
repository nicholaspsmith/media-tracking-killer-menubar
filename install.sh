#!/usr/bin/env bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at https://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2026 Nicholas Smith

# Build Media Tracking Killer.app and symlink it into ~/Applications
# (rebuilds propagate; SMAppService accepts a symlink there for Start at Login).
# Also retires the legacy shell-loop launchd agent this app replaces.
set -euo pipefail

SRC_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME="Media Tracking Killer.app"

"$SRC_DIR/scripts/build-app.sh"

mkdir -p "$HOME/Applications"
ln -sfn "$SRC_DIR/build/$APP_NAME" "$HOME/Applications/$APP_NAME"
echo "Linked $HOME/Applications/$APP_NAME -> $SRC_DIR/build/$APP_NAME"

# --- retire the legacy launchd agent + shell loop this app replaces ---------
LEGACY_LABEL="com.user.killapplemediatracking"
LEGACY_PLIST="$HOME/Library/LaunchAgents/$LEGACY_LABEL.plist"
if [ -f "$LEGACY_PLIST" ]; then
    launchctl bootout "gui/$(id -u)/$LEGACY_LABEL" 2>/dev/null || true
    rm -f "$LEGACY_PLIST"
    rm -f "$HOME/background_scripts/killapplemediatracking.sh"
    echo "Retired legacy $LEGACY_LABEL launchd agent."
fi

# Register Start at Login. Without this the app only runs until the next reboot,
# and a menu-bar app that quietly fails to come back is easy to miss for weeks.
# SMAppService can only register the calling process's own bundle, so this has
# to run the installed binary rather than call launchctl.
if "$HOME/Applications/$APP_NAME/Contents/MacOS/MediaTrackingKiller" --login on >/dev/null; then
    echo "Start at Login: on"
else
    echo "Start at Login: could not register (turn it on from the menu)" >&2
fi

open "$HOME/Applications/$APP_NAME"

cat <<'EOF'

Media Tracking Killer is running in the menu bar (green dot = active).

Menu options
  - Enabled: master on/off toggle (gray dot when paused)
  - Kill Now: sweep immediately
  - Check Interval: 5 / 15 / 30 / 60 seconds
  - Processes to Kill: toggle each daemon individually
  - Start at Login: SMAppService (no launchd agent needed)
EOF
