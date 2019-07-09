//
//  BLRouter.swift
//  BloodLuck
//
//  Created by ponted on 2019/7/2.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

/*
* useage 
first   need use regisetrRouter  init 
second  use openRouter to jump to need viewcontroller
*/

class BLRouter: NSObject {
    
    
    /// register router
    ///
    /// - Parameters:
    ///   - url:                        router url
    ///   - module:                     router class
    static func registerRouter(url:String,module:AnyClass){
        BLRouterHandle.registerUrlRouter(url: url, module: module)
    }
    
    
    /// oprn router
    ///
    /// - Parameters:
    ///   - url:                         router url
    ///   - modal:                       router form when modal is true is present or is push or present
    ///   - params:                      router need parameters
    static func openRouter(url: String, modal: Bool, params: Dictionary<String, AnyObject>?) {
        let urlTmp = URL.init(string: url)
        if urlTmp == nil {
            assert(true, "url参数包含中文必须encode编码")
        }
        let key =  (urlTmp?.path)!
        
        if (BLRouterHandle.canOpen(url: url)) {
            
            let paramsWithUrlQuery = BLRouterUtil.mergeDictionary(dic0: BLRouterUtil.getQueryDictionary(url: url), dic1: params)
            
            let moduleType = BLRouterMatch.fetchModuleClass(key: key) as! BLRouterDelegate.Type
            let module = moduleType.init(params: paramsWithUrlQuery as Dictionary<String, AnyObject>?) as AnyObject
            
            if module.isKind(of: UIViewController.self) {
                let viewController = module as! UIViewController
                if viewController.isKind(of: UIViewController.self) {
                    let topViewController = BLRouterUtil.currentTopViewController()
                    if (topViewController.navigationController != nil) && !modal {
                        let navigation = topViewController.navigationController
                        navigation?.pushViewController(viewController, animated: true)
                    }
                    else {
                        topViewController.present(viewController, animated: true, completion: nil)
                    }
                }
            }
        }
        else {
            debugPrint("error")
        }
    }
}
