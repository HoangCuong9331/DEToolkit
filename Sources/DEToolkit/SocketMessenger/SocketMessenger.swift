//
//  SocketMessenger.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public class SocketMessenger: NSObject, D2dMessenger {
    weak var delegate: SocketMessengerDelegate?
    let address: String!
    let port: Int!
    var inputStream: InputStream?
    var outputStream: OutputStream?
    var sendMessageQueue = SocketMessageQueue<SocketSendMessage>()
    var receiveMessageQueue = SocketMessageQueue<SocketReceiveMessage>()
    var dispatchQueue: DispatchQueue?
    var timer = Set<AnyCancellable>()
    
    /// Use to tracking event, not regard to logic
    private var streamEventTracking: Stream.Event?
    
    /// Use to tracking stream, not regard to logic
    private var statusInputStreamTracking: Stream.Status = .notOpen {
        didSet {
            if statusInputStreamTracking != oldValue {
                print("_Stream Input changed value: \(statusInputStreamTracking.rawValue), event: \(String(describing: self.streamEventTracking?.rawValue))")
            }
        }
    }
    
    /// Use to tracking stream, not regard to logic
    private var statusOutputStreamTracking: Stream.Status = .notOpen {
        didSet {
            if statusOutputStreamTracking != oldValue {
                print("_Stream Output changed value: \(statusOutputStreamTracking.rawValue), event: \(String(describing: self.streamEventTracking?.rawValue))")
            }
        }
    }
    
    init(address: String, port: Int, delegate: SocketMessengerDelegate? = nil) {
        self.address = address
        self.port = port
        self.delegate = delegate
    }
    
    func open() {
        print("Socket open. \(String(describing: address)):\(String(describing: port))")
        Stream.getStreamsToHost(withName: address, port: port, inputStream: &inputStream, outputStream: &outputStream)
        
        inputStream?.schedule(in: .main, forMode: .default)
        outputStream?.schedule(in: .main, forMode: .default)
        
        inputStream?.delegate = self
        outputStream?.delegate = self
        
        inputStream?.open()
        outputStream?.open()

        setTimerToOpenStream()

        dispatchQueue = DispatchQueue(label: "SocketMessenger", qos: .userInitiated)
    }
    
    func send(message: SocketSendMessage) {
        print("Socket enqueue message (socket status: \(String(describing: self.outputStream?.streamStatus.rawValue)))")
        dispatchQueue?.async { [weak self] in
            self?.sendMessageQueue.push(message)
        }
        write()
    }
    
    func receive(message: SocketReceiveMessage) {
        receiveMessageQueue.push(message)
        read()
    }
    
    func read() {
        guard inputStream?.streamStatus == .open, inputStream?.hasBytesAvailable == true, let message = self.receiveMessageQueue.pop() else { return }
        
        dispatchQueue?.async { [weak self] in
            guard let self = self, let inputStream = self.inputStream, inputStream.streamStatus == .open else { return }
            message.completion(inputStream.read(size: message.readSize))
            self.read()
        }
    }
    
    func write() {
        dispatchQueue?.async(execute: { [weak self] in
            guard let self = self,
                  outputStream?.streamStatus == .open,
                  let message = self.sendMessageQueue.pop(),
                  let outputStream = self.outputStream,
                  outputStream.streamStatus == .open else { return }
            
            let isSuccessful = outputStream.write(message: message)
            message.completion?(isSuccessful ? .success : .fail)
            if let valueString = message.value as? String {
                print("SocketMessenger socket write header success: \(isSuccessful), detail: \(String(describing: valueString))")
            } else if let valueString = message.value as? Int32 {
                print("SocketMessenger socket write headerSize success: \(isSuccessful), detail: \(String(describing: valueString))")
            } else {
                print("SocketMessenger socket write success: \(isSuccessful)")
            }
            self.write()
        })
    }
    
    func close() {
        print("Socket close. \(String(describing: address)):\(String(describing: port))")
        inputStream?.close()
        outputStream?.close()
        inputStream?.remove(from: .main, forMode: .default)
        outputStream?.remove(from: .main, forMode: .default)
    }
    
    func disposeMessage() {
        sendMessageQueue.popAll().forEach { $0.completion?(.fail) }
        _ = receiveMessageQueue.popAll()
    }

    func setTimerToOpenStream() {
        let refreshInterval: Double = 1
        let timer = DispatchQueue
            .global(qos: .utility)
            .schedule(after: DispatchQueue.SchedulerTimeType(.now()),
                      interval: .seconds(refreshInterval),
                      tolerance: .seconds(refreshInterval / 5)) { [weak self] in
                guard let self else { return }
                print("SocketMessenger fail to Open Stream")
                self.delegate?.onError()
                self.close()
            }
                      .store(in: &self.timer)
    }
    
    func invalidateTimer() {
        self.timer.map { a in
            a.cancel()
        }
    }

    deinit {
        close()
    }
}

public protocol SocketMessengerDelegate: AnyObject {
    func onError()
    func onOpen()
    func onClose()
}

@available(iOS 13.0, *)
extension SocketMessenger: StreamDelegate {
    public func stream(_ stream: Stream, handle eventCode: Stream.Event) {
        streamEventTracking = eventCode
        if stream === outputStream {
            statusOutputStreamTracking = stream.streamStatus
            switch eventCode {
            case .endEncountered:
                print("outputStream connection end.")
                delegate?.onClose()
                disposeMessage()
            case .errorOccurred:
                print("outputStream connection error.")
            case .openCompleted:
                print("outputStream connection openCompleted.")
            case .hasBytesAvailable:
                print("outputStream connection hasBytesAvailable.")
            case .hasSpaceAvailable:
                print("outputStream connection hasSpaceAvailable.")
                write()
            default:
                break
            }
        } else if stream === inputStream {
            statusInputStreamTracking = stream.streamStatus
            print("Input stream status: \(stream.streamStatus)")
            switch eventCode {
            case .endEncountered:
                print("inputStream connection end.")
            case .errorOccurred:
                print("inputStream connection error.")
            case .openCompleted:
                print("inputStream connection openCompleted.")
                delegate?.onOpen()
                invalidateTimer()
            case .hasBytesAvailable:
                print("inputStream connection hasBytesAvailable.")
                read()
            case .hasSpaceAvailable:
                print("inputStream connection hasSpaceAvailable.")
            default:
                break
            }
        }
    }
}

class SocketMessageQueue<T> {
    private let lock = NSLock()
    private var elements = Array<T>()
    
    func push(_ element: T) {
        lock.lock()
        defer { lock.unlock() }
        elements.append(element)
    }
    
    func pop() -> T? {
        lock.lock()
        defer { lock.unlock() }
        return elements.isEmpty ? nil : elements.removeFirst()
    }
    
    func popAll() -> [T] {
        lock.lock()
        defer { lock.unlock() }
        let result = elements
        elements.removeAll()
        return result
    }
    
    func size() -> Int {
        lock.lock()
        defer { lock.unlock() }
        return elements.count
    }
    
    func isEmpty() -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return elements.isEmpty
    }
}

public struct SocketSendMessage {
    enum Status {
        case success
        case fail
    }
    
    let value: SocketMessageValue
    let completion: ((Status) -> Void)?
    
    init(value: SocketMessageValue, completion: ((Status) -> Void)? = nil) {
        self.value = value
        self.completion = completion
    }
}

public struct SocketReceiveMessage {
    let readSize: Int
    let completion: ((Data) -> Void)
    init(readSize: Int, completion: @escaping ((Data) -> Void)) {
        self.readSize = readSize
        self.completion = completion
    }
}

public protocol SocketMessageValue {
    func getMessageBuffer() -> [UInt8]
}

extension Array: SocketMessageValue where Element == UInt8 {
    public func getMessageBuffer() -> [UInt8] {
        return self
    }
}

extension String: SocketMessageValue {
    public func getMessageBuffer() -> [UInt8] {
        return [UInt8](self.utf8)
    }
}

extension Int32: SocketMessageValue {
    public func getMessageBuffer() -> [UInt8] {
        var value = self
        var result = withUnsafeBytes(of: &value) { Array($0) }
        if CFByteOrderGetCurrent() == CFByteOrderLittleEndian.rawValue {
            result.reverse()
        }
        return result
    }
}

extension Data: SocketMessageValue {
    public func getMessageBuffer() -> [UInt8] {
        let count = self.count
        var bytes = [UInt8](repeating: 0, count: count)
        self.copyBytes(to: &bytes, count: count)
        return bytes
    }

    func toString() -> String {
        return String(data: self, encoding: .utf8) ?? ""
    }

    func toIntFromBigEndian() -> Int? {
        guard !self.isEmpty else {
            return nil
        }
        return Int((self.withUnsafeBytes { $0.load(as: UInt32.self) }).bigEndian)
    }
}

private extension OutputStream {
    func write(message: SocketSendMessage) -> Bool {
        var isSuccessful = false
        let originBuffer = autoreleasepool { message.value.getMessageBuffer() }
        var sendBuffer = [UInt8](repeating: 0, count: 1024 * 16)
        var totalLength = 0
        
        while(true) {
            let sendBufferSize = (originBuffer.count - totalLength) > sendBuffer.count ? sendBuffer.count : (originBuffer.count - totalLength)
            memcpy(&sendBuffer, Array(originBuffer[totalLength...]), sendBufferSize)
            let startTime = Date()
            let length = self.write(sendBuffer, maxLength: sendBufferSize)
            totalLength += length
            let duration = Date().timeIntervalSince(startTime)
            if let valueString = message.value as? String {
                print("SocketMessenger socket writed header detail \(length),  \(totalLength)/\(originBuffer.count) : \(duration)s, detail: \(valueString)")
            } else if let valueInt = message.value as? Int32 {
                print("SocketMessenger socket writed headerSize detail \(length),  \(totalLength)/\(originBuffer.count) : \(duration)s, detail: \(valueInt)")
            } else {
                print("SocketMessenger socket writed \(length),  \(totalLength)/\(originBuffer.count) : \(duration)s")
            }
            if length == -1 || length == 0 || totalLength >= originBuffer.count {
                isSuccessful = length == -1 ? false : true
                break
            }
        }

        return isSuccessful
    }
}

private extension InputStream {
    func read(size: Int) -> Data {
        let bufferSize = size
        var buffer = [UInt8](repeating: 0, count: size)
        var totalLength = 0

        while(true) {
            guard self.streamStatus == .open else { return Data() }
            let readBufferSize = (bufferSize - totalLength) == 0 ? bufferSize : (bufferSize - totalLength)
            let startTime = Date()
            totalLength += self.read(&buffer + totalLength, maxLength: readBufferSize)
            let duration = Date().timeIntervalSince(startTime)
            print("socket read \(totalLength)/\(size) : \(duration)s")
            if totalLength == size {
                break
            }
        }
        return Data(buffer)
    }
}
