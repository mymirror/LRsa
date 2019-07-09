//
//  BluckString.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/24.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLString: NSObject {
    

    /// generate random String
    ///
    /// - Parameter length: the length of random String
    /// - Returns: random String
    class func randomStringWithLength(length:Int)-> String {
        
        let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        
        for _ in 0..<length {
            let index = Int(arc4random_uniform(UInt32(characters.count)))
            randomString.append(characters[characters.index(characters.startIndex, offsetBy: index)])
        }
        return randomString
    }
    
    
    
    
    
}
