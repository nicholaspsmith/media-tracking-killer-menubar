# Media Tracking Killer

<p align="center"><img src="docs/mascot.png" width="160" alt="Media Tracking Killer mascot, from the Menubarn widget library"></p>

<p align="center">Part of the <a href="https://widgets.nicksmith.software">Menubarn</a> widget library.</p>

Menu-bar app that periodically stops Apple's media-analysis daemons
(`mediaanalysisd`, `mediaanalysisd-access`, `photoanalysisd`) with SIGINT.
Built on [StatusItemKit](https://github.com/nicholaspsmith/StatusItemKit);
replaces the old `killapplemediatracking.sh` shell loop + launchd agent.

- **Green crossed-out eye** — active, killing on the configured interval
- **Gray crossed-out eye** — paused

## Menu

| Item | Purpose |
|---|---|
| Enabled | master on/off toggle |
| Kill Now | sweep immediately |
| Check Interval | 5 / 15 / 30 / 60 seconds (default 15) |
| Processes to Kill | toggle each daemon individually |
| Start at Login | SMAppService — no launchd agent |

Settings persist in `defaults` domain `com.nicholaspsmith.MediaTrackingKiller`.

## Requirements

- macOS 13+ (SMAppService), Xcode Command Line Tools
- [StatusItemKit](https://github.com/nicholaspsmith/StatusItemKit) checked out
  as a **sibling** directory (local SPM path dependency)

## Install

```sh
git clone https://github.com/nicholaspsmith/StatusItemKit.git
git clone https://github.com/nicholaspsmith/media-tracking-killer-menubar.git
cd media-tracking-killer-menubar
./install.sh
```

`install.sh` builds the app, symlinks it into `~/Applications`, retires the
legacy `com.user.killapplemediatracking` launchd agent if present, and
launches the app.

## Uninstall

```sh
osascript -e 'quit app "Media Tracking Killer"'
rm "$HOME/Applications/Media Tracking Killer.app"
defaults delete com.nicholaspsmith.MediaTrackingKiller
```

(Disable Start at Login from the menu first, or remove the entry under
System Settings ▸ General ▸ Login Items.)

## Why not a SwiftBar plugin?

This is a standalone `.app` built on [StatusItemKit](https://github.com/nicholaspsmith/StatusItemKit), not a script under a plugin host: no SwiftBar to install, a real AppKit menu instead of rendered stdout, event-driven updates instead of a re-run timer, and an icon that keeps its place in the bar. It replaced a shell loop plus a launchd agent; now the interval, the status icon and Start at Login are one app with no host. The full comparison is in [StatusItemKit's README](https://github.com/nicholaspsmith/StatusItemKit#why-not-swiftbar).

## The menu-bar suite

Part of a suite of macOS menu-bar apps that share one framework, one
build-and-sign script, and one installer. They are designed to sit in the
same bar together: consistent menus, a common **Icon** picker for shape and
colour, and cooperative hiding so no icon strands another.

| App | What it does |
|---|---|
| [Claude Usage](https://github.com/nicholaspsmith/claude-usage-menubar) | Claude Code plan limits, resets, and live agent sessions |
| [Apollo Monitor](https://github.com/nicholaspsmith/apollo-monitor-menubar) | Universal Audio Apollo monitor level, plus a UA process watchdog |
| [Battery Time](https://github.com/nicholaspsmith/battery-time-menubar) | Time remaining, power mode, and 24h usage |
| [VPN & DNS](https://github.com/nicholaspsmith/vpn-dns-menubar) | One dot for Mullvad + Tailscale state, with a DNS watcher |
| [Process Monitor](https://github.com/nicholaspsmith/MacOS_Process_Monitor) | Process-count sparkline against the per-UID limit |
| [KeyLight](https://github.com/nicholaspsmith/keylight-menubar) | Ctrl+brightness keys remapped to keyboard backlight |
| [MacRecorder](https://github.com/nicholaspsmith/MacRecorder) | Screen recording with system audio |
| **Media Tracking Killer** | Kills Apple's media tracking daemons |
| [Download Recycler](https://github.com/nicholaspsmith/download-recycler-menubar) | Sweeps stale files out of ~/Downloads |
| [Curtain](https://github.com/nicholaspsmith/menubar-curtain) | Hides a block of status icons by width, so it cannot strand one |

| Framework | |
|---|---|
| [StatusItemKit](https://github.com/nicholaspsmith/StatusItemKit) | Status-item lifecycle, polling, menus, meter icons, the shared Icon picker |
| [HotkeyKit](https://github.com/nicholaspsmith/HotkeyKit) | CGEventTap engine for intercepting and remapping global keys |

Install the whole suite on a fresh Mac with
[macOS Dev Environment Setup](https://github.com/nicholaspsmith/MacOS-Dev-Environment-Setup):

```bash
git clone https://github.com/nicholaspsmith/MacOS-Dev-Environment-Setup.git
cd MacOS-Dev-Environment-Setup && ./bootstrap.sh --all
```
