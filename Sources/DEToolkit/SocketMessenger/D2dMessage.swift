//
//  D2dMessage.swift
//  DEToolkit
//
//  Created by Le Cuong on 5/5/25.
//

public class D2dMessage {
    enum BodyType {
        case path
        case bytes
    }
    
    let bodyType = BodyType.bytes
    var header = [String: String]()
    let body: SocketMessageValue //TODO rename
    var bodyCount = 0
    
    public init(header: [String: String], body: SocketMessageValue) {
        self.header = header
        self.body = body
    }

    public func addHeader(key: String, value: String) {
        header[key] = value
    }
}

public struct SimpleFileHeaderFormat {
    let version: String = "0.0.1"
    let num: String
    let total: String
    let fileName: String
    let fileLength: String
    let fileType: String
    
    public func toMap() -> [String: String] {
        var map = [String: String]()
        map["version"] = version
        map["num"] = num
        map["total"] = total
        map["fileName"] = fileName
        map["fileLength"] = fileLength
        map["fileType"] = fileType
        return map
    }
}
