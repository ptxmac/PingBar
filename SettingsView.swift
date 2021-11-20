//
//  SettingsView.swift
//  PingBar
//
//  Created by Peter Kristensen on 20/11/2021.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("pingHost") var host = ""
    @AppStorage("pingDelay") var delay = 1.0
    
    @AppStorage("timePrecision") var precision = 2.0
    
    @AppStorage("doPing") var enabled = false

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
        .padding(.all, 20)
        .frame(width: 300)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
