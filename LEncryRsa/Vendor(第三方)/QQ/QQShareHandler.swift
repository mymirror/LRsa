//
//  QQShareHandler.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/25.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit


struct QQShareObjectModel {
    var shareText : String?     // when share type is QQText this param is ok
    var shareTitle : String?    // when share type is QQLink this param is ok
    var shareDecription : String? // when share type is QQLink this param is ok
    var shareLinkUrl : String? // when share type is QQLink this param is ok
    var sharePreviewObject : AnyObject? // when share type is QQLink this param is ok
    
    init(dic:NSDictionary) {
        self.shareText = dic["shareText"] as! String?
        self.shareTitle = dic["shareTitle"] as! String?
        self.shareDecription = dic["shareDecription"] as! String?
        self.shareLinkUrl = dic["shareLinkUrl"] as! String?
        self.sharePreviewObject? = dic["sharePreviewObject"] as AnyObject
    }
        
}

enum QQShareScene:Int {
    case QQShareFriends = 0 // only to friends Conversation
    case QQShareZone = 1    // only to qq zone 
    case QQShareFriends_Zone = 2  // user select share to friends Conversation or qq zone
}

class QQShareHandler: NSObject {
    
    static func QQSendText(text:String,scene:QQShareScene){
        
        if scene.rawValue == 1 {
            // share to zone otherwise share to friends
            let zoneObj = QQApiImageArrayForQZoneObject.init(imageArrayData: nil, title: text, extMap: nil)
            zoneObj?.shareDestType = ShareDestTypeQQ
            let sendMsgReq = SendMessageToQQReq.init(content: zoneObj)
            let sendApiCode = QQApiInterface.sendReq(toQZone: sendMsgReq)
            handlerResult(code: sendApiCode)
            return
        }
        if scene.rawValue == 0{
            let textObj = QQApiTextObject.init(text: text)
            textObj?.shareDestType = ShareDestTypeQQ
            let sendMsgReq = SendMessageToQQReq.init(content: textObj)
            let sendApiCode = QQApiInterface.sendReq(toQZone: sendMsgReq)
            handlerResult(code: sendApiCode)
            return
        }
        
    }
    
    
    static func QQSendLinkUrl(title:String,linkUrl:String,previewObject:AnyObject,description:String,scene:QQShareScene){
        
        var shareFlag = 0
        
        switch scene.rawValue {
        case 0:
            shareFlag = kQQAPICtrlFlagQZoneShareOnStart
            break
        case 1:
            shareFlag = kQQAPICtrlFlagQZoneShareForbid
            break
        case 2:
            shareFlag = kQQAPICtrlFlagQQShare
            break
        default:
            break
        }
        
        
        if previewObject.isKind(of: NSString.self){
            // share 
            let newObj:QQApiNewsObject = QQApiNewsObject.object(with: NSURL(string: linkUrl) as URL?, title: title, description: description , previewImageURL: NSURL(string: (previewObject as! String)) as URL?) as! QQApiNewsObject
            newObj.cflag = UInt64(shareFlag)
            let sendMsgReq = SendMessageToQQReq.init(content: newObj)
            let sendApiCode = QQApiInterface.sendReq(toQZone: sendMsgReq)
            handlerResult(code: sendApiCode)
        }else{
            let newObj:QQApiNewsObject = QQApiNewsObject.object(with: NSURL(string: linkUrl) as URL?, title: title, description: description, previewImageData: (previewObject as? Data)) as! QQApiNewsObject
            newObj.cflag = UInt64(shareFlag)
            let sendMsgReq = SendMessageToQQReq.init(content: newObj)
            let sendApiCode = QQApiInterface.sendReq(toQZone: sendMsgReq)
            handlerResult(code: sendApiCode)
        }
        
    }

    
    static func handlerResult(code:QQApiSendResultCode) -> Void {
        switch (code)
        {
        case EQQAPISENDSUCESS:
            //发送成功
            break;
        case EQQAPIQQNOTINSTALLED:
            //未安装QQ
            break;
            
        case EQQAPIQQNOTSUPPORTAPI:
            //未支持API
            break;
            
        case EQQAPIMESSAGETYPEINVALID:
            //发送参数错误
            break;
            
        case EQQAPIMESSAGECONTENTNULL:
            //发送参数错误
            break;
            
        case EQQAPIMESSAGECONTENTINVALID:
            //发送参数错误
            break;
            
        case EQQAPIAPPNOTREGISTED:
            //APP未注册
            break;
            
        case EQQAPIAPPSHAREASYNC:
            //分享异步
            break;
            
        case EQQAPISENDFAILD:
            //发送失败
            break;
            
        case EQQAPISHAREDESTUNKNOWN:
            //未指定分享到QQ或TIM
            break;
            
        case EQQAPITIMNOTINSTALLED:
            //TIM未安装
            break;
            
        case EQQAPITIMNOTSUPPORTAPI:
            //TIM api不支持
            break;
            
        case EQQAPIQZONENOTSUPPORTTEXT:
            //qzone分享不支持text类型分享
            break;
            
        case EQQAPIQZONENOTSUPPORTIMAGE:
            //qzone分享不支持image类型分享
            break;
            
        case EQQAPIVERSIONNEEDUPDATE:
            //当前QQ版本太低，需要更新至新版本才可以支持
            break;
            
        case ETIMAPIVERSIONNEEDUPDATE:
            //当前QQ版本太低，需要更新至新版本才可以支持
            break;
            
        default:
            break;
        }
    }
    
    
}
