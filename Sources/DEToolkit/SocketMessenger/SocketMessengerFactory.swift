//
//  SocketMessengerFactory.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//

import Foundation

// D2dMessenger is a protocol for d2d communication.
// SocketMessenger implements D2dMessenger.
// SecureSockeMessenger inherits SocketMessenger
@available(iOS 13.0, *)
class SocketMessengerFactory {
    class func create(address: String, port: Int, secured: Bool = false, delegate: SocketMessengerDelegate? = nil) -> D2dMessenger {
        print("isSecureMode:\(secured)")

        if secured {
            return SecuredSocketMessenger(address: address, port: port, delegate: delegate)
        } else {
            return SocketMessenger(address: address, port: port, delegate: delegate)
        }
    }
}
