//
//  BLLoginNetWork.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/26.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

typealias exchangeHandler = (_ status:Bool,_ errMsg:String,_ exchangeResult:[String:Any])->Void

class BLExhangeKey: NSObject {
    
    /// exchange key 
    ///
    /// - Parameter exchangeBlock: result block
    static func getExchangeKey(exchangeBlock:@escaping exchangeHandler)->Void{
        let keyPair:ECKeyPair = BLCurve25519.getECKeyPair()
        let keyPair_PublicKey:NSData = keyPair.publicKey()! as NSData
        let keyData:NSData = EMBEDAESKEY.dataFrom_utf8String()

        let data:NSData = BLEncry.BluckEncryData(contentData: keyPair_PublicKey, keyData: keyData)
        let base64String:String = data.base64EncodeToString()
        let param:NSDictionary = ["client_public":base64String]
        
        BLSessionManager.shareInstance.instance.commonSessionTools(param: param as! Dictionary<String, AnyObject>, url: SERVERCurve25519KEY, method: "POST", headers: [:], sucessBlock: { (info) in
            if (info.count == 0){
                exchangeBlock(false,ExChangeKeyFail,[:])
                return
            }
            //get curve25519 publick key from service
            let server_public_aes:String? = info["server_public_aes"] as? String
            let service_public:NSData = BLEncry.BluckDecryData(contentData: (server_public_aes?.dataFrom_base64String()), keyData: EMBEDAESKEY.dataFrom_utf8String())
            //generate share key
            let shareData1:NSData = BLCurve25519.generateSharedSecret(service_public, keyPair) as NSData
            let shareData:NSData = shareData1.subdata(with: NSMakeRange(16, 16)) as NSData
            let shareString:String = shareData.base64EncodeToString()
            //get data from service 
            let ret_Dic:String? = info["ret_data"] as? String
            let contentJson:String = BLEncry.BluckDecry(content_base64:ret_Dic!, key_base64: shareString)
            let contentDic:NSDictionary = BLSwiftJson().JsonToObject(jsonStr: contentJson) as! NSDictionary
            let shareDic:NSMutableDictionary = NSMutableDictionary(dictionary: contentDic as! [AnyHashable : Any], copyItems: true)
            shareDic.addEntries(from: ["shareString":shareString])
            exchangeBlock(true,ExchangeKeySuccess,shareDic as! [String : Any])

        }) { (errMsg) in
            exchangeBlock(false,errMsg,[:])
        }
        /*
        *  [shareString:sharekey] [server_signing_key:""][key_uuid:""]
        */
    }
    
    
    
    
}
