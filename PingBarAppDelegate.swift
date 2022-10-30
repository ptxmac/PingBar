//
//  PingBarAppDelegate.swift
//  PingBar
//
//  Created by Peter Kristensen on 20/11/2021.
//

import Foundation
import MenuBuilder
import SwiftUI

class PingBarAppDelegate: NSObject, NSApplicationDelegate {
    private var barItem: NSStatusItem?
    private var pingQueue = OperationQueue()
    private var lastReply = Date()

    @AppStorage("doPing") var enabled = false
    @AppStorage("pingHost") var host = "localhost"
    @AppStorage("pingDelay") var delay: TimeInterval = 1.0
    @AppStorage("maxPings") var maxPings = 10
    @AppStorage("timePrecision") var precision = 2

    private var pinger: Pinger?
    private var pingTimer: Timer?

    func stopPinging() {
        guard let timer = pingTimer else {
            return
        }
        timer.invalidate()
    }

    func updateTime() {
        let secs = Date().timeIntervalSince(lastReply)
        let str = String(format: "%%.%df", precision)
        barItem?.button?.title = String(format: str, secs)
    }

    func startPinging() {
        if !enabled {
            return
        }
        pinger = Pinger(withHost: host)

        lastReply = Date()

        updateTime()
        pingTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: true, block: { _ in
            guard let pinger = self.pinger else {
                print("missing pinger")
                return
            }

            if self.pingQueue.operationCount < self.maxPings {
                self.pingQueue.addOperation {
                    let delay = pinger.pingOnce()
                    OperationQueue.main.addOperation {
                        if delay >= 0.0 {
                            self.lastReply = Date().addingTimeInterval(-delay)
                        }
                        self.updateTime()
                    }
                }
            } else {
                self.updateTime()
            }
        })
    }

    func applicationDidFinishLaunching(_: Notification) {
        UserDefaults.standard.register(defaults: [
            "pingDelay": 1.0,
            "pingHost": "localhost",
            "doPing": false,
            "timePrecision": 0,
            "maxPings": 10, // TODO: add to ui!
        ])

        NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
                                               object: UserDefaults.standard,
                                               queue: nil) { _ in
            self.stopPinging()
            self.startPinging()
        }

        let bar = NSStatusBar.system
        let item = bar.statusItem(withLength: NSStatusItem.variableLength)
        item.button?.title = "Test"
        
        var prefName = "Preferences…"
        if #available(macOS 13.0, *) {
            prefName = "Settings…"
        }
            
        
        

        let menu = NSMenu {
            MenuItem(prefName).onSelect {
                if #available(macOS 13.0, *) {
                    NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
                } else {
                    NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
                }
                NSApp.activate(ignoringOtherApps: true)
            }
            MenuItem("About").onSelect {
                NSApp.orderFrontStandardAboutPanel(nil)
                NSApp.activate(ignoringOtherApps: true)
            }

            SeparatorItem()
            MenuItem("Quit").onSelect {
                NSApp.terminate(nil)
            }
        }

        item.menu = menu

        barItem = item

        startPinging()
    }
}
