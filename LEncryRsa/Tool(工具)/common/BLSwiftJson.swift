//
//  BLSwiftJson.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/21.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLSwiftJson: NSObject {
    
    
    /// transfer to param object
    ///
    /// - Parameter jsonStr:                    need transfer object
    /// - Returns:                              transfer object
    func JsonToObject(jsonStr:String) -> AnyObject {
        let jsonData : Data? = (jsonStr.data(using: String.Encoding.utf8))
        let jsonObject : AnyObject? =  (try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)) as AnyObject
        return jsonObject!
    }
    
    /// transfer to json string 
    ///
    /// - Parameter object:                     need transfer object
    /// - Returns:                              json string 
    func JsonToString(object:AnyObject) -> String {
        let jsonData : Data? =  try? JSONSerialization.data(withJSONObject: object, options: .prettyPrinted)
        var jsonString :String? = String(data: jsonData!, encoding: String.Encoding.utf8)
        jsonString = jsonString?.replacingOccurrences(of: "\n", with: "")
        jsonString = jsonString?.replacingOccurrences(of: "\r", with: "")
        jsonString = jsonString?.replacingOccurrences(of: "\t", with: "")
        jsonString = jsonString?.replacingOccurrences(of: "\r\n", with: "")
        jsonString = jsonString?.replacingOccurrences(of: "\0", with: "")
        
        return jsonString ?? ""
    }
    
    
    /// sort dic construct to json string 
    ///
    /// - Parameter dic:                        need sort dic
    /// - Returns:                              json string 
    func sortJsonDic(dic:[String:Any]) -> String {
        // dic keys sort 
        let result = dic.keys.sorted(by: { (str1, str2) -> Bool in
            str1<str2
        })
         // construct json string        
        var jsonStr :NSMutableString? = NSMutableString.init()
        jsonStr?.append("{")
        for index in 0..<result.count{
            let keyStr = result[index] 
            let valueObj = dic[keyStr]
            switch valueObj{
            case is String:
                jsonStr?.append(String(format: "\"%@\":\"%@\",",keyStr, (valueObj as! String)))
                break
            case is [String:Any]:
                jsonStr?.append(String(format: "\"%@\":\"%@\",",keyStr, (BLSwiftJson().JsonToString(object: (valueObj as AnyObject)))))
                break 
            case is [Any]:
                jsonStr?.append(String(format: "\"%@\":\"%@\",",keyStr, (BLSwiftJson().JsonToString(object: (valueObj as AnyObject)))))
                break
            case is Int:
                jsonStr?.append(String(format: "\"%@\":%d,", keyStr,valueObj as! Int))
                break
            default:
                
                break
            }
        }
        let  jsonStr1 = jsonStr?.replacingCharacters(in: NSRange.init(location: (jsonStr!.length-1), length: 1), with: "")
        jsonStr = NSMutableString.init(string: jsonStr1!)
        jsonStr?.append("}")
        return jsonStr! as String
    }
    
}
