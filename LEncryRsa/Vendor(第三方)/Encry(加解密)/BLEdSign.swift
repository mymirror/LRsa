//
//  BluckEd25519.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/20.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLEdSign: NSObject {
    
    static func getEDKeyPair() -> Ed25519Keypair {
        let keyPair:Ed25519Keypair = BlinkEd25519.generateKeyPair()
        return keyPair
    }
    
    static func sign(_ content:String , _ keyPair : Ed25519Keypair ) -> NSData {
        let signData :NSData = BlinkEd25519.ed25519_Signature(keyPair, content: content) as NSData
        return signData
    }
    
    static func verifySignature(_ sign_base64String:String ,_ publickey : NSData ,_ content_utf8String : String) -> Bool {
        
        let signData:NSData = sign_base64String.dataFrom_base64String()
        let contentData:NSData = content_utf8String.dataFrom_utf8String()
        let ret :Bool = BlinkEd25519.ed25519_Verify(signData as Data, content: contentData as Data, ed25519Publickey: publickey as Data)
        return ret
    }
    
    
}
