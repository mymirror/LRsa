//
//  BLRedis.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/26.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLRedis: NSObject {
    
    /// store info with nsuserdefaults
    ///
    /// - Parameters:
    ///   - value:                      store value
    ///   - key:                        store key
    static func storeUserPrivateInfo(dic:[String:Any]){
        let userDefault = UserDefaults.standard
        if dic.count != 0 {
            let keyArr = dic.keys
            for keyStr in keyArr{
                let valueAny:Any? = dic[keyStr]
                userDefault.setValue(valueAny, forKey: keyStr)
            }
            userDefault.synchronize()
        }
        
    }
    
    
    /// get info with nsuserdefaults
    ///
    /// - Parameter key:                get value with key
    /// - Returns:                      get key's value
    static func readUserprivateInfo(key:String)->Any{
        let userDefault = UserDefaults.standard
        let result = userDefault.value(forKey: key)
        return result as Any 
    }
    
}
