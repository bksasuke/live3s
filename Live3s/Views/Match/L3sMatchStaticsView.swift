//
//  L3sMatchStaticsView.swift
//  Live3s
//
//  Created by phuc on 1/5/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import UIKit

class L3sMatchStaticsView: UIView {

    var viewcontroller: UIViewController!
    var containerView: UIView!
    var homeName: String!
    var awayName: String!
    var homeDataSource: [StaticMatch]? {
        didSet {
            tableView.reloadData()
        }
    }
    var awayDataSource: [StaticMatch]? {
        didSet {
            tableView.reloadData()
        }
    }
    var h2hataSource: [StaticMatch]? {
        didSet {
            tableView.reloadData()
        }
    }
    @IBOutlet weak var tableView: UITableView!
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView = commonInit()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView = commonInit()
    }
    fileprivate func commonInit() -> UIView {
        func nibName() -> String {
            return type(of: self).description().components(separatedBy: ".").last!
        }
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: nibName(), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.frame = bounds
        view.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.addSubview(view)        
        tableView.register(UINib(nibName: "L3sStaticTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        tableView.allowsSelection = true
        return view
    }
    
}

extension L3sMatchStaticsView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return h2hataSource?.count ?? 0
        case 1: return homeDataSource?.count ?? 0
        case 2: return awayDataSource?.count ?? 0
        default: return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! L3sStaticTableViewCell
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        var infor: StaticMatch?
        switch (indexPath as NSIndexPath).section {
        case 0:
            infor = h2hataSource![(indexPath as NSIndexPath).row]
            break
        case 1:
            infor = homeDataSource![(indexPath as NSIndexPath).row]
            break
        case 2:
            infor = awayDataSource![(indexPath as NSIndexPath).row]
            break
        default: break
        }
        cell.infor = infor
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let supperview = UIView(frame: CGRect(x: 0, y: 0, width: frame.width, height: 60))
            supperview.backgroundColor = UIColor.white
            let viewFrame = CGRect(x: 0, y: 20, width: frame.width, height: 40)
            let view = UILabel(frame: viewFrame)
            view.textAlignment = .center
            view.backgroundColor = UIColor(rgba: "#595858")
            view.textColor = UIColor.white
            view.font = UIFont.boldSystemFont(ofSize: 15)
            let strTitite = "\(homeName) \(AL0604.localization(LanguageKey.face_to_face)) \(awayName)"
            view.text = strTitite
            supperview.addSubview(view)
            return supperview

        case 1: return tableView.defaultViewForHeader(homeName)
        case 2: return tableView.defaultViewForHeader(awayName)
        default: return UIView()
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
                    return 60
        }else{
                    return tableView.defaultHeightForHeader()
        }


    }
}

extension L3sMatchStaticsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var infor: StaticMatch!
        switch (indexPath as NSIndexPath).section {
        case 0:
            infor = h2hataSource![(indexPath as NSIndexPath).row]
            break
        case 1:
            infor = homeDataSource![(indexPath as NSIndexPath).row]
            break
        case 2:
            infor = awayDataSource![(indexPath as NSIndexPath).row]
            break
        default: break
        }
        let match: MatchModule = MatchModule()
        match.id = "\(infor.matchId)"
        match.is_finish = "1"
        match.away_club_name = infor.awayName
        match.away_goal = "\(infor.awayGoal)"
        match.home_club_name = infor.homeName
        match.home_goal = "\(infor.homeGoal)"
        match.time_start = infor.timeStart
        match.home_goalH1 = infor.first_time_home_goal
        match.away_goalH1 = infor.first_time_away_goal
        
        let matchDetailVC = L3sMatchDetailViewController(nibName: "L3sMatchDetailViewController", bundle: nil)
        matchDetailVC.match = match
        viewcontroller.navigationController?.pushViewController(matchDetailVC, animated: true)
    }
}
