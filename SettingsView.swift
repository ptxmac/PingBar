//
//  SettingsView.swift
//  PingBar
//
//  Created by Peter Kristensen on 20/11/2021.
//

import SwiftUI

struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context _: Context) -> NSView {
        let view = NSView()
        DispatchQueue.main.async {
            self.window = view.window
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

struct SettingsView: View {
    @AppStorage("pingHost") var host = ""
    @AppStorage("pingDelay") var delay = 1.0

    @AppStorage("timePrecision") var precision = 2.0

    @AppStorage("doPing") var enabled = false

    @State var window: NSWindow?

    var body: some View {
        Form {
            TextField("Host", text: $host)
            HStack {
                Slider(value: $delay, in: 0.5 ... 5) {
                    Text("Delay")
                }
                Text("\(String(format: "%.2f", delay))")
            }
            HStack {
                Slider(value: $precision, in: 0 ... 5, step: 1) {
                    Text("Precision")
                }
                Text("\(String(format: "%.0f", precision))")
            }
            Toggle("Enabled", isOn: $enabled)
        }
        .background(WindowAccessor(window: $window))
        .padding(.all, 20)
        .frame(width: 300)
        .onAppear() {
            NSApp.setActivationPolicy(.regular)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.willCloseNotification)) { n in
            let w = n.object as? NSWindow
            if window == w {
                NSApp.setActivationPolicy(.accessory)

            }
        }
        
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
