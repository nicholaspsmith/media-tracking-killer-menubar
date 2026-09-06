import AppKit
import StatusItemKit

/// Menu-bar app that periodically SIGINTs Apple's media-analysis daemons
/// (mediaanalysisd & friends), replacing the old always-on shell loop +
/// launchd agent. The icon is a crossed-out eye: green = actively killing,
/// gray = paused.
final class App: NSObject, NSApplicationDelegate {
    private var controller: StatusItemController!
    /// Gives up this item's width while Curtain reveals its hidden block, so the
    /// block has room to land; restores itself from the TTL if Curtain vanishes.
    private var yieldClient: YieldClient!
    private let defaults = UserDefaults.standard

    /// Daemons this app targets. Each is individually toggleable in the menu.
    private let targets: [(process: String, label: String)] = [
        ("mediaanalysisd", "mediaanalysisd (media analysis)"),
        ("mediaanalysisd-access", "mediaanalysisd-access"),
        ("photoanalysisd", "photoanalysisd (photo analysis)"),
    ]
    private let intervalChoices = [5, 15, 30, 60]

    private var killsThisSession = 0
    private var lastSweep = Date.distantPast

    // MARK: - Settings (UserDefaults-backed)

    private var enabled: Bool {
        get { defaults.object(forKey: "enabled") as? Bool ?? true }
        set { defaults.set(newValue, forKey: "enabled"); poll() }
    }
    private var intervalSeconds: Int {
        get {
            let v = defaults.integer(forKey: "intervalSeconds")
            return intervalChoices.contains(v) ? v : 15
        }
        set { defaults.set(newValue, forKey: "intervalSeconds") }
    }
    private func targetEnabled(_ process: String) -> Bool {
        defaults.object(forKey: "target.\(process)") as? Bool ?? true
    }
    private func setTargetEnabled(_ process: String, _ on: Bool) {
        defaults.set(on, forKey: "target.\(process)")
    }

    // MARK: - Lifecycle

    func applicationDidFinishLaunching(_ notification: Notification) {
        controller = StatusItemController(
            pollInterval: 5,
            onPoll: { [weak self] in self?.poll() },
            onBuildMenu: { [weak self] menu in self?.buildMenu(menu) }
        )
        controller.start()
        yieldClient = YieldClient(item: controller)
        yieldClient.start()
    }

    /// Runs every 5s: refresh the icon, and sweep when the configured
    /// interval has elapsed.
    private func poll() {
        if enabled && Date().timeIntervalSince(lastSweep) >= Double(intervalSeconds) {
            sweep()
        }
        let color: NSColor = enabled ? .systemGreen : .systemGray
        controller.setIcon(MeterIcon.symbol("eye.slash", color: color))
    }

    /// SIGINT every enabled target. killall exits non-zero when nothing
    /// matched, which Shell.run reports as nil — so non-nil means we hit one.
    private func sweep() {
        lastSweep = Date()
        for target in targets where targetEnabled(target.process) {
            if Shell.run("/usr/bin/killall", ["-SIGINT", target.process]) != nil {
                killsThisSession += 1
            }
        }
    }

    // MARK: - Menu

    private func buildMenu(_ menu: NSMenu) {
        let mono = NSFont.monospacedSystemFont(ofSize: 12, weight: .regular)
        let status = enabled ? "active — killing every \(intervalSeconds)s" : "paused"
        let header = NSMenuItem()
        header.view = MenuBuilder.textView(
            "Media Tracking Killer: \(status)\nkills this session: \(killsThisSession)",
            font: mono)
        menu.addItem(header)
        menu.addItem(NSMenuItem.separator())

        let toggle = NSMenuItem(title: "Enabled",
                                action: #selector(toggleEnabled), keyEquivalent: "e")
        toggle.target = self
        toggle.state = enabled ? .on : .off
        menu.addItem(toggle)

        let killNow = NSMenuItem(title: "Kill Now",
                                 action: #selector(killNow), keyEquivalent: "k")
        killNow.target = self
        menu.addItem(killNow)

        // Interval radio submenu
        let intervalItem = NSMenuItem(title: "Check Interval", action: nil, keyEquivalent: "")
        let intervalMenu = NSMenu()
        for seconds in intervalChoices {
            let item = NSMenuItem(title: "\(seconds) seconds",
                                  action: #selector(setInterval(_:)), keyEquivalent: "")
            item.target = self
            item.tag = seconds
            item.state = seconds == intervalSeconds ? .on : .off
            intervalMenu.addItem(item)
        }
        intervalItem.submenu = intervalMenu
        menu.addItem(intervalItem)

        // Per-target checkboxes submenu
        let targetsItem = NSMenuItem(title: "Processes to Kill", action: nil, keyEquivalent: "")
        let targetsMenu = NSMenu()
        for (index, target) in targets.enumerated() {
            let item = NSMenuItem(title: target.label,
                                  action: #selector(toggleTarget(_:)), keyEquivalent: "")
            item.target = self
            item.tag = index
            item.state = targetEnabled(target.process) ? .on : .off
            targetsMenu.addItem(item)
        }
        targetsItem.submenu = targetsMenu
        menu.addItem(targetsItem)

        menu.addItem(NSMenuItem.separator())

        let login = NSMenuItem(title: "Start at Login",
                               action: #selector(toggleLogin), keyEquivalent: "")
        login.target = self
        login.state = LoginItem.isEnabled ? .on : .off
        menu.addItem(login)

        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
    }

    // MARK: - Actions

    @objc private func toggleEnabled() { enabled.toggle() }
    @objc private func killNow() { sweep(); poll() }
    @objc private func setInterval(_ sender: NSMenuItem) { intervalSeconds = sender.tag }
    @objc private func toggleTarget(_ sender: NSMenuItem) {
        let process = targets[sender.tag].process
        setTargetEnabled(process, !targetEnabled(process))
    }
    @objc private func toggleLogin() { LoginItem.toggle() }
}

let app = NSApplication.shared
let delegate = App()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
