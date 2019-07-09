//
//  SinaManager.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/21.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit


typealias WeiBoActionBlock = (_ status:Bool,_ authDic:[String:AnyObject])->Void

class SinaManager: NSObject,WeiboSDKDelegate {
    
    var wbActionBlock:WeiBoActionBlock!
    
    // create singleton
    class shareInstace {
        static let instance = SinaManager()
        private init() {}
    }
        
    /// register weibo
    ///
    /// - Parameter appId:             apply weibo appid
    /// - Returns:                      register result status
    static func registerWeiBo(appId:String){
        WeiboSDK.registerApp(appId)
    }
    
    
    /// user auth weibo
    ///
    /// - Parameter block:              auth result block 
    func WeiBoAuth(block:@escaping WeiBoActionBlock) -> Void {
        
        wbActionBlock = block
        let authReq = WBAuthorizeRequest.init()
        authReq.redirectURI = "http://"
        authReq.scope = "all"
        WeiboSDK.send(authReq)
    }
    
    
    /// get WeiBo user info 
    ///
    /// - Parameters:
    ///   - access_token:                 user's access_token on the weibo plat
    ///   - uid:                          user's uid on the weibo plat
    /// - Returns:                        user's info 
    func GetWeiBoUserInfo(access_token:String,uid:String) -> NSDictionary {
        let urlStr = "https://api.weibo.com/2/users/show.json?access_token="+access_token+"&uid="+uid
        let url = NSURL(string: urlStr)
        let zoneStr : String? = (try? NSString.init(contentsOf: url! as URL, encoding: String.Encoding.utf8.rawValue)) as String?
        
        let swiftjson = BLSwiftJson()
        let userInfo:NSDictionary? = swiftjson.JsonToObject(jsonStr: zoneStr!) as? NSDictionary
        return userInfo!    
    }
    
    
    /// Weiboshare 
    ///
    /// - Parameter param:                 share params
    ///   - block:                         share result block
    func WeiBoShare(param:NSDictionary,block:@escaping WeiBoActionBlock) -> Void {
        guard WeiboSDK.isWeiboAppInstalled() else {
            // tip user not install weibo APP
            return
        }
        wbActionBlock = block
        let model = WeiBoShareModel(dic: param)
        SinaShareHandler.sendWeiBoShare(model: model)
    }
    
    
    //following two method is weibodelegate require method
    func didReceiveWeiboRequest(_ request: WBBaseRequest!) {
        
    }
    // request response 
    func didReceiveWeiboResponse(_ response: WBBaseResponse!) {
        // auth response
        if response.isKind(of: WBAuthorizeResponse.self) {
            let authResponse = response as! WBAuthorizeResponse
            if authResponse.statusCode == WeiboSDKResponseStatusCode.success{
                // auth success
                let access_token : String? = authResponse.userInfo["access_token"] as? String
                let uid : String?  = authResponse.userInfo["uid"] as? String
                var authDic = [String:AnyObject]()
                authDic["uid"] = uid as AnyObject?
                authDic["access_token"] = access_token as AnyObject?
                wbActionBlock?(true,authDic)
            }else if authResponse.statusCode == WeiboSDKResponseStatusCode.userCancel {
                wbActionBlock?(false,["msg":"用户取消授权" as AnyObject])
            }else {
                wbActionBlock?(false,[:])
            }
            return
        }
        // send msg response 
        if response.isKind(of: WBSendMessageToWeiboResponse.self) {
            let msgResponse = response as! WBSendMessageToWeiboResponse
            if msgResponse.statusCode == WeiboSDKResponseStatusCode.success{
                wbActionBlock?(true,[:])
            }else{
                wbActionBlock?(false,[:])
            }
        }
    }
    
    
    
    
}
