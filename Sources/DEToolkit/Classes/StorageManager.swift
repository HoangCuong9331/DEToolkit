//
//  Storage.swift
//  DEToolkit
//
//  Created by Le Cuong on 20/2/25.
//

import Foundation
import Security

public protocol StorageManager {
    
    /// Saves a Codable object to storage.
    ///
    /// - Parameters:
    ///   - object: The Codable object to be saved.
    ///   - key: A unique key for storing the object.
    /// - Returns: `true` if the object was successfully saved, `false` otherwise.
    @discardableResult
    func saveObject(_ object: Codable, forKey key: String) async throws -> Bool
    
    /// Retrieves a Codable object from storage.
    ///
    /// - Parameter key: The unique key associated with the stored object.
    /// - Returns: The retrieved object of type `T`, or `nil` if the object does not exist or decoding fails.
    func retrieveObject<T: Codable>(forKey key: String) async throws -> T?
    
    /// Deletes an object from storage.
    ///
    /// - Parameter key: The unique key associated with the object to be deleted.
    /// - Returns: `true` if the object was successfully deleted, `false` otherwise.
    @discardableResult
    func deleteObject(forKey key: String) async throws -> Bool
}

public protocol CollectiveStorageManager: StorageManager {
    
    /// Retrieves an array of Codable objects from storage
    ///
    /// - Parameter prefix: A unique prefix for all key associated with the object
    /// - Returns: An array of Codable objects from storage
    func retrieveObjects<T: Codable>(withKeyPrefix prefix: String) async -> [T]
}

actor FileStorageManager: StorageManager {
    private let cacheDirectoryURL: URL

    public init(cacheDirectoryURL: URL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]) {
        self.cacheDirectoryURL = cacheDirectoryURL
    }
    
    @discardableResult
    func saveObject(_ object: Codable, forKey key: String) async throws -> Bool {
        let encoder = JSONEncoder()
        let encodedData = try encoder.encode(object)
        let url = cacheDirectoryURL.appendingPathComponent("\(key).diy")
        try encodedData.write(to: url)
        return true
    }
    
    func retrieveObject<T: Codable>(forKey key: String) async throws -> T? {
        let decoder = JSONDecoder()
        let url = cacheDirectoryURL.appendingPathComponent("\(key).diy")
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try decoder.decode(T.self, from: data)
    }
    
    @discardableResult
    func deleteObject(forKey key: String) async throws -> Bool {
        let url = cacheDirectoryURL.appendingPathComponent("\(key).diy")
        try FileManager.default.removeItem(at: url)
        return true
    }
}


// TODO: check race conditions and fix with global actor
public actor KeychainManager: StorageManager {
    public init() { }
    
    @discardableResult
    public func saveObject(_ object: Codable, forKey key: String) -> Bool {
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(object) else {
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "",
            kSecAttrAccount as String: key,
            kSecValueData as String: encodedData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        SecItemDelete(query as CFDictionary)
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    public func retrieveObject<T: Codable>(forKey key: String) -> T? {
        guard let kTrue = kCFBooleanTrue else { return nil }
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "",
            kSecAttrAccount as String: key,
            kSecReturnData as String: kTrue,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        if status == errSecSuccess, let data = result as? Data {
            let decoder = JSONDecoder()
            return try? decoder.decode(T.self, from: data)
        }
        
        return nil
    }
    
    @discardableResult
    public func deleteObject(forKey key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "",
            kSecAttrAccount as String: key
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess
    }
}

// TODO: check race conditions and fix with global actor
public actor UserDefaultManager: CollectiveStorageManager {
    let userDefaults: UserDefaults
    
    public init(suiteName: String? = nil) {
        if let suiteName = suiteName {
            if suiteName.starts(with: "group.") {
                userDefaults = UserDefaults.standard
            } else {
                userDefaults = UserDefaults(suiteName: suiteName)!
            }
        } else {
            userDefaults = UserDefaults.standard
        }
    }
    
    @discardableResult
    public func saveObject(_ object: Codable, forKey key: String) -> Bool {
        let encoder = JSONEncoder()
        guard let encodedData = try? encoder.encode(object) else {
            return false
        }
        
        UserDefaults.standard.set(encodedData, forKey: key)
        return UserDefaults.standard.synchronize()
    }
    
    public func retrieveObject<T: Codable>(forKey key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }
        
        let decoder = JSONDecoder()
        return try? decoder.decode(T.self, from: data)
    }
    
    public func retrieveObjects<T: Codable>(withKeyPrefix prefix: String) -> [T] {
        let defaults = UserDefaults.standard
        let allKeys = defaults.dictionaryRepresentation().keys

        var filteredValues: [T] = []

        for key in allKeys where key.hasPrefix(prefix) {
            if let data = defaults.data(forKey: key) {
                let decoder = JSONDecoder()
                guard let tValue: T = try? decoder.decode(T.self, from: data)
                else { continue }
                filteredValues.append(tValue)
            }
        }

        return filteredValues
    }
    
    @discardableResult
    public func deleteObject(forKey key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return UserDefaults.standard.synchronize()
    }
}
