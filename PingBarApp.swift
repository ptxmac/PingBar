//
//  PingBarApp.swift
//  PingBar
//
//  Created by Peter Kristensen on 20/11/2021.
//

import MenuBuilder
import SwiftUI

@main
struct PingBarApp: App {
    @NSApplicationDelegateAdaptor(PingBarAppDelegate.self) var delegate

    var body: some Scene {
        Settings {
            SettingsView()
        }
    }
}
