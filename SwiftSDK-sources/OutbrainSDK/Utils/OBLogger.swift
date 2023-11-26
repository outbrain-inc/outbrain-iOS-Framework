//
//  OBLogger.swift
//  OutbrainSDK
//
//  Created by Dror Seltzer on 06/07/2023.
//

import Foundation

public struct OBLogger {
   
    // store all logs
    var logs: [OBLog] = []
        
    init() {
    }
    
    // MARK: Logging methods
    
    // Log
    public mutating func log(_ message: String, domain: String? = nil, printLog: Bool = true) {
        let log = OBLog(message: message, level: .log, domain: domain, printLog: printLog)
        addLog(log)
    }
    
    // Debug
    public mutating func debug(_ message: String, domain: String? = nil, printLog: Bool = true) {
        let log = OBLog(message: message, level: .debug, domain: domain, printLog: printLog)
        addLog(log)
    }
    
    // Warn
    public mutating func warn(_ message: String, domain: String? = nil, printLog: Bool = true) {
        let log = OBLog(message: message, level: .warn, domain: domain, printLog: printLog)
        addLog(log)
    }
    
    // Error
    public mutating func error(_ message: String, domain: String? = nil, printLog: Bool = true) {
        let log = OBLog(message: message, level: .error, domain: domain, printLog: printLog)
        addLog(log)
    }
    
    // MARK: Private methods
    
    // Add log to logs array and print it if needed
    private mutating func addLog(_ log: OBLog) {
        // add log to logs array
        logs.append(log)
        
        // print log if needed
        if log.printLog {
            printLog(log)
        }
    }
    
    // Print log
    private func printLog(_ log:OBLog) {
        // format log string
        let formattedLog = log.formattedLog
        
        // print log
        print("\(formattedLog)")
    }
    
    // Print all logs and filter debug logs in release mode
    public func printLogs(domain: String? = nil) {
        var logsArr = self.logs

        // filter logs by domain if needed
        if let domainNameFilter = domain {
            logsArr = self.logs.filter { $0.domain == domainNameFilter }
        }
        
        // check if logs array is empty
        if logsArr.isEmpty {
            print("No logs")
        }
        
        // iterate over all logs
        logsArr.forEach { log in
            // check if log should be printed - debng logs should be printed only in debug mode
            if log.level != .debug {
                printLog(log)
            } else {
                #if DEBUG
                printLog(log)
                #endif
            }
        }
    }
}

struct OBLog {
    let message: String
    let level: OBLogLevels
    let timestamp: Date
    let printLog: Bool
    let domain: String?
    
    // date format for printing
    static let dateFormat = "yyyy-MM-dd HH:mm:ss"
    
    // Format log string getter
    var formattedLog: String {
        
        // get log level string
        let logLevelString = self.logLevelString
        
        // format timestamp
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = OBLog.dateFormat
        let timestamp = dateFormatter.string(from: timestamp)
        
        // format domain
        var domainStr: String = ""
        if self.domain == nil {
            domainStr = "[OUTBRAIN-SDK]"
        } else {
            domainStr = "[OUTBRAIN-SDK-\(self.domain!.uppercased())]"
        }

        // return formatted log string
        return "\(domainStr)-[\(logLevelString.uppercased())]: \(self.message) - \(timestamp)"
    }
    
    // Get log level string
    var logLevelString:String {
        switch self.level {
        case .log:
            return "log"
        case .debug:
            return "debug"
        case .warn:
            return "warn"
        case .error:
            return "error"
        }
    }
    
    init(message: String, level: OBLogLevels, domain: String? = nil, printLog: Bool) {
        self.message = message
        self.level = level
        self.timestamp = Date() // get current timestamp
        self.printLog = printLog
        self.domain = domain
    }
}

public enum OBLogLevels: String {
    case log
    case debug
    case warn
    case error
}
