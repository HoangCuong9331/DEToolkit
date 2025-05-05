//
//  D2dConnectionInfo.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//

import UIKit
import Combine

// MARK: - A struct representing information required to establish a D2D connection
public struct D2dConnectionInfo {
    // Enum to represent the type of connection: either socket or samba
    public enum ConnectionType {
       case socket  // Represents a direct socket connection (TCP/IP)
       case samba   // Represents a Samba (SMB) connection (file sharing protocol)
    }

    // The type of connection being established (socket or samba)
    public let type: ConnectionType

    // The IP address of the device to connect to
    public let ip: String

    // The port number to connect to on the remote device
    public let port: Int

    // A security key (e.g., shared secret) used to authenticate or secure the connection
    public let secKey: String

    // Indicates whether the connection should use an additional layer of security (e.g., TLS)
    public var secured: Bool = false

    /// Initializes a new D2dConnectionInfo.
    /// - Parameters:
    ///   - type: Connection type
    ///   - ip: IP address of the remote device
    ///   - port: Port number
    ///   - secKey: Security key
    ///   - secured: Secured connection flag (default: `false`)
    public init(
        type: ConnectionType,
        ip: String,
        port: Int,
        secKey: String,
        secured: Bool = false
    ) {
        self.type = type
        self.ip = ip
        self.port = port
        self.secKey = secKey
        self.secured = secured
    }
}

/// A service responsible for sending and receiving D2D messages using a messenger over socket or samba.
/// This version is adapted to use Combine for reactive programming.
@available(iOS 13.0, *)
public class D2dService {
    let messenger: D2dMessenger
    let connectionInfo: D2dConnectionInfo

    public init(connectionInfo: D2dConnectionInfo, delegate: SocketMessengerDelegate? = nil) {
        self.connectionInfo = connectionInfo
        switch connectionInfo.type {
        case .socket:
            messenger = SocketMessengerFactory.create(address: connectionInfo.ip, port: connectionInfo.port, secured: connectionInfo.secured, delegate: delegate)
        case .samba:
            // TODO: Implement SambaMessenger
            messenger = SocketMessengerFactory.create(address: connectionInfo.ip, port: connectionInfo.port, delegate: delegate)
        }
    }

    public func open() {
        messenger.open()
    }

    public func send(message: D2dMessage) -> AnyPublisher<Bool, TraceError> {
        Future<Bool, TraceError> { [weak self] promise in
            guard let self = self else { return }

            message.addHeader(key: "secKey", value: self.connectionInfo.secKey)
            let byteBody = autoreleasepool { message.body.getMessageBuffer() }
            message.bodyCount = byteBody.count

            if message.header["fileLength"] == "" {
                message.addHeader(key: "fileLength", value: "\(byteBody.count)")
            }

            let header = message.header.toJson() ?? ""
            print("[D2DService] send image header : \(header)")
            print("[D2DService] start send image \(String(describing: message.header["fileName"]))")

            self.messenger.send(message: SocketSendMessage(value: Int32(header.count), completion: { status in
                switch status {
                case .success:
                    print("[D2DService] socket headerSize write success \(header.count)")
                case .fail:
                    promise(.failure(TraceError(message: "socket headerSize write fail")))
                    print("[D2DService] socket headerSize write fail \(header.count)")
                }
            }))

            self.messenger.send(message: SocketSendMessage(value: header, completion: { status in
                switch status {
                case .success:
                    print("[D2DService] socket header write success \(header)")
                case .fail:
                    promise(.failure(TraceError(message: "socket header write fail")))
                    print("[D2DService] socket header write fail \(header)")
                }
            }))

            self.messenger.send(message: SocketSendMessage(value: byteBody, completion: { status in
                switch status {
                case .success:
                    print("[D2DService] send image \(String(describing: message.header["fileName"])) succeed")
                    promise(.success(true))
                case .fail:
                    promise(.failure(TraceError(message: "socket body write fail")))
                }
            }))
        }
        .eraseToAnyPublisher()
    }

    public func receive() -> AnyPublisher<D2dMessage, TraceError> {
        Future<D2dMessage, TraceError> { [weak self] promise in
            guard let self = self else { return }

            self.messenger.receive(message: SocketReceiveMessage(readSize: 4, completion: { [weak self] data in
                guard let self = self, let headerSize = data.toIntFromBigEndian(), headerSize > 0 else {
                    promise(.failure(TraceError(message: "invalid header size: \(data)")))
                    return
                }

                self.messenger.receive(message: SocketReceiveMessage(readSize: headerSize, completion: { [weak self] data in
                    guard let self = self else { return }
                    guard let header = data.toString().toDictionary() as? [String: String],
                          let fileLength = Int(header["fileLength"] ?? "0"), fileLength > 0 else {
                        promise(.failure(TraceError(message: "invalid header: \(data.toString())")))
                        return
                    }

                    self.messenger.receive(message: SocketReceiveMessage(readSize: fileLength, completion: { data in
                        promise(.success(D2dMessage(header: header, body: data)))
                    }))
                }))
            }))
        }
        .eraseToAnyPublisher()
    }

    public func receive(count: Int) -> AnyPublisher<D2dMessage, TraceError> {
        let publishers = (0..<count).map { _ in self.receive() }
        return Publishers.MergeMany(publishers)
            .eraseToAnyPublisher()
    }

    public func receiveImage(count: Int) -> AnyPublisher<UIImage, TraceError> {
        receive(count: count)
            .tryMap { message -> UIImage in
                guard let imageData = message.body as? Data, let image = UIImage(data: imageData) else {
                    throw TraceError(message: "invalid image data")
                }
                return image
            }
            .mapError { $0 as? TraceError ?? TraceError(message: $0.localizedDescription) }
            .eraseToAnyPublisher()
    }

    public func close() {
        messenger.close()
        messenger.invalidateTimer()
    }

    private var cancellables = Set<AnyCancellable>()
}

protocol D2dMessenger {
    func open()
    func send(message: SocketSendMessage)
    func receive(message: SocketReceiveMessage)
    func close()
    func invalidateTimer()
}
