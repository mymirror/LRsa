//
//  BLProtocolJump.swift
//  BloodLuck
//
//  Created by ponted on 2019/6/25.
//  Copyright © 2019 xuezhiyuan. All rights reserved.
//

import Foundation

extension AppDelegate {

    func registerThirdAccount() -> Void {
        WXManager.registerWX(apiKey: WXCHATAPPKEY)
        QQManager.shareInstance.instance.registerQQ(appId: QQAPPID)
        SinaManager.registerWeiBo(appId: SINAAPPKEY)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return WXApi.handleOpen(url, delegate: WXManager.shareInstance.instance) ||
               WeiboSDK.handleOpen(url, delegate: SinaManager.shareInstace.instance) ||
               TencentOAuth.handleOpen(url)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return WXApi.handleOpen(url, delegate: WXManager.shareInstance.instance) ||
               WeiboSDK.handleOpen(url, delegate: SinaManager.shareInstace.instance) ||
               TencentOAuth.handleOpen(url)
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        return WXApi.handleOpen(url, delegate: WXManager.shareInstance.instance) ||
               WeiboSDK.handleOpen(url, delegate: SinaManager.shareInstace.instance) ||
               TencentOAuth.handleOpen(url)
    }
}
