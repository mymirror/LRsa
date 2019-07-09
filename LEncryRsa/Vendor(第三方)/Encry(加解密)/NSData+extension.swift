//
//  BluckEncry.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/24.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit
import CommonCrypto

extension NSData{
    
    func AES256EncryptWithKey(key:NSData)->NSData? {
        
        let randomString = BLString.randomStringWithLength(length: 16)
        let ivData:NSData = randomString.data(using: .utf8)! as NSData
        let datas:NSData = NSData.init()
        let encryData:NSData = self.AES256EncryptWithKeyIv(key: key, iv: ivData) ?? datas
        
        let encryContentData:NSMutableData = NSMutableData.init(data: ivData as Data)
        encryContentData.append(encryData as Data)
        
        return encryContentData
    }
    
    func AES256DecryptWithKey(key:NSData)->NSData? {

        let mutableData:NSData = NSMutableData.init(data: self as Data)
        let ivData :NSData = mutableData.subdata(with: NSMakeRange(0, 16)) as NSData
        let contentData :NSData = mutableData.subdata(with: NSMakeRange(16, mutableData.length-16)) as NSData
        
        let datas:NSData = NSData.init()
        let content :NSData = contentData.AES256DecryptWithKeyIv(key: key, iv: ivData) ?? datas
        
        return content
    }
    

    func AES256EncryptWithKeyIv(key:NSData, iv:NSData)->NSData? {
        return self.AES256operation(operation:CCOperation(kCCEncrypt), key:key, iv:iv)
    }
    
    func AES256DecryptWithKeyIv(key:NSData, iv:NSData)->NSData? {
        return self.AES256operation(operation:CCOperation(kCCDecrypt), key:key, iv:iv)
    }
    
    func AES256operation(operation:CCOperation, key:NSData, iv:NSData)->NSData? {
        
        let algoritm:  CCAlgorithm = CCAlgorithm(kCCAlgorithmAES128)
        let option:   CCOptions    = CCOptions(kCCOptionPKCS7Padding)
        
        let keyBytes        = key.bytes
        let keyLength       = key.length == 16 ? Int(kCCKeySizeAES128) : Int(kCCKeySizeAES256)
        
        let ivBytes         = iv.bytes
        
        let dataBytes       = self.bytes
        let dataLength      = self.length
        
        let cryptLength     = Int(self.length+kCCBlockSizeAES128)
        let cryptPointer    = UnsafeMutablePointer<UInt8>.allocate(capacity: cryptLength)
        
        let numBytesEncrypted = UnsafeMutablePointer<Int>.allocate(capacity: 1)
        numBytesEncrypted.initialize(to: 0)
        
        let cryptStatus = CCCrypt(operation, algoritm, option,
                                  keyBytes, keyLength,
                                  ivBytes,
                                  dataBytes,dataLength,
                                  cryptPointer, cryptLength,
                                  numBytesEncrypted)
        
        if CCStatus(cryptStatus) == CCStatus(kCCSuccess) {
            let len = Int(numBytesEncrypted.pointee)
            let data:NSData = NSData(bytesNoCopy: cryptPointer, length: len)

            return data
        } else {
            
            print("aes_ERROR")
            return nil
        }
    }
    
    
    func base64EncodeToString() -> String {
        
        let content:String = self.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: UInt(uint(0))))
        return content
    }
    
    func utf8EncodeToString() -> String {
        
        let content:String = String(data: self as Data, encoding: String.Encoding.utf8) ?? ""
        return content
    }
    
 
}

extension String{
    
    func dataFrom_utf8String() -> NSData {
        
        let data:NSData = self.data(using: String.Encoding.utf8)! as NSData
        return data
    }
    
    func dataFrom_base64String() -> NSData {
        
        let data:NSData = NSData.init(base64Encoded: self, options: NSData.Base64DecodingOptions(rawValue: UInt(uint(0))))!
        return data
    }
    
}



