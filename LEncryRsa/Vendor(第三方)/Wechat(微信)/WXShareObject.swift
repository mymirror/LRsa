//
//  WXShareObject.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/24.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit


/// media model
struct wxMediaModel {
    var MsgTitle:String?            // WXMediaMessage title
    var MsgDescription:String?      // WXMediaMessage description
    var MediaObject:AnyObject?      // WXMediaMessage mediaObject
    var MsgExt:String?              // WXMediaMessage msgExt
    var MsgAction:String?           // WXMediaMessage Action
    var MsgThubImage:NSData?        // WXMediaMessage image
    var MediaTagName:String?        // WXMediaMessage tagname
    var LinkUrl:String?             // share link url is not inside WXMediaMessage
    var MsgText:String?             // share text is not inside WXMediaMessage 
    var imageData:Data?             // share image  is not inside WXMediaMessage
    
    init(dic:NSDictionary) {
        self.MsgTitle = dic["MsgTitle"] as! String?
        self.MsgDescription = dic["MsgDescription"] as! String?
        self.MediaObject = (dic["MediaObject"] as AnyObject?)
        self.MsgExt = (dic["MsgExt"] as! String?)
        self.MsgAction = (dic["MsgAction"] as! String?)
        self.MsgThubImage = (dic["MsgThubImage"] as! NSData?)
        self.MediaTagName = (dic["MediaTagName"] as! String?)
        self.LinkUrl = (dic["LinkUrl"] as! String?)
        self.MsgText = (dic["MsgText"] as! String?)
        self.imageData = (dic["imageData"] as? Data)

    }
    
}

class WXShareObject: NSObject {
    
     static func sendWxMsgReq(bText:Bool,text:String,scene:WXScene,mediaModel:wxMediaModel)->SendMessageToWXReq{
        let sendMsgReq = SendMessageToWXReq()
        sendMsgReq.bText = bText
        sendMsgReq.scene = Int32(scene.rawValue)
        
        guard bText else {
            sendMsgReq.message = sendWxMedia(mediaModel: mediaModel)
            return sendMsgReq
        }
        
        sendMsgReq.text = text
        return sendMsgReq
    }
    
    static func sendWxMedia(mediaModel:wxMediaModel)->WXMediaMessage{
        let mediaMsg = WXMediaMessage()
        mediaMsg.title = mediaModel.MsgTitle ?? ""
        mediaMsg.description = mediaModel.MsgDescription ?? ""
        mediaMsg.mediaObject = mediaModel.MediaObject as Any 
        mediaMsg.messageExt = mediaModel.MsgExt
        mediaMsg.messageAction = mediaModel.MsgAction
        mediaMsg.thumbData = mediaModel.MsgThubImage as Data?
        mediaMsg.mediaTagName = mediaModel.MediaTagName
        
        return mediaMsg
    }
}
