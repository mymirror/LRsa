//
//  SinaShareHandler.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/25.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

struct WeiBoShareModel {
    var shareTitle : String?            // share title
    var shareLinkUrl : String?          // share link
    var shareDescription : String?      // share des
    var shareImageData : NSData?        // share image
    
    init(dic:NSDictionary) {
        self.shareTitle  = dic["shareTitle"] as? String
        self.shareLinkUrl  = dic["shareLinkUrl"] as? String
        self.shareDescription  = dic["shareDescription"] as? String
        self.shareImageData  = dic["shareImageData"] as? NSData
    }
}

class SinaShareHandler: NSObject {
    
    static func sendWeiBoShare(model:WeiBoShareModel){
        let wbSendReq  = WBSendMessageToWeiboRequest()
        wbSendReq.message = shareWeiBoMsgObject(model: model)
        WeiboSDK.send(wbSendReq)
    }
    
    static func shareWeiBoMsgObject(model:WeiBoShareModel)->WBMessageObject{
        let wbMsgObject : WBMessageObject? = WBMessageObject()
        wbMsgObject?.text = model.shareTitle
        
        let wbWebObj : WBWebpageObject? = WBWebpageObject()
        wbWebObj?.objectID = "indentifi"
        wbWebObj?.title = model.shareLinkUrl
        wbWebObj?.webpageUrl = model.shareLinkUrl
        wbWebObj?.description = model.shareDescription
        wbWebObj?.thumbnailData = model.shareImageData as Data?
        
        wbMsgObject?.mediaObject = wbWebObj
                
        return wbMsgObject!
    }
}
