//
//  L3sSettingView.swift
//  Live3s
//
//  Created by phuc on 1/18/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import RealmSwift
import UIKit

enum IndexRegister: Int {
    case kickoff = 0, goal, redCard, halftime, fullTime
}

enum TypeRegister: Int {
    case kickoff = 1, goal, halftime, redCard, fullTime
}

class L3sSettingView: UIView {
    
    var tableView: UITableView!
    var leagueID:String?
    var matchID:String?
    var matchPush: MatchPush?
    
    var dataSource = [
        "Kick Off",
        "Goal",
        "Red Card",
        "Half Time",
        "Full Time",]
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
        if let matchID = matchID {
            matchPush = MatchPush.findByID(matchID)
            tableView.reloadData()
        }else{
            matchPush = MatchPush.findByID("9999")
            tableView.reloadData()
        }
      
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createView()
        if let matchID = matchID {
            matchPush = MatchPush.findByID(matchID)
            tableView.reloadData()
        }else{
            matchPush = MatchPush.findByID("9999")
            tableView.reloadData()
        }

        
    }
    
    fileprivate func createView() {
        backgroundColor = UIColor.white
        tableView = UITableView(frame: bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "L3sSettingTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        addSubview(tableView)
    }
    
    func registerPush(_ matchID:String, pushType:String, status:String) {
        NetworkService.registerPush(status, matchID: matchID, pushType: pushType) { (result, pushType, status, error) in
            if result == "success"{
                    switch Int(pushType)! {
                    case TypeRegister.kickoff.rawValue:
                        self.matchPush?.kickoff = Int(status)
                        MatchPush.saveMatchPush(self.matchPush!)
                        break
                    case TypeRegister.goal.rawValue:
                        self.matchPush?.goal = Int(status)
                        MatchPush.saveMatchPush(self.matchPush!)
                        break
                    case TypeRegister.redCard.rawValue:
                        self.matchPush?.redcard = Int(status)
                        MatchPush.saveMatchPush(self.matchPush!)
                        break
                    case TypeRegister.halftime.rawValue:
                        self.matchPush?.halftime = Int(status)
                        MatchPush.saveMatchPush(self.matchPush!)
                        break
                    case TypeRegister.fullTime.rawValue:
                        self.matchPush?.fulltime = Int(status)
                        MatchPush.saveMatchPush(self.matchPush!)
                        break
                    default:
                        break
                    }
            }else{
                
            }
        }
    }
    
}

extension L3sSettingView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! L3sSettingTableViewCell
        cell.delegate = self
        if (indexPath as NSIndexPath).row == 0 {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 17)
        } else {
            cell.titleLabel.font = UIFont.systemFont(ofSize: 14)
        }
         cell.switchControl.setOn(false, animated: false)
        if let matchPush = self.matchPush{
            switch (indexPath as NSIndexPath).row {
            case IndexRegister.kickoff.rawValue:
                if matchPush.kickoff == 2{
                    cell.switchControl.setOn(false, animated: false)
                }else{
                    cell.switchControl.setOn(true, animated: false)
                }
                break
            case IndexRegister.goal.rawValue:
                if matchPush.goal == 2{
                    cell.switchControl.setOn(false, animated: false)
                }else{
                    cell.switchControl.setOn(true, animated: false)
                }
                break
            case IndexRegister.redCard.rawValue:
                if matchPush.redcard == 2{
                    cell.switchControl.setOn(false, animated: false)
                }else{
                    cell.switchControl.setOn(true, animated: false)
                }
                break
            case IndexRegister.halftime.rawValue:
                if matchPush.halftime == 2{
                    cell.switchControl.setOn(false, animated: false)
                }else{
                    cell.switchControl.setOn(true, animated: false)
                }
                break
            case IndexRegister.fullTime.rawValue:
                if matchPush.fulltime == 2{
                    cell.switchControl.setOn(false, animated: false)
                }else{
                    cell.switchControl.setOn(true, animated: false)
                }
                break
            default:
                break
            }
            
        }
        guard let defaultRealm = try? Realm(),
            let item = defaultRealm.objectForPrimaryKey(MatchPushList.self, key: AL0604.currentLanguage)?.list,
            let title = item.filter({$0.value == (indexPath.row+1).description}).first else {return cell}
        cell.titleLabel.text = title.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath as NSIndexPath).row == 0 {
            return 50
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}

extension L3sSettingView: L3sSettingTableViewCellDelegate{
    func actionChangeRegister(_ cell: L3sSettingTableViewCell) {
        let indexPath = tableView.indexPath(for: cell)
        if let matchPush = self.matchPush{
            switch (indexPath! as NSIndexPath).row {
            case IndexRegister.kickoff.rawValue:
                if matchPush.kickoff == 1{
                    registerPush(matchID!, pushType: "1", status: "2")
                }else{
                    registerPush(matchID!, pushType: "1", status: "1")
                }
                break
            case IndexRegister.goal.rawValue:
                if matchPush.goal == 1{
                    registerPush(matchID!, pushType: "2", status: "2")
                }else{
                    registerPush(matchID!, pushType: "2", status: "1")
                }
                break
            case IndexRegister.redCard.rawValue:
                if matchPush.redcard == 1{
                    registerPush(matchID!, pushType: "4", status: "2")
                }else{
                    registerPush(matchID!, pushType: "4", status: "1")
                }
                break
            case IndexRegister.halftime.rawValue:
                if matchPush.halftime == 1{
                    registerPush(matchID!, pushType: "3", status: "2")
                }else{
                    registerPush(matchID!, pushType: "3", status: "1")
                }
                break
            case IndexRegister.fullTime.rawValue:
                if matchPush.fulltime == 1{
                    registerPush( matchID!, pushType: "5", status: "2")
                }else{
                    registerPush( matchID!, pushType: "5", status: "1")
                }
                
                break
            default:
                break
            }
            
        }
        
    }
    
}
