//
//  BluckEncry.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/25.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLEncry: NSObject {

    /// AES Encry
    ///
    /// - Parameters:
    ///   - content_base64: need Encry content
    ///   - key_base64: Encry key
    /// - Returns: Encrypted content
    static func BluckEncry(content_utf8:String,key_base64:String)->String{
        
        let contentData:NSData = content_utf8.dataFrom_utf8String()
        let keyData:NSData = key_base64.dataFrom_base64String()
        
        let encryData = contentData.AES256EncryptWithKey(key: keyData)
        let encryString:String = encryData?.base64EncodeToString() ?? ""
        
        return encryString
    }
    
    
    /// AES Decry
    ///
    /// - Parameters:
    ///   - content_base64: need Decry content
    ///   - key_base64: Decry key
    /// - Returns: Decrypted content
    static func BluckDecry(content_base64:String,key_base64:String)->String{
        
        let encryData:NSData = content_base64.dataFrom_base64String()
        let keyData:NSData = key_base64.dataFrom_base64String()
        
        let contentData = encryData.AES256DecryptWithKey(key: keyData)
        let content:String = contentData?.utf8EncodeToString() ?? ""
        
        return content
    }
    
    
    static func BluckEncryData(contentData:NSData,keyData:NSData)->NSData{
    
        let encryData:NSData = contentData.AES256EncryptWithKey(key: keyData)!
        return encryData
    
    }
    
    static func BluckDecryData(contentData:NSData?,keyData:NSData)->NSData{
        
        let decryData:NSData? = contentData?.AES256DecryptWithKey(key: keyData)
        return decryData!
        
    }
    
    
    
    
}
