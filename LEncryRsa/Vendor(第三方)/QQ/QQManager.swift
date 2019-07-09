//
//  QQManager.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/21.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

typealias QQUserActionBlock = (_ status:Bool,_ errCode:Int,_ dic:[String:AnyObject])->Void

enum QQShareType:Int {
    case QQText = 0 // share text type
    case QQLink = 1 // share link type
}

class QQManager: NSObject,TencentSessionDelegate {
    var qqUserBlock : QQUserActionBlock!
    // create singleton
    class shareInstance{
        static let instance = QQManager()
        private init() {}
    }
    
    // custom  TencentOAuth instance
    var authQQ : TencentOAuth!
    
    /// instance register qq 
    ///
    /// - Parameter appId:                  apply qq id
    /// - Returns:                          TencentOAuth instance 
    func registerQQ(appId:String){
        authQQ = TencentOAuth(appId: appId, andDelegate: self)
        print(authQQ as Any)
    }
    
    /// QQ user auth
    ///
    /// - Parameter block:                   auth result block
    func QQAuth(block:@escaping QQUserActionBlock) -> Void {
        qqUserBlock = block
        let permissions = [kOPEN_PERMISSION_GET_USER_INFO,kOPEN_PERMISSION_GET_SIMPLE_USER_INFO,kOPEN_PERMISSION_ADD_SHARE,kOPEN_PERMISSION_GET_INFO,kOPEN_PERMISSION_GET_OTHER_INFO]
        authQQ.authShareType = AuthShareType_QQ
        authQQ.authorize(permissions)
    }
    
    /// QQ user info
    ///
    /// - Parameter block:                   get user info  block
    func getQQuserInfo(block:@escaping QQUserActionBlock) -> Void {
        qqUserBlock = block
        authQQ.getUserInfo()
    }
    
    // get user info delegate or  block
    func getUserInfoResponse(_ response: APIResponse!) {
        let detailRetCode = response.detailRetCode
        guard detailRetCode == kOpenSDKErrorSuccess.rawValue else {
            qqUserBlock?(true,0,response.jsonResponse as! [String:AnyObject])
            return
        }
        qqUserBlock?(false,0,["cancel":"获取个人信息失败" as AnyObject])
    }
    
    
    /// this function in order to interWorking ios and android
    ///
    /// - Returns:                          dic container ios and andriod need  unionid param
    func getQQInterWorkingData() -> NSDictionary {
        let authToken = authQQ.accessToken ?? ""
        let urlStr = "https://graph.qq.com/oauth2.0/me?access_token="+authToken+"&unionid=1"
        let url = NSURL(string: urlStr)
        
        let zoneStr : String? = (try? NSString.init(contentsOf: url! as URL, encoding: String.Encoding.utf8.rawValue)) as String?
        let swiftjson = BLSwiftJson()
        let userTokenDic:NSDictionary? = swiftjson.JsonToObject(jsonStr: zoneStr!) as? NSDictionary
        
        var unionid : String
        if userTokenDic != nil {
            unionid = userTokenDic?["unionid"] as! String
        }else{
            unionid = ""
        }
        
        var resultDic : [String:AnyObject]? = [String:AnyObject]()
        resultDic?["access_token"] = authToken as AnyObject
        resultDic?["openId"] = authQQ.openId as AnyObject
        
        resultDic?["unionid"] = unionid as AnyObject
        
        return resultDic! as NSDictionary
    }
    
    // TencentSessionDelegate three methods
    /*
     *  user login success
     *  user login fail follwing user himself cancel or fail
     *  network is bad or no network
     */
    func tencentDidLogin() {
        qqUserBlock?(true,0,[:])
    }
    
    func tencentDidNotLogin(_ cancelled: Bool) {
        guard cancelled else {
            qqUserBlock?(false,1,["cancel":"用户取消登录" as AnyObject])
            return
        }
        qqUserBlock?(false,0,["cancel":"登录失败" as AnyObject])
    }
    
    func tencentDidNotNetWork() {
        
    }
    
    
    /// QQ users share into Conversation and qq zone
    ///
    /// - Parameters:
    ///   - param:                      dic detail following QQShareObjectModel
    ///   - scene:                      share Scene detail following QQShareScene
    ///   - type:                       share type detail following QQShareType
    func QQShare(param:NSDictionary,scene:QQShareScene,type:QQShareType)->Void{
        var model : QQShareObjectModel? = QQShareObjectModel.init(dic: param)
        if model?.sharePreviewObject == nil{
            model?.sharePreviewObject = "" as AnyObject
        }

        switch type.rawValue {
        case 0:
            QQShareHandler.QQSendText(text: model?.shareText ?? "", scene: scene)
            break
        case 1:
            QQShareHandler.QQSendLinkUrl(title: model?.shareTitle ?? "", linkUrl: model?.shareLinkUrl ?? "", previewObject: (model?.sharePreviewObject)!, description: model?.shareDecription ?? "", scene: scene)
            break
        default:
            break
        }
    }
    
    
}
