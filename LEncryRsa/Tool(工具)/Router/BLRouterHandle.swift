//
//  BLRouterHandle.swift
//  BloodLuck
//
//  Created by ponted on 2019/7/3.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLRouterHandle: NSObject {

    // init all url router
    static func initUrlRouter(dic:[String:AnyClass]){
        BLRouterMatch.shareInstance.instance.urlDic = dic
    }
    
    // init one url router
    static func registerUrlRouter(url:String,module:AnyClass){
        let urlTmp = URL.init(string: url)
        let key = (urlTmp?.path)!
        BLRouterMatch.shareInstance.instance.urlDic.updateValue(module as AnyClass, forKey: key)
    }
    
    // remove one url router
    static func removeUrlRouter(url:String){
        let urlTmp = URL.init(string: url)
        let key = (urlTmp?.path)!
        BLRouterMatch.shareInstance.instance.urlDic.removeValue(forKey: key)
    }
    
    // remove all url router
    static func removeAllRouter(){
        BLRouterMatch.shareInstance.instance.urlDic.removeAll()
    }
    
    // judge the url can open
    static func canOpen(url:String)->Bool{
       let urlTmp = URL.init(string: url)
       let key = (urlTmp?.path)!
       return  ((BLRouterMatch.fetchModuleClass(key: key) as? BLRouterDelegate != nil) && (BLRouterMatch.shareInstance.instance.urlDic[key] != nil))
    }
    
}
