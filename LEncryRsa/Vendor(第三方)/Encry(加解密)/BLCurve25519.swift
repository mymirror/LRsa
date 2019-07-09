//
//  BluckCurve25519.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/20.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLCurve25519: NSObject {
    
    /// generate 25519 key pair
    ///
    /// - Returns:                      25519 key pair
    static func getECKeyPair() -> ECKeyPair {
        let keyPair:ECKeyPair = Curve25519.generateKeyPair()
        return keyPair
    }
    
    
    /// generate share key 
    ///
    /// - Parameters:
    ///   - publicKey:                  public key 
    ///   - keyPair:                    25519 key pair
    /// - Returns:                      sharekey 
   static func generateSharedSecret(_ publicKey:NSData , _ keyPair : ECKeyPair ) -> NSData {
        let shareKey:NSData = Curve25519.generateSharedSecret(fromPublicKey: publicKey as Data, andKeyPair: keyPair)! as NSData
        return shareKey
    }
    

}
