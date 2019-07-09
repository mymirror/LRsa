//
//  BLRouterMatch.swift
//  BloodLuck
//
//  Created by ponted on 2019/7/3.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLRouterMatch: NSObject {

    var urlDic:[String:AnyObject] = [:]
    class shareInstance{
        static let instance = BLRouterMatch()
        private init() {}
    }
    
    static func fetchModuleClass(key:String)->AnyObject?{
        return BLRouterMatch.shareInstance.instance.urlDic[key]
    }
}
