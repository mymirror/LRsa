//
//  BLMd5Tool.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/21.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit
import CommonCrypto

class BLMd5Tool: NSObject {
    
    
    /// string md5
    ///
    /// - Parameter str:        need md5 data
    /// - Returns:              md5's data
    func md5(str:String) -> String {
        let cStr = str.cString(using: String.Encoding.utf8)
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: 16)
        CC_MD5(cStr!,(CC_LONG)(strlen(cStr!)), buffer)
        let md5String = NSMutableString();
        for i in 0 ..< 16{
            md5String.appendFormat("%02x", buffer[i])
        }
        free(buffer)
        return md5String as String
    }
    
    
    /// sha1 sign
    ///
    /// - Parameter str:          need sha1 string 
    /// - Returns:                sign result data
    func sha1(str:String) -> String {
        let cStr = str.cString(using: String.Encoding.utf8)
        let digest = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        CC_SHA1(cStr!,(CC_LONG)(strlen(cStr!)), digest)
         
        let output = NSMutableString(capacity: Int(CC_SHA1_DIGEST_LENGTH))
        for i in 0 ..< Int(CC_SHA1_DIGEST_LENGTH){
            output.appendFormat("%02x", digest[i])
        }
        free(digest)
        return output as String
    }
    
}
