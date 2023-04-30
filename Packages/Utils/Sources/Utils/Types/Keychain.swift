import Foundation

/// Simple wrapper around the system Keychain.
///
/// Based on Apple's "GenericKeychain" sample code.
/// Example of a possible implementation:
///
///     final class MyKeychain: Keychain<MyKeychain.Key> {
///         enum Key: String {
///             case deviceID
///             case apiKey
///         }
///     }
///
///     let keychain = MyKeychain("MyApp")
///
///     try keychain.set("123", for: .deviceID)
///     try keychain.set("abc", for: .apiKey)
///
///     let deviceID = try keychain.get(.deviceID)
///     let apiKey = try keychain.get(.apiKey)
///
open class Keychain<Key: RawRepresentable>: GenericKeychain where Key.RawValue == String {
    public let service: String
    public let group: String?
    public let accessibility: String?

    public init(
        _ service: String,
        group: String? = nil,
        accessibility: String? = nil
    ) {
        self.service = service
        self.group = group
        self.accessibility = accessibility
    }
}

public protocol GenericKeychain {
    associatedtype Key: RawRepresentable

    var service: String { get }
    var group: String? { get }
    var accessibility: String? { get }

    func get(_ key: Key) throws -> String
    func set(_ value: String?, for key: Key) throws
    func remove(_ key: Key) throws
}

public extension GenericKeychain where Key.RawValue == String {
    func get(_ key: Key) throws -> String {
        try keychainItem(key.rawValue).readPassword()
    }

    func set(_ value: String?, for key: Key) throws {
        if let value = value {
            try keychainItem(key.rawValue).savePassword(value)
        } else {
            try remove(key)
        }
    }

    func remove(_ key: Key) throws {
        try keychainItem(key.rawValue).deleteItem()
    }

    private func keychainItem(_ key: String) -> KeychainPasswordItem {
        KeychainPasswordItem(
            service: service,
            account: key,
            accessGroup: group,
            accessibility: accessibility
        )
    }
}

/// - See: https://developer.apple.com/library/ios/samplecode/GenericKeychain

/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information

 Abstract:
 A struct for accessing generic password keychain items.
 */

/// - Note: add `accessibility` for `kSecAttrAccessible` attribute (2021)

public struct KeychainPasswordItem {

    // MARK: Types

    public enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    // MARK: Properties

    public let service: String

    public private(set) var account: String

    public let accessGroup: String?

    public var accessibility: String?

    // MARK: Intialization

    public init(
        service: String,
        account: String,
        accessGroup: String? = nil,
        accessibility: String? = nil
    ) {
        self.service = service
        self.account = account
        self.accessGroup = accessGroup
        self.accessibility = accessibility
    }

    // MARK: Keychain access

    public func readPassword() throws -> String {
        // Build a query to find the item that matches the service, account and access group.
        var query = KeychainPasswordItem.keychainQuery(
            withService: service,
            account: account,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate.
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Parse the password string from the query result.
        guard let existingItem = queryResult as? [String: AnyObject],
              let passwordData = existingItem[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else {
            throw KeychainError.unexpectedPasswordData
        }

        return password
    }

    public func savePassword(_ password: String) throws {
        // Encode the password into an Data object.
        guard let encodedPassword = password.data(using: String.Encoding.utf8) else {
            throw KeychainError.unhandledError(status: -1)
        }

        do {
            // Check for an existing item in the keychain.
            try _ = readPassword()

            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainPasswordItem.keychainQuery(
                withService: service,
                account: account,
                accessGroup: accessGroup,
                accessibility: accessibility
            )
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noPassword {
            /*
                 No password was found in the keychain. Create a dictionary to save
                 as a new keychain item.
             */
            var newItem = KeychainPasswordItem.keychainQuery(
                withService: service,
                account: account,
                accessGroup: accessGroup,
                accessibility: accessibility
            )
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }

    public mutating func renameAccount(_ newAccountName: String) throws {
        // Try to update an existing item with the new account name.
        var attributesToUpdate = [String: AnyObject]()
        attributesToUpdate[kSecAttrAccount as String] = newAccountName as AnyObject?

        let query = KeychainPasswordItem.keychainQuery(
            withService: service,
            account: account,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
        let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }

        account = newAccountName
    }

    public func deleteItem() throws {
        // Delete the existing item from the keychain.
        let query = KeychainPasswordItem.keychainQuery(
            withService: service,
            account: account,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else {
            throw KeychainError.unhandledError(status: status)
        }
    }

    public static func passwordItems(
        forService service: String,
        accessGroup: String? = nil,
        accessibility: String? = nil
    ) throws -> [KeychainPasswordItem] {
        // Build a query for all items that match the service and access group.
        var query = KeychainPasswordItem.keychainQuery(
            withService: service,
            accessGroup: accessGroup,
            accessibility: accessibility
        )
        query[kSecMatchLimit as String] = kSecMatchLimitAll
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanFalse

        // Fetch matching items from the keychain.
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // If no items were found, return an empty array.
        guard status != errSecItemNotFound else { return [] }

        // Throw an error if an unexpected status was returned.
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }

        // Cast the query result to an array of dictionaries.
        guard let resultData = queryResult as? [[String: AnyObject]] else {
            throw KeychainError.unexpectedItemData
        }

        // Create a `KeychainPasswordItem` for each dictionary in the query result.
        var passwordItems = [KeychainPasswordItem]()
        for result in resultData {
            guard let account = result[kSecAttrAccount as String] as? String else {
                throw KeychainError.unexpectedItemData
            }
            let passwordItem = KeychainPasswordItem(
                service: service,
                account: account,
                accessGroup: accessGroup,
                accessibility: accessibility
            )
            passwordItems.append(passwordItem)
        }

        return passwordItems
    }

    // MARK: Convenience

    private static func keychainQuery(
        withService service: String,
        account: String? = nil,
        accessGroup: String? = nil,
        accessibility: String? = nil
    ) -> [String: AnyObject] {
        var query = [String: AnyObject]()
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        if let accessibility = accessibility {
            query[kSecAttrAccessible as String] = accessibility as AnyObject?
        }

        return query
    }

}
