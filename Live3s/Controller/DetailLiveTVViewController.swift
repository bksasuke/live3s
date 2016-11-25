//
//  DetailLiveTVViewController.swift
//  Live3s
//
//  Created by codelover2 on 25/01/2016.
//  Copyright © Năm 2016 com.phucnguyen. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds
import SwiftyJSON
import Alamofire
import AlamofireImage
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class DetailLiveTVViewController : UIViewController{
    
    @IBOutlet weak var tableview: UITableView!
    @IBOutlet weak var lblHomeName: UILabel!
    @IBOutlet weak var lblAwayName: UILabel!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblTiso: UILabel!
    @IBOutlet weak var lblTisoHT: UILabel!
    var isLiveTv = false
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    fileprivate var arrayChanel:[JSON]? = [JSON]() {
        didSet {
            self.tableview.reloadData()
        }
    }

    internal var matchLive:MatchTVOBJ?
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeader()
        self.tableview.dataSource = self;
        self.tableview.delegate = self;
        self.tableview.separatorStyle = .none
         NotificationCenter.default.addObserver(self, selector: #selector(DetailLiveTVViewController.addAvertising), name: NSNotification.Name(rawValue: ADD_AD), object: nil)
        self.addAvertisingFull()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        lblTisoHT.isHidden = isLiveTv
        lblStatus.isHidden = isLiveTv
        self.getDataFromServer()
    } 
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }
    func updateDataTable() {
        setUpHeader()
    }
    func setUpHeader() {
        if let matchLive = self.matchLive {
            for updateOBJ in L3sAppDelegate.arrayUpdate {
                if matchLive.id == updateOBJ.match_id {
                    matchLive.status = updateOBJ.status
                    matchLive.home_goal = updateOBJ.home_goal
                    matchLive.away_goal = updateOBJ.away_goal
                    matchLive.home_goalH1 = updateOBJ.home_goalH1;
                    matchLive.away_goalH1 = updateOBJ.away_goalH1;
                }
            }
            self.lblHomeName.text = matchLive.home_club_name
            self.lblAwayName.text = matchLive.away_club_name
            if isLiveTv {
                self.lblTiso.text = "vs"
            }else{
                if matchLive.time_start > Date().timeIntervalSince1970 {
                    self.lblStatus.text = DateManager.shareManager.dateToString(matchLive.time_start, format: "HH:mm")
                    self.lblTiso.text = "?-?"
                    lblTisoHT.text = ""
                    self.lblTisoHT.isHidden = true
                }else {
                    if matchLive.status != "" {
                        self.lblStatus.text = matchLive.status
                    }else {
                        self.lblStatus.text = "Live"
                    }
                    if matchLive.home_goal == "" {
                        matchLive.home_goal = "0"
                    }
                    
                    if matchLive.away_goal == "" {
                        matchLive.away_goal = "0"
                    }
                    self.lblTiso.text = "\(matchLive.home_goal) - \(matchLive.away_goal)"
                    let h1 = matchLive.time_start + 2700
                    if h1 <= Date().timeIntervalSince1970{
                        if matchLive.home_goalH1 != "" && matchLive.away_goalH1 != ""{
                            self.lblTisoHT.text =     "(HT \(matchLive.home_goalH1) - \(matchLive.away_goalH1))"
                            self.lblTisoHT.isHidden = false
                        }else{
                            self.lblTisoHT.isHidden = true
                        }
                        
                    }else{
                        self.lblTisoHT.isHidden = true
                    }

                    
                }
                
            }

        }
    }
    
    func getDataFromServer(){
        NetworkService.getListChannel((matchLive?.id)!) { (json, error) in
            for (_,subJson):(String,JSON) in json {
                self.arrayChanel?.append(subJson)
            }
        }
    }
    
    
    func addAvertising() {
        if let appDeleteAD = L3sAppDelegate.adBanner{
            if appDeleteAD.visible == "true"{
                let bannerFrame = CGRect(x: 0, y: self.view.frame.size.height - 50, width: self.view.frame.size.width, height: 50);
                bannerView = GADBannerView(frame: bannerFrame)
                bannerView!.adUnitID = appDeleteAD.id;
                bannerView!.rootViewController = self;
                let request:GADRequest = GADRequest();
                // Enable test ads on simulators.
                request.testDevices = [kGADSimulatorID];
                self.view.addSubview(bannerView!)
                bannerView?.load(request)
            }
        }
    }
    
    func addAvertisingFull(){
            if let appDeleteADFull = L3sAppDelegate.adFull{
                if appDeleteADFull.visible == "true"{
                    let varial = arc4random_uniform(100) + 1
                    if Int(varial) < Int(appDeleteADFull.rate){
                        self.interstitial = GADInterstitial(adUnitID: appDeleteADFull.id)
                        let request = GADRequest()
                        // Requests test ads on test devices.
                        request.testDevices = [kGADSimulatorID];
                        self.interstitial.load(request)
                        self.interstitial.delegate = self
                    }
                }
            }
    }


}

// MARK: - GADInterstitialDelegate
extension DetailLiveTVViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
        
    }
}
//MARK - UITableViewDatasource
extension DetailLiveTVViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let countChannel = arrayChanel?.count{
            return countChannel
        }else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellTV") as! ChannelLiveTVCell
        cell.selectionStyle = .none
       
        if let json:JSON = arrayChanel?[indexPath.row]{
            if (indexPath as NSIndexPath).row % 2 == 0{
                cell.backgroundColor = UIColor.white
                cell.contentView.backgroundColor = UIColor.white
                
            }else{
                cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                cell.contentView.backgroundColor = UIColor(rgba: "#f5f5f5")
            }
            cell.lblTitle.text = json["name"].stringValue
            let logo = json["logo"].stringValue
            let url = URL(string: logo)
             cell.logoImage.af_setImageWithURL(url!)
            
            let arrayList = json["channels"].arrayValue ?? nil
            if arrayList?.count > 0 {
                var str = ""
                for subJson:JSON in arrayList! {
                    let strChannel = subJson["channel"].stringValue
                    str = str + "\(strChannel)\n"
                }
                cell.lblChannel.text = str
            }else{
                cell.lblChannel.text = ""
            }
        }
       
        return cell
    }
    
}

//MARK - UITableViewDelegate
extension DetailLiveTVViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
         if let json:JSON = arrayChanel?[indexPath.row]{
            let arrayList = json["channels"].arrayValue ?? nil
            if arrayList?.count > 0 {
                if arrayList?.count == 1 {
                    return 40
                }else{
                    let count = Int((arrayList?.count)!)
                    let value = count - 1
                    return CGFloat(value * 30)
                }
               
               
            }else{
                return 40
            }
         }else{
            return 40
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

    }
    
}


// Mark - ChannelLiveTVCell
class ChannelLiveTVCell: UITableViewCell {
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblChannel: UILabel!
    
    @IBOutlet weak var logoImage: UIImageView!
}
