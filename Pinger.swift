//
//  Pinger.swift
//  PingBar
//
//  Created by Peter Kristensen on 20/11/2021.
//

import Foundation

class Pinger {
    private var host: String
    
    init(withHost: String) {
        host = withHost
    }
    
    func pingOnce() -> TimeInterval {
        let task = Process()
        let date = Date()
        
        task.launchPath = "/sbin/ping"
        task.arguments = [
            "-o",
            "-c", "1",
            "-q", host
        ]
        let pipe = Pipe()
        task.standardOutput = pipe
        task.launch()
        task.waitUntilExit()
        
        let termStatus = task.terminationStatus
            
        let hd = pipe.fileHandleForReading
        let data = hd.readDataToEndOfFile()
        
        let string = String(data: data, encoding: .utf8)
        if termStatus != 0 {
            print("infinity: %d", termStatus)
            return -1
        }
        
        var dt = Date().timeIntervalSince(date)
        string?.enumerateLines(invoking: { str, stop in
            if str.hasPrefix("round-trip") {
                stop = true
                let comps = str.components(separatedBy: CharacterSet(charactersIn: "/ "))
                
                for obj in comps {
                    let obj = obj as NSString
                    let d = TimeInterval(obj.floatValue)
                    if d != 0.0 {
                        dt = d / 1000.0
                        break
                    }
                }
            }

        })
        
        return dt
    }
}
