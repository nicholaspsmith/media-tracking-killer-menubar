# Media Tracking Killer

Menu-bar app that periodically stops Apple's media-analysis daemons
(`mediaanalysisd`, `mediaanalysisd-access`, `photoanalysisd`) with SIGINT.
Built on [StatusItemKit](https://github.com/nicholaspsmith/StatusItemKit);
replaces the old `killapplemediatracking.sh` shell loop + launchd agent.

- **Green dot** — active, killing on the configured interval
- **Gray dot** — paused

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
