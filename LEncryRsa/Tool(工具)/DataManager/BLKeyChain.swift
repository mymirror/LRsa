//
//  BLKeyChain.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/28.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLKeyChain: NSObject {
    static func getKeychainQuery(service: String) -> NSMutableDictionary {
        return NSMutableDictionary.init(objects: [kSecClassGenericPassword, service, service, kSecAttrAccessibleAfterFirstUnlock], forKeys: [kSecClass as! NSCopying, kSecAttrService as! NSCopying, kSecAttrAccount as! NSCopying, kSecAttrAccessible as! NSCopying])
    }
    // sava data to key chain
    static func save(key:String,data:Any){
        // Get search dictionary
        let keychainQuery = self.getKeychainQuery(service: key)
        // Delete old item before add new item
        SecItemDelete(keychainQuery)
        // Add new object to search dictionary(Attention:the data format)
        keychainQuery.setObject(NSKeyedArchiver.archivedData(withRootObject: data), forKey: kSecValueData as! NSCopying)
        // Add item to keychain with the search dictionary
        SecItemAdd(keychainQuery, nil)
    }
    
    // load data from key chain
    static func load(service: String) -> String {
        var ret: String = ""
        let keychainQuery = self.getKeychainQuery(service: service)
        // Configure the search setting
        // Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
        keychainQuery.setObject(kCFBooleanTrue as Any, forKey: kSecReturnData as! NSCopying)
        keychainQuery.setObject(kSecMatchLimitOne, forKey: kSecMatchLimit as! NSCopying)
        var keyData: CFTypeRef?
        if SecItemCopyMatching(keychainQuery, &keyData) == noErr {
            ret = NSKeyedUnarchiver.unarchiveObject(with: keyData as! Data) as! String
        }
        return ret
    }
    
    // delete data from key chain
    static func deleteKeyData(service: String) {
        let keychainQuery = self.getKeychainQuery(service: service)
        SecItemDelete(keychainQuery)
    }
    
    // cation self app bundle id key chain
    static func saveAndLoadKeyChain()->String{
        var valueString = load(service: "com.BloodLink..BloodLink")
        if valueString.isEmpty {
            let uuidStr = NSUUID().uuidString
            save(key: "com.BloodLink..BloodLink", data:uuidStr)
        }
        valueString = load(service: "com.BloodLink..BloodLink")
        return valueString
    }
}
