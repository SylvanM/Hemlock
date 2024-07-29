//
//  SavedUserData.swift
//  Hemlock
//
//  Created by Sylvan Martin on 7/26/24.
//

import Foundation



struct SavedUserData {
    
    enum UserItemKey: String {
        case userID = "User ID"
        case encryptedMasterKey = "Encrypted Master Key"
        case masterKeyHash = "Master Key Hash"
    }
    
    static let userInfoPlistURL = Bundle.main.url(forResource: "UserCreds", withExtension: "plist")!
    
    static func savedDataExists() -> Bool {
        
        let userItems = NSDictionary(contentsOf: userInfoPlistURL) as! Dictionary<String, Any>
        
        guard
            let encryptedMasterKey = userItems[UserItemKey.encryptedMasterKey.rawValue] as? Data,
            let masterKeyHash = userItems[UserItemKey.masterKeyHash.rawValue] as? Data,
            let _ = userItems[UserItemKey.userID.rawValue] as? UInt64
        else {
            return false
        }
        
        return [UInt8](encryptedMasterKey).count != 0 || [UInt8](masterKeyHash).count == 64
    }
    
    static func saveUserData(userID: UInt64, loginPassword: String, plaintextMasterKey: [UInt8]) {
        let passwordHash = HLCore.Crypto.hash(loginPassword)
        // use the password hash as a key!
        
        var encryptionKey = [UInt8](repeating: 0, count: 32) // a 32-byte Speck key
        for i in 0..<encryptionKey.count {
            encryptionKey[i] = passwordHash[i] ^ passwordHash[i + 32]
        }
        
        let encryptedMasterKey = HLCore.Crypto.enc(plaintextMasterKey, key: encryptionKey)
        let masterKeyHash = HLCore.Crypto.hash(plaintextMasterKey)
        
        let userItems = [
            UserItemKey.encryptedMasterKey.rawValue : Data(encryptedMasterKey),
            UserItemKey.masterKeyHash.rawValue : Data(masterKeyHash),
            UserItemKey.userID.rawValue : userID
        ] as [String : Any]
        
        do {
            let plistData = try PropertyListSerialization.data(fromPropertyList: userItems, format: .xml, options: 0)
            try plistData.write(to: userInfoPlistURL)
        } catch {
            fatalError("Hey! Why can't we write to these files?")
        }
        
    }
    
    /// Ensures that an email and password are legitimate
    static func validateLogin(email: String, loginPassword: String) -> Bool {
        // TODO: Actually couple this with a web call that checks that the UID matches and all that
        // other jazz.
        
        return true
    }
    
}
