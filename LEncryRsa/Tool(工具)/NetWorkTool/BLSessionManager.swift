//
//  BLSessionManager.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/19.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit
import Alamofire

typealias sucessHandler = (_ sucessHandlerInfo: [String:Any])->Void

typealias errorHandler = (_ errorHandlerMsg: String)->Void

typealias progressHandler = (_ progressValue: Double)->Void

class BLSessionManager: NSObject {
    var requestDic:NSMutableDictionary? = NSMutableDictionary.init()
    
    //create sigleton  
    class shareInstance {
        static let instance = BLSessionManager()
        private init() {}
    }           
    /// common get post delete request and so on 
    ///
    /// - Parameters:
    ///   - param:          request with params
    ///   - url:            request url
    ///   - method:         request method such as : get post delete and so on
    ///   - headers:        request headers
    ///   - sucessBlock:    sucess request result block
    ///   - errBlock:       fail request result block
    func commonSessionTools(param:Dictionary<String,AnyObject>,url:String,method:String,headers:[String:String],
                            sucessBlock:@escaping sucessHandler,errBlock:@escaping errorHandler){
        /*
         GET: Retrieves data, such as a web page, but doesn’t alter any data on the server.
         PATCH: Sends data to the specific location provided.
         POST: Sends data to the server, commonly used when filling a form and clicking submit.
         PUT: Sends data to the specific location provided.
         DELETE: Deletes data from the specific location provided.
         */
        var method1 : HTTPMethod = .get
        switch method.uppercased() {
        case "POST":
            method1 = .post
            break
        case "DELETE":
            method1 = .delete
            break
        case "PUT":
            method1 = .put
            break
        case "PATCH":
            method1 = .patch
            break
        default:
            break  
        }
        let headers1:NSMutableDictionary? = NSMutableDictionary()
        if headers.count != 0 {
            headers1?.addEntries(from: headers)
        }
        let auth:String? = headers["Auth"]
        if (auth == nil || auth == "") {
            let access_token:String? = (UserDefaults.standard.value(forKey: "access_token")) as? String
            let access_token_dic:[String:String] = ["access_token":access_token ?? ""]
            let swiftjson = BLSwiftJson()
            let json_token : String = swiftjson.JsonToString(object: access_token_dic as AnyObject)
            headers1?.setValue(json_token as Any, forKey: "Auth")
        }
        // get device key
        let uuidStr = BLKeyChain.saveAndLoadKeyChain()
        let deviceName = UIDevice.current.name
        let verify_code_dic = ["device_code":uuidStr,"device_name":deviceName] as [String:Any]
        let verify_json = BLSwiftJson().JsonToString(object: verify_code_dic as AnyObject)
        let verify_base64 = (BLEncry.BluckEncryData(contentData: verify_json.dataFrom_utf8String(), keyData: EMBEDAESKEY.dataFrom_utf8String())).base64EncodeToString()
        headers1?.setValue(verify_base64, forKey: "VERIFY-CODE")
        let commonDataRequest:DataRequest =  Alamofire.request(url, method: method1, parameters: param, encoding: URLEncoding.default, headers: headers1 as? HTTPHeaders).responseData { (response) in
            self.cancelCurrentRequest(url: url, param: param as NSDictionary)
            let code :Int? = response.response?.statusCode
            if code != 200
            {
                errBlock(response.error?.localizedDescription ?? "")
                return;
            }
            let ss:AnyObject? = (try? JSONSerialization.jsonObject(with: response.result.value!, options:.mutableContainers) as AnyObject?)
            
            if ss is Dictionary<String, Any>
            {    
                sucessBlock(ss as! [String : Any])
            }else
            {
                if(ss == nil){
                    sucessBlock(["stringData":""]) 
                    return
                }
                let data1  = NSString.init(data: response.result.value!, encoding:String.Encoding.utf8.rawValue)
                sucessBlock(["stringData":data1 ?? ""])
            }
        }
        addRequestIntli(url: url, param: param as NSDictionary, commonRequest: commonDataRequest)
    }
    
    
    
    /// send file to service 
    ///
    /// - Parameters:
    ///   - param:                  send rquest param 
    ///   - url:                    send request url
    ///   - fileArr:                file info kind is array
    ///   - header:                 send request header
    ///   - uploadProgressValue:    send progress
    ///   - sucessBlock:            sucess request result block
    ///   - errBlock:               error request result block
    func uploadFilesSessionTools(param:Dictionary<String,AnyObject>,url:String,fileArr:[NSDictionary],
                                 header:[String:String],uploadProgressValue:@escaping progressHandler,
                                 sucessBlock:@escaping sucessHandler,errBlock:@escaping errorHandler) {
        
        let headers1:NSMutableDictionary? = NSMutableDictionary()
        if header.count != 0 {
            headers1?.addEntries(from: header)
        }
        let auth:String? = header["Auth"]
        if (auth == nil || auth == "") {
            let access_token:String? = (UserDefaults.standard.value(forKey: "access_token")) as? String
            let access_token_dic:[String:String] = ["access_token":access_token ?? ""]
            let swiftjson = BLSwiftJson()
            let json_token : String = swiftjson.JsonToString(object: access_token_dic as AnyObject)
            headers1?.setValue(json_token as Any, forKey: "Auth")
        }
        
        Alamofire.upload(multipartFormData: { (data) in
            for fileDic in fileArr{
                let fileName:String? = (fileDic["fileName"]) as? String
                let fileData:Data? = (fileDic["fileData"]) as? Data
                let fileType:String? = (fileDic["type"]) as? String
                let fileKey:String? = (fileDic["file"]) as? String
                data.append(fileData!, withName: fileKey!, fileName: fileName!, mimeType: fileType!)
            }
        }, usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold, to: url, method: .post, headers: headers1 as? HTTPHeaders) { (EncodingResult) in
            switch EncodingResult {
            case .success(let uploadAction,_,_):
                self.addRequestIntli(url: url, param: param as NSDictionary, commonRequest: uploadAction)
                uploadAction.responseData(completionHandler: { (data) in
                    self.cancelCurrentRequest(url: url, param: param as NSDictionary)
                    let code :Int? = data.response?.statusCode
                    if code != 200
                    {
                        errBlock(data.error?.localizedDescription ?? "")
                        return;
                    }
                    let ss:AnyObject? = (try? JSONSerialization.jsonObject(with: data.result.value!, options:.mutableContainers) as AnyObject?)
                    
                    if ss is Dictionary<String, Any>
                    {    
                        sucessBlock(ss as! [String : Any])
                    }else
                    {
                        if(ss == nil){
                            sucessBlock(["stringData":""]) 
                            return
                        }
                        let data1  = NSString.init(data: data.result.value!, encoding:String.Encoding.utf8.rawValue)
                        sucessBlock(["stringData":data1 ?? ""])
                    }
                })
                uploadAction.uploadProgress(closure: { (Progress) in
                    uploadProgressValue(Progress.fractionCompleted)
                })
            case .failure(let encodingError): 
                self.cancelCurrentRequest(url: url, param: param as NSDictionary)
                errBlock(encodingError.localizedDescription)
                break
            }
            
        }
        
    }
    
    
    /// cancel current request
    ///
    /// - Parameters:
    ///   - url:                need cancel request's url string
    ///   - param:              need cancel request param
    func cancelCurrentRequest(url:String,param:NSDictionary) {
        
        let needMd5Str:NSMutableString? = NSMutableString()
        needMd5Str?.append(url)
        if param.count != 0 {
            let jsonSwift = BLSwiftJson()
            let jsonString :String? = (jsonSwift.JsonToString(object: param as AnyObject)) as String?
            needMd5Str?.append(jsonString!)
        }
        let mdTool = BLMd5Tool()
        let md5Str : String? = (mdTool.md5(str: needMd5Str! as String)) 
        let request:DataRequest? = requestDic?.value(forKey: md5Str!) as! DataRequest?
        request?.cancel()
        requestDic?.removeObject(forKey: md5Str!)
    }
    
    
    /// add request inteli logo 
    ///
    /// - Parameters:
    ///   - url:                request url
    ///   - param:              request param
    ///   - commonRequest:      request object
    func addRequestIntli(url:String,param:NSDictionary,commonRequest:AnyObject) {
        let needMd5Str:NSMutableString? = NSMutableString()
        needMd5Str?.append(url)
        if param.count != 0 {
            let jsonSwift = BLSwiftJson()
            let jsonString :String? = (jsonSwift.JsonToString(object: param as AnyObject)) as String?
            needMd5Str?.append(jsonString!)
        }
        let mdTool = BLMd5Tool()
        let md5Str : String? = (mdTool.md5(str: needMd5Str! as String)) 
        requestDic?.setValue(commonRequest, forKey: md5Str!)
    }
    
}
