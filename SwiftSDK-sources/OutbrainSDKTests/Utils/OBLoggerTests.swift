//
//  OBLoggerTests.swift
//  OutbrainSDKTests
//
//  Created by Dror Seltzer on 12/07/2023.
//

import XCTest
@testable import OutbrainSDK

final class OBLoggerTests: XCTestCase {

    func testPrintLogsNoLogs() {
        let loggerMock = OBLoggerMock()
        
        loggerMock.printLogs(domain: nil)
        
        XCTAssertEqual(loggerMock.printedLogs.count, 0)
        XCTAssertEqual(loggerMock.printedLogs, [])
    }
    
    func testPrintLogs() {
        var loggerMock = OBLoggerMock()
        let log1 = OBLog(message: "Log message", level: .log, printLog: true)
        let log2 = OBLog(message: "Debug message", level: .debug, printLog: true)
        let log3 = OBLog(message: "Warn message", level: .warn, printLog: true)
        let log4 = OBLog(message: "Error message", level: .error, printLog: true)
        loggerMock.printLog(log1)
        loggerMock.printLog(log2)
        loggerMock.printLog(log3)
        loggerMock.printLog(log4)
        
        loggerMock.printLogs(domain: nil)
        
        XCTAssertEqual(loggerMock.printedLogs.count, 4)
        XCTAssertTrue(loggerMock.printedLogs[0].contains("[OUTBRAIN-SDK]-[LOG]: Log message"))
        XCTAssertTrue(loggerMock.printedLogs[1].contains("[OUTBRAIN-SDK]-[DEBUG]: Debug message"))
        XCTAssertTrue(loggerMock.printedLogs[2].contains("[OUTBRAIN-SDK]-[WARN]: Warn message"))
        XCTAssertTrue(loggerMock.printedLogs[3].contains("[OUTBRAIN-SDK]-[ERROR]: Error message"))
    }
    
    func testPrintLogsForDomain() {
        var loggerMock = OBLoggerMock()
        let log1 = OBLog(message: "Log message 1", level: .log, domain: "domain1", printLog: true)
        let log2 = OBLog(message: "Log message 2", level: .log, domain: "domain2", printLog: true)
        loggerMock.printLog(log1)
        loggerMock.printLog(log2)
        
        loggerMock.printLogs(domain: "domain1")
                
        XCTAssertEqual(loggerMock.printedLogs.count, 2)
        XCTAssertTrue(loggerMock.printedLogs[0].contains("[OUTBRAIN-SDK-DOMAIN1]-[LOG]: Log message 1"))
        XCTAssertTrue(loggerMock.printedLogs[1].contains("[OUTBRAIN-SDK-DOMAIN2]-[LOG]: Log message 2"))
    }

}

protocol OBLogger {
    func printLogs(domain: String?)
    mutating func printLog(_ log: OBLog)
}

struct OBLoggerMock: OBLogger {
    
    var printedLogs: [String] = []
    
    func printLogs(domain: String?) {
        // Implement mock behavior
    }
    
    mutating func printLog(_ log: OBLog) {
        let formattedLog = log.formattedLog
        printedLogs.append(formattedLog)
    }
}
