//
//  L3sMatchLineUpView.swift
//  Live3s
//
//  Created by phuc on 12/14/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import SwiftyJSON

class L3sMatchLineUpView: UIView {
    
    fileprivate var containerView: UIView!

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    var homeDataSource = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    var awaySource = [JSON]() {
        didSet {
            tableView.reloadData()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        containerView = commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        containerView = commonInit()        
    }
    // MARK: - private method
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
        tableView.allowsSelection = false
        segmentedControl.tintColor = HEADER_BACKGROUND_COLOR
        return view
    }
    
    // Mark: - public method
    
    @IBAction func didChangeSelectedSegment(_ sender: AnyObject) {
        tableView.reloadData()
    }

    func setSegmentedSection(_ home: String, away: String) {
        segmentedControl.setTitle(home, forSegmentAt: 0)
        segmentedControl.setTitle(away, forSegmentAt: 1)
    }
}

// MARK: - UITableViewDataSource 

extension L3sMatchLineUpView: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var dataSource: [JSON]!
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            dataSource = homeDataSource
        case 1:
            dataSource = awaySource
        default: break
        }
        if dataSource.count < 2 {return 0}
        if section == 0 {
            return dataSource[0].count ?? 0
        } else {
            return dataSource[1].count ?? 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        if let acell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
            cell = acell
        } else {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        var playerName: String!
        var dataSource: [JSON]!
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            dataSource = homeDataSource
        case 1:
            dataSource = awaySource
        default: break
        }
        if (indexPath as NSIndexPath).section == 0 {
            let playerList = dataSource[0]
            playerName = playerList["\(indexPath.row + 1)"].stringValue
        } else {
            let playerList = dataSource[1]
            playerName = playerList["\(indexPath.row + 1)"].stringValue
        }
        cell.textLabel?.text = playerName
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        return cell
    }
}

extension L3sMatchLineUpView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return ""
        } else {
            return AL0604.localization(LanguageKey.formation_sub)
        }
    }
}
