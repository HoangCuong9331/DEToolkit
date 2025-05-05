//
//  TraceError.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//


open class TraceError: Error, @unchecked Sendable {
    public enum ErrorCode: String {
        case module_msf = "2"
        case module_ocf = "3"
        case module_server = "4"
    }
    public let message: String
    public let code: String
    public let userInfo: Any?
    public let prevError: TraceError?
    private let errorPlace: String

    public init(message: String = "", code: String = "", userInfo: Any? = nil, prevError: TraceError? = nil, file: String = #file, function: String = #function, line: UInt = #line) {
        self.message = message
        self.code = code
        self.userInfo = userInfo
        self.prevError = prevError
        self.errorPlace = "\(file) \(line): \(function) -"
    }

    public func getStackTrace() -> String {
        return getStackTrace(depth: 1)
    }

    private func getStackTrace(depth: Int) -> String {
        let prefix = depth == 1 ? "🔶[ERROR TRACE]🔶\n\t 🔶 " : ""
        return "\(prefix)\(errorPlace) \(String(describing: self)): \(message) \(prevError != nil ? "\n\t 🔶" : "") \(prevError?.getStackTrace(depth: depth + 1) ?? "")"
    }

    public func getSourceError() -> TraceError {
        return prevError?.getSourceError() ?? self
    }

    public func generateErrorCode() -> String {
        return "\(code)\(prevError?.generateErrorCode() ?? "")"
    }
}
