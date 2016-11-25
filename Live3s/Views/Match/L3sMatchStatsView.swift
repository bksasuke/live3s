//
//  L3sMatchStatsView.swift
//  Live3s
//
//  Created by phuc on 12/12/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit

class L3sMatchStatsView: UIView {

    var dataSource: [Stat]? {
        didSet {
            tableView.reloadData()
        }
    }
    fileprivate var tableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        createView()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        createView()
    }
    
    fileprivate func createView() {
        tableView = UITableView(frame: bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = HEADER_BACKGROUND_COLOR
        tableView.allowsSelection = false
        tableView.register(UINib(nibName: "L3sStatTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        addSubview(tableView)
    }
}

extension L3sMatchStatsView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource?.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! L3sStatTableViewCell
        let stat = dataSource![(indexPath as NSIndexPath).row]
        cell.stat = stat
        return cell
    }
    
}

extension L3sMatchStatsView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let viewFrame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 20)
        let view = UILabel(frame: viewFrame)
        view.backgroundColor = UIColor.white
        return view
    }
}

extension UITableView {
    func defaultViewForHeader(_ title: String) -> UIView {
        let viewFrame = CGRect(x: 0, y: 0, width: frame.width, height: defaultHeightForHeader())
        let view = UILabel(frame: viewFrame)
        view.textAlignment = .center
        view.backgroundColor = UIColor(rgba: "#595858")
        view.textColor = UIColor.white
        view.font = UIFont.boldSystemFont(ofSize: 15)
        view.text = AL0604.localization(title)
        return view
    }
      func defaultHeightForHeader() -> CGFloat {
        return 40
    }
}
