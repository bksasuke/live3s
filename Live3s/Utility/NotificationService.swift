//
//  NotificationService.swift
//  Live3s
//
//  Created by ALWAYSWANNAFLY on 3/12/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import Foundation

struct NotificationService {
    
    //MARK: Public variable
    
    static let shareInstance = NotificationService()
    
    //MARK: Prvate variable
    fileprivate let kUSERDEFAULT_DEVICETOKEN = "emobi.wind.live3s_deviceToken"
    fileprivate let userDefault = UserDefaults.standard
    
    
    //MARK: Public method
    
    func getDeviceToken() -> String? {
        return userDefault.string(forKey: kUSERDEFAULT_DEVICETOKEN)
    }
    
    func saveDeviceToken(_ token: String) {
        userDefault.set(token, forKey: kUSERDEFAULT_DEVICETOKEN)
    }
    
    func registerUserNotification() {
            let setting = UIUserNotificationSettings(types: [.alert, .sound, .badge], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            UIApplication.shared.registerForRemoteNotifications()
    }
    
    func registerDevietokenForPushServer(_ token: String) {
        
        func pushTokenToServer(_ token: String) {
            NetworkService.registDeviceToken(token, completion: { (bool) in
                if bool {
                    self.saveDeviceToken(token)
                }
            })
        }
        
        guard let oldToken = getDeviceToken() else {
            // push new token to server
            pushTokenToServer(token)
            return
        }
        
        if oldToken == token {
            // already have token on server
            return
        } else {
            // get new token
            pushTokenToServer(token)
        }
        
    }
}
