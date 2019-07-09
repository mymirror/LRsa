//
//  BLLocation.swift
//  BloodLuck
//
//  Created by xuezhiyuan on 2019/7/1.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

//class BLLocation: NSObject , AMapLocationManagerDelegate{
//    
//    //create sigleton
//    class shareInstance {
//        static let instance = BLLocation()
//        private init() {}
//    }
//    
//    func registerAMap(apikey:String){
//        AMapServices.shared()?.apiKey = apikey
//    }
//    
//    func startLocation()  {
//        
//        if !BLPermissionManager.CheckLocation() {
//            return
//        }
//        
//        let locationManager = AMapLocationManager.init()
//        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
//        locationManager.locationTimeout = 12
//        locationManager.delegate = self
//        locationManager.reGeocodeTimeout = 7
//        locationManager.locatingWithReGeocode = true
//        
//        locationManager.requestLocation(withReGeocode: true) { (location, regeocode, error) in
//            print("location___",location,regeocode,error)
//        }
//        
//        
//        
//    }
//    
//    
//
//}

