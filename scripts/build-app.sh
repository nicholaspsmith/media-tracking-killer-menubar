#!/bin/bash
# Build Media Tracking Killer.app in ./build/ via StatusItemKit's shared
# bundler (requires ../StatusItemKit checked out as a sibling).
set -euo pipefail
cd "$(dirname "$0")/.."
exec ../StatusItemKit/scripts/make-app.sh MediaTrackingKiller "Media Tracking Killer"
