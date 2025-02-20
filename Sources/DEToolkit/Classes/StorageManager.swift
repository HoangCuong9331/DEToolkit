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
    func saveObject(_ object: Codable, forKey key: String) -> Bool
    
    /// Retrieves a Codable object from storage.
    ///
    /// - Parameter key: The unique key associated with the stored object.
    /// - Returns: The retrieved object of type `T`, or `nil` if the object does not exist or decoding fails.
    func retrieveObject<T: Codable>(forKey key: String) -> T?
    
    /// Deletes an object from storage.
    ///
    /// - Parameter key: The unique key associated with the object to be deleted.
    /// - Returns: `true` if the object was successfully deleted, `false` otherwise.
    func deleteObject(forKey key: String) -> Bool
}

public final class KeychainManager: StorageManager {
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

public final class UserDefaultManager: StorageManager {
    public init() { }
    
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
    
    @discardableResult
    public func deleteObject(forKey key: String) -> Bool {
        UserDefaults.standard.removeObject(forKey: key)
        return UserDefaults.standard.synchronize()
    }
}
