//
//  WXShareHandler.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/24.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class WXShareHandler: NSObject {
    
    
    /// share text type
    ///
    /// - Parameters:
    ///   - text:               share content
    ///   - scene:              share scene
    static func WxSendText(text:String,scene:WXScene){
        let model = wxMediaModel.init(dic: [:])
        let sendReq = WXShareObject.sendWxMsgReq(bText: true, text: text, scene: scene, mediaModel: model)
        WXApi.send(sendReq)
    }
    
    
    /// share image Type
    ///
    /// - Parameters:
    ///   - imageData:             share image Data
    ///   - scene:                 share scene
    ///   - mediaModel:            share additional object such as share title suntitle and so on
    static func WxSendImage(imageData:NSData?,scene:WXScene,mediaModel:wxMediaModel){
        let wxObject = WXImageObject.init()
        wxObject.imageData = imageData! as Data
        
        var model = mediaModel
        model.MediaObject = wxObject as AnyObject?
        
        let sendReq = WXShareObject.sendWxMsgReq(bText: false, text: "", scene: scene,mediaModel:model)
        WXApi.send(sendReq)
    }
    
    
    /// share link type
    ///
    /// - Parameters:
    ///   - urlString:              share link url
    ///   - scene:                  share scene
    ///   - mediaModel:             share additional object such as share title suntitle and so on
    static func WxSendLink(urlString:String,scene:WXScene,mediaModel:wxMediaModel){
        let ext = WXWebpageObject()
        ext.webpageUrl = urlString
        var model = mediaModel
        model.MediaObject = ext
        
        let sendReq = WXShareObject.sendWxMsgReq(bText: false, text: "", scene: scene, mediaModel: mediaModel)
        WXApi.send(sendReq)
    }

}
