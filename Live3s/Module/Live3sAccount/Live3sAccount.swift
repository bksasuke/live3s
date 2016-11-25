//
//  Live3sAccount.swift
//  Live3s
//
//  Created by ATCOMPUTER on 09/05/2016.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import Foundation

let live3sUserName = "username"
let live3sUserImage = "userImage"
let live3sUserGold = "usergold"
let live3sAccount = "live3sAccount"
class Live3sAccount: NSObject, NSCoding {
    
   // let getInstance:Live3sAccount = Live3sAccount(userName: "", gold: "0")
    var userName:String = ""
    var userGold:String = ""
    var imageUrl:String = ""
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.userName, forKey: live3sUserName)
        aCoder.encode(self.userGold, forKey: live3sUserGold)
        aCoder.encode(self.imageUrl, forKey: live3sUserImage)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init()
        self.userName = aDecoder.decodeObject(forKey: live3sUserName) as! String
        self.userGold = aDecoder.decodeObject(forKey: live3sUserGold) as! String
        self.imageUrl = aDecoder.decodeObject(forKey: live3sUserImage) as! String
    }
    
    override init() {
        super.init()
    }
    
    init(userName:String, gold:String) {
        self.userName = userName
        self.userGold = gold
    }

    func saveAccount() {
        let data = NSKeyedArchiver.archivedData(withRootObject: self)
        UserDefaults.standard.set(data, forKey: live3sAccount)
    }
    
    static func getAccount() -> Live3sAccount  {
        if let data = UserDefaults.standard.object(forKey: live3sAccount) as? Data {
            return (NSKeyedUnarchiver.unarchiveObject(with: data) as? Live3sAccount)!
        }
        return Live3sAccount()
    }
}
