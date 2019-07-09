//
//  BLRegisterLoginSession.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/26.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

typealias LRModuleSessionResult = (_ status:Bool,_ code:String,_ errMsg:String,_ successMsg:String)->Void

class BLRegisterLoginModuleSession: NSObject {
    
    // login or register need param: cell_phone_number,password,verify_code,invite_code
    /// common login or register and third account login
    ///
    /// - Parameters:
    ///   - url:                        login\register\third part login url
    ///   - param:                      need post param 
    ///   - block:                      request block
    static func loginInWithRegister(url:String,param:NSDictionary,block:@escaping LRModuleSessionResult) -> Void {
        // first get exchange key on the service
        BLExhangeKey.getExchangeKey { (status, msg, exchangeDic) in
            guard status else {
                // get exchangekey fail user can tip msg
                return
            }
            var userParam = [String:Any]()
            for indexKey in param.allKeys{
                let keyStr:String = indexKey as! String
                userParam[keyStr] = param.value(forKey: keyStr) 
            }
            //get user psd
            var psd:String? = userParam["password"] as! String?
            if psd != nil{ 
                psd = BLMd5Tool().md5(str: psd ?? "")
                userParam["password"] = psd
            }
            // should sort userParam‘s key order by ascii
            let paramJson = BLSwiftJson().sortJsonDic(dic: userParam)
            print(BLSwiftJson().JsonToObject(jsonStr: paramJson))
            //create ed25519 keypair
            let ed25519 = BLEdSign.getEDKeyPair()
            let client_sign_publicKey = ed25519.publickey?.base64EncodedString()
            let client_sign_privateKey = ed25519.privatekey?.base64EncodedString()
            //ed25519 sign 
            let signData = BLEdSign.sign(paramJson, ed25519)
            let signBase64Str = signData.base64EncodedString()
            userParam["sign"] = signBase64Str
            userParam["client_sign_publickey"] = client_sign_publicKey
            //sort new dic
            let newSortJsonStr = BLSwiftJson().sortJsonDic(dic: userParam)
            // share key aes newSortJsonStr
            let shareKey = exchangeDic["shareString"] as! String
            let aesStr = BLEncry.BluckEncry(content_utf8: newSortJsonStr, key_base64: shareKey)
            // construct send param 
            let sendParamDic = ["data":aesStr,"uuid":(exchangeDic["key_uuid"] as! String)]
            
            BLSessionManager.shareInstance.instance.commonSessionTools(param: sendParamDic as Dictionary<String, AnyObject>, url: url, method: "post", headers: [:], sucessBlock: { (userInfo) in
                print(userInfo)
                let rsCode = userInfo["rsCode"]
                let codeStr = String(format: "%@", rsCode as! CVarArg)
                // construct rsdata
                let rsData:[String:Any]? = userInfo["rsData"] as? [String:Any]
                guard (codeStr == "200") else {
                    // when code is 267 or 273 
                    if(codeStr=="267"||codeStr=="273"){
                        // data aes get origin data
                        let resultData:String? = rsData?["data"] as? String
                        let decryStr:String? = BLEncry.BluckDecry(content_base64: resultData!, key_base64: shareKey) as String
                        block(false,codeStr,"",decryStr ?? "")      
                    }else{
                        block(false,codeStr,"","")
                    }
                    return
                }
                if (rsData == nil){
                    // no data can return
                    block(true,codeStr,"","")
                    return
                }
                guard rsData?.count != 0 else {
                    block(true,codeStr,"","")
                    return
                }
                let resultData:String? = rsData?["data"] as? String
                let decryStr:String? = BLEncry.BluckDecry(content_base64: resultData!, key_base64: shareKey) as String
                guard decryStr != nil else{
                    block(false,"","数据处理失败","")
                    return;
                }
                let dataDic:NSMutableDictionary? = BLSwiftJson().JsonToObject(jsonStr: decryStr ?? "") as? NSMutableDictionary
                let dataSignStr = dataDic?["sign"]
                dataDic?.removeObject(forKey: "sign")
                let jsonDataDicStr = BLSwiftJson().sortJsonDic(dic: (dataDic as AnyObject) as! [String : Any])
                let server_signing_key = exchangeDic["server_signing_key"] as! String
                let verifyRet = BLEdSign.verifySignature(dataSignStr as! String, server_signing_key.dataFrom_base64String(), jsonDataDicStr)
                guard verifyRet else {
                    block(false,"","数据非法","")
                    return
                }
                //data is ok and success
                var storeDic = [String:Any]()
                let check_record = String(format: "%@", (rsData!["check_record"])! as! CVarArg)
                storeDic["is_reg"] = check_record
                let access_token = dataDic?.value(forKey: "access_token") as! String
                storeDic["access_token"] = access_token
                
                let refresh_token = dataDic?.value(forKey: "refresh_token") as! String
                storeDic["refresh_token"] = refresh_token
                
                let cell_phone_number:Any? = dataDic?.value(forKey: "cell_phone_number")
                if cell_phone_number != nil{
                    storeDic["cell_phone_number"] = String(format: "%@", cell_phone_number as! CVarArg) 
                }
                
                storeDic["shareEncryKey"] = shareKey
                storeDic["server_sign_Publickey"] = server_signing_key
                storeDic["client_sign_publickey"] = client_sign_publicKey
                storeDic["client_sign_privatekey"] = client_sign_privateKey
                storeDic["uid"] = (dataDic?.value(forKey: "uid") as! String)
                let lastUid = BLRedis.readUserprivateInfo(key: "LastUid") as? String
                if lastUid == nil{
                    storeDic["LastUid"] = storeDic["uid"] 
                }else{
                    if let valueUid = lastUid{
                        if (valueUid == "" || valueUid == "(null)" || 0 == valueUid.count){
                            storeDic["LastUid"] = storeDic["uid"]
                        }
                    }
                }
                BLRedis.storeUserPrivateInfo(dic: storeDic)
                
                block(true,codeStr,"","")
            }, errBlock: { (errMsg) in
                block(false,"",errMsg,"")
            })
        }
    }
    
    
    /// Device verification request
    ///
    /// - Parameters:
    ///   - url:                            request url
    ///   - param:                          request param
    ///   - tempToken:                      Device verification temporary toke
    ///   - addDeviceAuth:                  Add device to trust list 
    ///   - block:                          request block
    static func verifyDeviceAuth(url:String,param:NSDictionary,tempToken:String,addDeviceAuth:Int,block:@escaping LRModuleSessionResult)->Void{
        // first get service exchangekey
        BLExhangeKey.getExchangeKey { (status, msg, exchangeDic) in
            guard status else {
                block(status,"",msg,"")
                return
            }
            // construct param
            let sendDic:NSMutableDictionary = NSMutableDictionary.init(dictionary: param)
            if (tempToken.isEmpty == false){
                sendDic.setValue(tempToken, forKey: "temp_token")
            }
            // click to two part : need adddevice and do not need add device
            var sendUrl = url;
            if (addDeviceAuth == 1){
                sendUrl = String(format: "%@?add_device=1", url)
            }
            // sort dic
            let jsonStr =  BLSwiftJson().sortJsonDic(dic: sendDic as! [String:Any]) 
            let shareStr = exchangeDic["shareString"] as! String
            let signJson = BLEncry.BluckEncry(content_utf8: jsonStr, key_base64: shareStr) as AnyObject
            
            BLSessionManager.shareInstance.instance.commonSessionTools(param: ["data":signJson,"uuid":(exchangeDic["key_uuid"] as AnyObject)], url: sendUrl, method: "post", headers: [:], sucessBlock: { (info) in
                block(true,"","","")
            }, errBlock: { (errMsg) in
                block(false,"",errMsg,"")
            })
        }
    }
    
}
