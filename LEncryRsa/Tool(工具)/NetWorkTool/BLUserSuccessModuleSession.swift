//
//  BLUserSuccessModuleSession.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/28.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLUserSuccessModuleSession: NSObject {
    
    // refresh user token 
    // When false and errmsg !="" and errmsg is LoginCredentialsExpired, the user needs to log in again. otherwise refresh net fail
    static func refreshUserToken(block:@escaping LRModuleSessionResult){
        
        let client_sign_publickey = BLRedis.readUserprivateInfo(key: "client_sign_publickey") as! String
        let client_sign_privatekey = BLRedis.readUserprivateInfo(key: "client_sign_privatekey")  as! String
        let ed25519 = BLEdSign.getEDKeyPair()
        ed25519.publickey = client_sign_publickey.dataFrom_base64String() as Data
        ed25519.privatekey = client_sign_privatekey.dataFrom_base64String() as Data
        //sign
        let refresh_token = BLRedis.readUserprivateInfo(key: "refresh_token") as! String
        let signData = BLEdSign.sign(refresh_token, ed25519)
        let signString = signData.base64EncodeToString()
        
        BLSessionManager.shareInstance.instance.commonSessionTools(param: ["sign":signString as AnyObject,"refresh_token":refresh_token as AnyObject], url: CM_Refresh_Token, method: "post", headers: [:], sucessBlock: { (refreshInfo) in
            print(refreshInfo)
            if(refreshInfo.count == 0){
                block(false,"",LoginCredentialsExpired,"")
                return
            }
            let code = refreshInfo["rsCode"]
            let rsCode = String(format: "%@", code as! CVarArg)
            guard rsCode == "200" else {
                block(false,rsCode,LoginCredentialsExpired,"")
                return
            }
            
            let rsData:[String:Any]? = refreshInfo["rsData"] as? [String:Any]
            if rsData?.count == 0{
                block(false,rsCode,LoginCredentialsExpired,"")
                return
            }
            
            let token = rsData!["token"] as! String
            let AesToken = BLEncry.BluckDecry(content_base64: token, key_base64: BLRedis.readUserprivateInfo(key: "shareEncryKey") as! String)
            let expire_time = rsData!["expire_time"] as! String
            let signDic = ["expire_time":expire_time,"token":AesToken]
            let jsonSignDic = BLSwiftJson().sortJsonDic(dic: signDic)
            let needSign = rsData!["sign"] as! String
            let signRet = BLEdSign.verifySignature(needSign, (BLRedis.readUserprivateInfo(key: "server_sign_Publickey") as! String).dataFrom_base64String(), jsonSignDic)
            
            guard signRet else {
                block(false,rsCode,LoginCredentialsExpired,"") 
                return
            }
            BLRedis.storeUserPrivateInfo(dic: ["access_token":AesToken])
            block(true,rsCode,"","")
            
        }) { (errMsg) in
            block(false,"",errMsg,"")
        }
    }
    
    
    /// user get resource
    ///
    /// - Parameters:
    ///   - sourceName:                         request source
    ///   - viewController:                     request's viewcontroller
    ///   - toast:                              request tip toast
    ///   - block:                              request result block       
    static func getResource(sourceName:String,viewController:UIViewController,toast:BLReqestToast,block:@escaping LRModuleSessionResult){
        
        let headers = ["Auth":constructRequestHeaders()]
        
        BLSessionManager.shareInstance.instance.commonSessionTools(param: [:], url: CM_Get_Reource(x: sourceName), method: "get", headers:headers, sucessBlock: { (resourceInfo) in
            print(resourceInfo)
            let code = resourceInfo["rsCode"] 
            let rsCode = String(format: "%@", code as! CVarArg)
            let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
            if(rsCode == "556"){
                // LoginCredentials Expired,APP auto refresh
                refreshUserToken(block: { (status, userCode, errMsg, successInfo) in
                    guard status else {
                        if(errMsg == LoginCredentialsExpired)
                        {
                            DispatchQueue.main.async {
                                toast.hide()
                                // user need login again 
                            }
                            
                        }else{
                            block(false,"",errMsg,"")
                        }
                        return
                    }
                    // refresh success user get new access_token
                    BLSessionManager.shareInstance.instance.commonSessionTools(param: [:], url: CM_Get_Reource(x: sourceName), method: "get", headers: headers, sucessBlock: { (successInfo) in
                        print(successInfo)
                        let code = successInfo["rsCode"]
                        let rsCode = String(format: "%@", code as! CVarArg)
                        if(rsCode == "200") {
                            // token success
                            let rsData = resourceInfo["rsData"] as? [String:Any]
                            if (rsData == nil || rsData?.count == 0){
                                // no data
                                block(true,"","","")
                                return
                            }
                            let data = rsData?["data"] as? String
                            if(data == nil || data == "" || data == "null" || data == "(null)"){
                                block(true,"","","")
                                return
                            }
                            let origin = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                            let jsonDic = (BLSwiftJson().JsonToObject(jsonStr: origin)) as? [String:String]
                            let resource_id = jsonDic?["resource_id"]
                            block(true,"","",resource_id ?? "")
                            return
                        }
                        if (rsCode == "556"){
                            block(false,"",GetResourceFail,"")
                            return
                        }
                        block(false,rsCode,"",BLSwiftJson().JsonToString(object: successInfo as AnyObject))
                    }, errBlock: { (errMsg) in
                        block(false,"",errMsg,"")
                    })
                    
                })
                return
            }
            if(rsCode == "200"){
                // get resourceId success
                let rsData = resourceInfo["rsData"] as? [String:Any]
                if (rsData == nil || rsData?.count == 0){
                    // no data
                    block(true,"","","")
                    return
                }
                let data = rsData?["data"] as? String
                if(data == nil || data == "" || data == "null" || data == "(null)"){
                    block(true,"","","")
                    return
                }
                let origin = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                let jsonDic = (BLSwiftJson().JsonToObject(jsonStr: origin)) as? [String:String]
                let resource_id = jsonDic?["resource_id"]
                print(resource_id ?? "")
                block(true,"","",resource_id ?? "")
            }
            
        }) { (errmsg) in
            block(false,"",errmsg,"")    
        }
    }
    
    
    /// common get post and so on request
    ///
    /// - Parameters:
    ///   - url:                            request ur;
    ///   - param:                          request param 
    ///   - method:                         request method 
    ///   - viewController:                 request's viewcontroller
    ///   - toast:                          request tip toast
    ///   - block:                          request result block
    static func userSuccessRequestData(url:String,param:[String:Any],
                                       method:String,viewController:UIViewController,toast:BLReqestToast,block:@escaping LRModuleSessionResult){
        
        let headers = ["Auth":constructRequestHeaders()]
        let sendParam:[String:Any] = parameterSignProcess(param: param)
        
        BLSessionManager.shareInstance.instance.commonSessionTools(param: sendParam as Dictionary<String, AnyObject>, url: url, method: method, headers: headers, sucessBlock: { (successInfo) in
            let rsCode = String(format: "%@", (successInfo["rsCode"]) as! CVarArg)
            if(rsCode == "200"){
                // request ok and user access_token is ok
                let rsData = successInfo["rsData"]
                if(rsData == nil){
                    block(true,rsCode,"","")
                    return
                }
                let dataDic = rsData as! [String:Any]
                let data = dataDic["data"] as? String
                if(data == nil || data == "" || data == "null" || data == "(null)"){
                    block(true,rsCode,"","")
                    return
                }
                let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
                let aesData = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                block(true,rsCode,"",aesData)
                return
            }
            if(rsCode == "556"){
                //refresh token
                refreshUserToken(block: { (status, code, errMsg, successInfo) in
                    guard status else {
                        if(errMsg == LoginCredentialsExpired)
                        {
                            DispatchQueue.main.async {
                                toast.hide()
                                // user need login again 
                            }
                        }else{
                            block(false,"",errMsg,"")
                        }
                        return
                    }
                    // send request again
                    BLSessionManager.shareInstance.instance.commonSessionTools(param: param as Dictionary<String, AnyObject>, url: url, method: method, headers: headers, sucessBlock: { (successInfo) in
                        let rsCode = String(format: "%@", (successInfo["rsCode"]) as! CVarArg)
                        if(rsCode == "200") {
                            let rsData = successInfo["rsData"]
                            if(rsData == nil){
                                block(true,rsCode,"","")
                                return
                            }
                            let dataDic = rsData as! [String:Any]
                            let data = dataDic["data"] as? String
                            if(data == nil || data == "" || data == "null" || data == "(null)"){
                                block(true,rsCode,"","")
                                return
                            }
                            let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
                            let aesData = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                            block(true,rsCode,"",aesData)
                            return
                        }
                        if (rsCode == "556"){
                            block(false,"",GetResourceFail,"")
                            return
                        }
                        block(false,rsCode,"",BLSwiftJson().JsonToString(object: successInfo as AnyObject))
                    }, errBlock: { (errMsg) in
                        block(false,"",errMsg,"") 
                    })
                })
                return
            }
            block(false,rsCode,"",BLSwiftJson().JsonToString(object: successInfo as AnyObject))
            
        }) { (errMsg) in
            block(false,"",errMsg,"")
        }
    }
    
    
    /// upload files
    ///
    /// - Parameters:
    ///   - url:                            upload request url
    ///   - param:                          upload request param
    ///   - fileArray:                      upload files properties
    ///   - viewController:                 upload view
    ///   - toast:                          upload tip show view
    ///   - uploadPregress:                 upload progress
    ///   - block:                          upload result block
    static func userUploadFile(url:String,param:[String:Any],fileArray:[NSDictionary],viewController:UIViewController,toast:BLReqestToast,uploadPregress:@escaping progressHandler,block:@escaping LRModuleSessionResult){
        let sendParam:[String:Any] = parameterSignProcess(param: param)
        
        BLSessionManager.shareInstance.instance.uploadFilesSessionTools(param: sendParam as Dictionary<String, AnyObject>, url: url, fileArr: fileArray, header: [:], uploadProgressValue: { (pressValue) in
            uploadPregress(pressValue)
        }, sucessBlock: { (successInfo) in
            let rsCode = String(format: "%@", (successInfo["rsCode"]) as! CVarArg)
            if(rsCode == "200"){
                // request ok and user access_token is ok
                let rsData = successInfo["rsData"]
                if(rsData == nil){
                    block(true,rsCode,"","")
                    return
                }
                let dataDic = rsData as! [String:Any]
                let data = dataDic["data"] as? String
                if(data == nil || data == "" || data == "null" || data == "(null)"){
                    block(true,rsCode,"","")
                    return
                }
                let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
                let aesData = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                block(true,rsCode,"",aesData)
                return
            }
            if(rsCode == "556"){
                refreshUserToken(block: { (status, code, errMsg, successInfo) in
                    guard status else {
                        if(errMsg == LoginCredentialsExpired)
                        {
                            DispatchQueue.main.async {
                                toast.hide()
                                // user need login again 
                            }
                        }else{
                            block(false,"",errMsg,"")
                        }
                        return
                    }
                    
                    BLSessionManager.shareInstance.instance.uploadFilesSessionTools(param: sendParam as Dictionary<String, AnyObject>, url: url, fileArr: fileArray, header: [:], uploadProgressValue: { (pressValue) in
                        uploadPregress(pressValue)
                    }, sucessBlock: { (successInfo) in
                        let rsCode = String(format: "%@", (successInfo["rsCode"]) as! CVarArg)
                        if(rsCode == "200") {
                            let rsData = successInfo["rsData"]
                            if(rsData == nil){
                                block(true,rsCode,"","")
                                return
                            }
                            let dataDic = rsData as! [String:Any]
                            let data = dataDic["data"] as? String
                            if(data == nil || data == "" || data == "null" || data == "(null)"){
                                block(true,rsCode,"","")
                                return
                            }
                            let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
                            let aesData = BLEncry.BluckDecry(content_base64: data!, key_base64: shareKey!)
                            block(true,rsCode,"",aesData)
                            return
                        }
                        if (rsCode == "556"){
                            block(false,"",GetResourceFail,"")
                            return
                        }
                        block(false,rsCode,"",BLSwiftJson().JsonToString(object: successInfo as AnyObject))
                    }, errBlock: { (errMsg) in
                        block(false,"",errMsg,"") 
                    })
                    
                })
                return 
            }
            
        }) { (errMsg) in
            block(false,"",errMsg,"")
        }
    }
    
    /// construct request headers [Auth]
    ///
    /// - Returns:                          Auth headers
    static func constructRequestHeaders() -> String {
        
        let timeStamp = BLTimeTool.getTimeStamp()
        let access_token = BLRedis.readUserprivateInfo(key: "access_token") as? String
        let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
        let uidStr = BLRedis.readUserprivateInfo(key: "uid") as? String
        let codeStr = String(format: "%@%@%@", timeStamp,access_token ?? "",shareKey ?? "",uidStr ?? "")
        let code = BLMd5Tool().sha1(str: codeStr)
        let dic = ["tamp":timeStamp,"token":access_token ?? "","code":code]
        let jsonDic = BLSwiftJson().sortJsonDic(dic: dic)
        return jsonDic 
    }
    
    
    /// Incoming parameter signature encryption processing
    ///
    /// - Parameter                         param: process param 
    /// - Returns:                          block process's result data
    static func parameterSignProcess(param:[String:Any])->[String:Any]{
        var sendParam:[String:Any] = [:]
        if param.count != 0 {
            let compareparam = BLSwiftJson().sortJsonDic(dic: param)
            let client_sign_publickey = BLRedis.readUserprivateInfo(key: "client_sign_publickey") as! String
            let client_sign_privatekey = BLRedis.readUserprivateInfo(key: "client_sign_privatekey") as! String
            let ed25519 = BLEdSign.getEDKeyPair()
            ed25519.publickey = client_sign_publickey.dataFrom_base64String() as Data
            ed25519.privatekey = client_sign_privatekey.dataFrom_base64String() as Data
            // sign 
            let signString = (BLEdSign.sign(compareparam, ed25519).base64EncodeToString()) as String
            var sendDic = param
            sendDic["sign"] = signString
            // comparae
            let jsonString = BLSwiftJson().sortJsonDic(dic: sendDic)
            let shareKey = BLRedis.readUserprivateInfo(key: ShareEncryKey) as? String
            let aesStr = BLEncry.BluckEncry(content_utf8: jsonString, key_base64: shareKey ?? "")
            sendParam["data"] = aesStr
        }
        return sendParam
    }
    
}
