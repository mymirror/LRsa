//
//  WXManager.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/21.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

typealias wxActionBlock = (_ result:Bool,_ code:Int,_ accessCode:String)->Void

let kAuthScope = "snsapi_message,snsapi_userinfo,snsapi_friend,snsapi_contact";
let kAuthOpenID = "0c806938e2413ce73eef92cc3";
let kAuthState = "123";

/// user auth action result block
///
/// - wxAuthSuccess:            auth sucess 
/// - wxAuthFail:               auth fail
/// - wxAuthNoInstall:          user can't install weixin 
/// - wxAuthCancel:             user anth canceled
/// - wxAuthDenied:             wx denied user auth
enum wxUserAuthResultEnum : Int {
    case wxAuthSuccess = 0
    case wxAuthFail = 1
    case wxAuthNoInstall = 2
    case wxAuthCancel = 3
    case wxAuthDenied = 4
}


/// wx share type
///
/// - wxShareText:              share text 
/// - wxShareImage:             share image
/// - wxShareLink:              share url link
/// - wxShareMusic:             share music 
/// - wxShareVideo:             share video  
enum wxUserShareInfoType : Int {
    case wxShareText = 0     // share text type
    case wxShareImage = 1    // share image type
    case wxShareLink = 2     // share link type
    case wxShareMusic = 3
    case wxShareVideo = 4
}

class WXManager: NSObject,WXApiDelegate {
    
    // declare user block
    var  wxUserActionBlock:wxActionBlock!
    
    // wxmanager singletion
    class shareInstance {
        static let instance = WXManager()
        private init() {}
    }
    
    /// register wx api_key
    ///
    /// - Parameter             apiKey: applied appid
    /// - Returns:              make sure register result :  bool type
    static func registerWX(apiKey:String){
        // register wx support file type
        let typeFlag:UInt64 = enAppSupportContentFlag.MMAPP_SUPPORT_TEXT.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_PICTURE.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_LOCATION.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_VIDEO.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_AUDIO.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_WEBPAGE.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_DOC.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_DOCX.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_PPT.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_PPTX.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_XLS.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_XLSX.rawValue | enAppSupportContentFlag.MMAPP_SUPPORT_PDF.rawValue
        WXApi.registerAppSupportContentFlag(typeFlag)
        // register with appid
        WXApi.registerApp(apiKey)
    }
    
    /// wx auth to vc
    ///
    /// - Parameters:
    ///   - currentVc:          current view
    ///   - block:              auth result block
    func wxAuth(currentVc:UIViewController,block:@escaping wxActionBlock) -> Void {
        wxUserActionBlock = block
        
        let req = SendAuthReq()
        req.scope = kAuthScope
        req.state = kAuthOpenID
        req.openID = kAuthState
        
        guard WXApi.isWXAppInstalled() else {
            WXApi.sendAuthReq(req, viewController: currentVc, delegate: self)
            return
        }
        WXApi.send(req)
    }
    
    
    /// get user token refresh_token unionid and so on
    ///
    /// - Parameters:
    ///   - wxAppKey:               apply wx appid 
    ///   - code:                   auth code 
    /// - Returns:  dic such as 数据返回格式:
    ///     {
    ///     "access_token":"ACCESS_TOKEN",   //Token
    ///     "expires_in":7200,
    ///     "refresh_token":"REFRESH_TOKEN", //刷新Token
    ///     "openid":"OPENID",
    ///     "scope":"SCOPE",
    ///     "unionid":"o6_bmasdasdsad6_2sgVt7hMZOPfL"
    ///     }
    ///     {
    ///     "errcode":40003,"errmsg":"invalid openid"
    ///     }
    func getUserToken(wxAppKey:String,code:String) -> NSDictionary {
        let urlStr = "https://api.weixin.qq.com/sns/oauth2/access_token?appid="+wxAppKey+"&secret="+WXSECRET+"&code="+code+"&grant_type=authorization_code"
        
        let url = NSURL(string: urlStr)
        
        let zoneStr : String? = (try? NSString.init(contentsOf: url! as URL, encoding: String.Encoding.utf8.rawValue)) as String?
        
        guard (zoneStr != nil) else {
            return [:]
        }
        
        let swiftjson = BLSwiftJson()
        let userTokenDic:NSDictionary? = swiftjson.JsonToObject(jsonStr: zoneStr!) as? NSDictionary
        
        return userTokenDic! 
    }
    
    
    /// get user info container user nickname、 headerImage sex and so on 
    ///
    /// - Parameters:
    ///   - access_token:           user access_token 
    ///   - open_id:                user open_id 
    /// - Returns:                  user info type is dic  example suc as 
    ///     city = Haidian;
    ///     country = CN;
    /// headimgurl = "http://wx.qlogo.cn/mmopen/FrdAUicrPIibcpGzxuD0kjfnvc2klwzQ62a1brlWq1sjNfWREia6W8Cf8kNCbErowsSUcGSIltXTqrhQgPEibYakpl5EokGMibMPU/0";
    ///    language = "zh_CN";
    ///    nickname = "xxx";
    ///    openid = oyAaTjsDx7pl4xxxxxxx;
    ///    privilege =     (
    ///    );
    ///    province = Beijing;
    ///    sex = 1;
    ///    unionid = oyAaTjsxxxxxxQ42O3xxxxxxs;
    ///     {
    ///    "errcode":40003,"errmsg":"invalid openid"
    ///     }
    func getUserInfo(access_token:String,open_id:String) -> NSDictionary {
        let urlStr = "https://api.weixin.qq.com/sns/userinfo?access_token="+access_token+"&openid="+open_id
        
        let url = NSURL(string: urlStr)
        
        let zoneStr : String? = (try? NSString.init(contentsOf: url! as URL, encoding: String.Encoding.utf8.rawValue)) as String?
        
        let swiftjson = BLSwiftJson()
        let userTokenDic:NSDictionary? = swiftjson.JsonToObject(jsonStr: zoneStr!) as? NSDictionary
        
        return userTokenDic!    
    }
    
    /// WXApiDelegate block methods
    ///
    /// - Parameter             resp: resp response
    func onResp(_ resp: BaseResp) {
        if resp.isKind(of: SendAuthResp.self) {
            let authResp = resp as! SendAuthResp
            switch authResp.errCode{
            case 0:
                // auth ok user can use wx to login 
                wxUserActionBlock?(true,wxUserAuthResultEnum.wxAuthSuccess.rawValue,authResp.code ?? "")
                break
            case -2:
                // user cancel auth 
                wxUserActionBlock?(false,wxUserAuthResultEnum.wxAuthCancel.rawValue,authResp.code ?? "")
                break
            case -4:
                // wx denied user auth
                wxUserActionBlock?(false,wxUserAuthResultEnum.wxAuthDenied.rawValue,authResp.code ?? "")
                break
            default:
                break
            }
            return
        }
        
        if resp.isKind(of: SendMessageToWXResp.self) {
            let msgResp = resp as! SendMessageToWXResp
            // errCode is 0  share msg success otherwise fail
            if msgResp.errCode == 0{
                wxUserActionBlock?(true,Int(WXSuccess.rawValue),msgResp.errStr)
            }else{
                wxUserActionBlock?(false,Int(msgResp.errCode),msgResp.errStr);
            }
        }
    }
    
    
    /// Wx share  diving into the following share TEXT IMAGE LINKURL 
    /// you can share to friends timelines,ect
    /// - Parameters:
    ///   - param:              need share info dic
    ///   - scene:              need share scene
    ///   - type:               share type
    ///   - block:              share block
    func wxShare(param:NSDictionary,scene:WXScene,type:wxUserShareInfoType,block:@escaping wxActionBlock) -> Void {
        guard WXApi.isWXAppInstalled() else {
            // tip user not install weixin APP
            return 
        }
        wxUserActionBlock = block
        let model = wxMediaModel.init(dic: param)

        switch type {
        case .wxShareText:
            WXShareHandler.WxSendText(text: model.MsgText ?? "", scene: scene)
            break
            
        case .wxShareImage:
            let data:NSData? = NSData.init()
            let imageData : NSData = model.imageData as NSData? ?? data! 
            WXShareHandler.WxSendImage(imageData: imageData , scene: scene, mediaModel: model)
            break
            
        case .wxShareLink:
            WXShareHandler.WxSendLink(urlString: model.LinkUrl ?? "", scene: scene, mediaModel:model)
            break
            
        default:
            break
        }
        
    }
    
    
}
