//
//  BLPermissionManager.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/6/27.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit
import MapKit
import AssetsLibrary
import AVFoundation


class BLPermissionManager: NSObject {
    
    static func CheckNotification()->Bool{
        
        var check = false
        let notification = UIApplication.shared.currentUserNotificationSettings
        if notification?.types == UIUserNotificationType.init(rawValue: 0) {
            BLPermissionManager().openSetting("温馨提示", "为了更好的体验,请到设置->血之缘->通知中开启通知服务,已便获取最新的通知信息!")
        }else{
            check = true
        }
        return check
    }
    
    static func CheckLocation()->Bool{
        
        var check = false
        let status = CLLocationManager.authorizationStatus()
        if status == CLAuthorizationStatus.denied || status == CLAuthorizationStatus.restricted {
            BLPermissionManager().openSetting("温馨提示", "为了更好的体验,请到设置->血之缘->位置中开启定位服务,已便获取附近信息!")
        }else{
            check = true
            
        }
        return check
    }
    
    static func CheckGetPhoto()->Bool{
        
        var check = false
        let status = ALAssetsLibrary.authorizationStatus()
        if status == ALAuthorizationStatus.denied || status == ALAuthorizationStatus.restricted {
            BLPermissionManager().openSetting("温馨提示", "为了更好的体验,请到设置->血之缘->照片中开启访问照片,已便获取相机照片!")
        }else{
            check = true
            
        }
        return check
    }
    
    static func CheckTakePhoto()->Bool{
        
        var check = false
        let status = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        if status == AVAuthorizationStatus.denied || status == AVAuthorizationStatus.restricted {
            BLPermissionManager().openSetting("温馨提示", "为了更好的体验,请到设置->血之缘->相机中开启服务,开启相机拍照功能!")
        }else{
            check = true
        }
        return check
    }
    
    
    func openSetting(_ title:String,_ message:String){
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "残忍拒绝", style: .cancel, handler: nil)
        let okAction = UIAlertAction(title: "确认", style: .default, handler: {
            action in
            print("点击了确定")
            let url = NSURL(string: UIApplication.openSettingsURLString)
            if UIApplication.shared.canOpenURL(url! as URL ) {
                UIApplication.shared.openURL(url! as URL)
            }
        })
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        
        let vc = BLCurrentController.getTopVC()
        print("presentviewcontroller:_____",vc as Any)
        vc!.present(alertController, animated:true, completion: nil)
        
        
    }

}

