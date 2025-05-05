//
//  SecuredSocketMessenger.swift
//  DEToolkit
//
//  Created by Le Cuong on 25/4/25.
//

import Foundation

@available(iOS 13.0, *)
public class SecuredSocketMessenger: SocketMessenger {
    private var secCertificate: SecCertificate? {
        guard let certificateUrl = Bundle(for: Self.self).url(forResource: "cert_file", withExtension: "crt") else {
            print("Failed to load file")
            return nil
        }

        guard let certificateData = try? Data(contentsOf: certificateUrl) as CFData else {
            print("Certificate data is nil")
            return nil
        }

        guard let certificate = SecCertificateCreateWithData(nil, certificateData) else {
            print("Failed to create secCertificate")
            return nil
        }

        return certificate
    }

    override func open() {
        print("socket open. \(String(describing: address)):\(String(describing: port))")

        Stream.getStreamsToHost(withName: address, port: port, inputStream: &inputStream, outputStream: &outputStream)

        guard let inputStream = inputStream,
              let outputStream = outputStream else {
            print("Need to check input & output streams")
            return
        }

        inputStream.delegate = self
        outputStream.delegate = self

        inputStream.schedule(in: .main, forMode: .default)
        outputStream.schedule(in: .main, forMode: .default)

        let certs: NSArray = NSArray(objects: secCertificate)
        let sslSettings: [NSObject: NSObject] = [
            kCFStreamSSLLevel: kCFStreamSocketSecurityLevelNegotiatedSSL,
            kCFStreamSSLValidatesCertificateChain: kCFBooleanFalse,
            kCFStreamSSLPeerName: kCFNull,
            kCFStreamSSLIsServer: kCFBooleanFalse
        ]

        var result = inputStream.setProperty(sslSettings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
        print("set SSLSetting of inputStream : \(result)")
        result = outputStream.setProperty(sslSettings, forKey: kCFStreamPropertySSLSettings as Stream.PropertyKey)
        print("set SSLSetting of outputStream : \(result)")

        inputStream.open()
        outputStream.open()

        setTimerToOpenStream()

        dispatchQueue = DispatchQueue(label: "SocketMessenger", qos: .userInitiated)
    }
}
