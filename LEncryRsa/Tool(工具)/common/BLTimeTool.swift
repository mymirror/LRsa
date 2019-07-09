//
//  BLTimeTool.swift
//  BloodLuck
//
//  Created by ponted on 2019/7/2.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import UIKit

class BLTimeTool: NSObject {
    static func getTimeStamp() -> String {
        let dat = NSDate.init(timeIntervalSinceNow: 0)
        let  a = dat.timeIntervalSince1970
        let timeString = String(format: "%f", a)
        return timeString
    }
}
