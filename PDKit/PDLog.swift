//
// Created by Juliya Smith on 12/24/19.
// Copyright (c) 2019 Juliya Smith. All rights reserved.
//

import Foundation


public class PDLog<T> {

    private enum LogStatus: String {
        case INFO = "INFO"
        case WARN = "WARN"
        case ERROR = "ERROR"
    }
    
    private var symbolMap: [LogStatus: String] = [
        .INFO: "🔎",
        .WARN: "⚠️",
        .ERROR: "🛑"
    ]

    private var context: String

    public init() {
        self.context = String(describing: T.self)
    }

    public func info(_ message: String) {
        printMessage(message, status: .INFO)
    }

    public func warn(_ message: String) {
        printMessage(message, status: .WARN)
    }

    public func error(_ message: String) {
        printMessage(message, status: .ERROR)
    }

    public func error(_ message: String, _ error: Error) {
        printMessage("message. \(String(describing: error))", status: .ERROR)
    }

    public func error(_ error: Error) {
        printMessage(String(describing: error), status: .ERROR)
    }

    private func printMessage(_ message: String, status: LogStatus) {
        let symbol = symbolMap[status] ?? ""
        print("\(symbol) \(status.rawValue) (\(context)) \(symbol) - \(message).")
    }
}