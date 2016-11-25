//
//  StatisticViewController.swift
//  Live3s
//
//  Created by phuc on 11/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import GoogleMobileAds
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


class SessionViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var statisticCountry: StatisticCountry?
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    fileprivate var arraySession: [StatisticSession]? = [StatisticSession](){
        didSet {
            
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }

    fileprivate var isReloadingData = false {
        didSet {
            if isReloadingData {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        LoadingView.sharedInstance.showLoadingView(view)
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        getDataFromServer((self.statisticCountry?.id)!)
        self.addAvertisingFull()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getDataFromServer(_ coutry_id:String) {
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getLeagueOfCountry(coutry_id) { (leagues, error) -> () in
            if error == nil {
                if let arrayLeague = leagues {
                    if arrayLeague.count > 0 {
                        for leagueJSON in arrayLeague {
                            let leagueOBJ = StatisticSession(json: leagueJSON)
                            self.arraySession?.append(leagueOBJ);
                        }
                    }else{
                        let alert = UIAlertController(title: AL0604.localization(LanguageKey.alert), message:AL0604.localization(LanguageKey.no_data), preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.cancel), style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        self.isReloadingData = false
                    }
                    
                }else{
                    let alert = UIAlertController(title: AL0604.localization(LanguageKey.alert), message:AL0604.localization(LanguageKey.no_data), preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.cancel), style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                    self.isReloadingData = false
                }
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

//MARK: - SesionTableViewCellDelegate
extension SessionViewController: SesionTableViewCellDelegate {
    func actionFavorite(_ cell: SesionTableViewCell) {
        var favorite = seasonfavoriteList()
        let id = cell.season!.id!
        if let index = favorite.index(of: id) {
            favorite.remove(at: index)
            cell.imgFavorite.image = UIImage(named: "icon_favorite.png")
        } else  {
            favorite.append(cell.season!.id!)
            cell.imgFavorite.image = UIImage(named: "icon_favorited.png")
        }
        setSeasonfavoriteList(favorite)
    }
}
//MARK - UITableViewDatasource
extension SessionViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if let countSeason = arraySession?.count{
                return countSeason
            }else {
                return 0
            }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionCell") as! SesionTableViewCell
        cell.selectionStyle = .none
        let sessionOBJ:StatisticSession = arraySession![(indexPath as NSIndexPath).row]
         cell.season = sessionOBJ
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        cell.delegate = self
        let url = URL(string: statisticCountry!.country_logo!)
        cell.imgFlag.af_setImageWithURL(url!)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lgFrame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 30)
        let view = UIView(frame:lgFrame)
        view.backgroundColor = UIColor(red: 89/255, green: 88/255, blue: 88/255, alpha: 1.0)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 5, width: self.view.frame.size.width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        if let strTitle = self.statisticCountry?.name{
                titleLabel.text = strTitle
        }
        view.addSubview(titleLabel)
        return view
    }
    
    
}
// MARK: - GADInterstitialDelegate
extension SessionViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
        
    }
}

//MARK - UITableViewDelegate
extension SessionViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailStatisticViewController") as! DetailStatisticViewController
        let leagueSelect = self.arraySession![(indexPath as NSIndexPath).row]
        detailVC.leagueID = leagueSelect.id
        detailVC.urlLogo = self.statisticCountry?.country_logo
        detailVC.isRank = true
        detailVC.isMatch = false
        detailVC.isIndex = false
        navigationController?.pushViewController(detailVC, animated: true)
        
    }
}
//MARK - StatisticCell
protocol SesionTableViewCellDelegate: NSObjectProtocol {
    func actionFavorite(_ cell: SesionTableViewCell)
}

class SesionTableViewCell: UITableViewCell{
    
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgFavorite: UIImageView!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var season: StatisticSession? {
        didSet {

                lblTitle.text = season?.name
                let favorite = seasonfavoriteList()
            if favorite.contains(season!.id!) {
                imgFavorite.image = UIImage(named: "icon_favorited.png")
            } else {
                imgFavorite.image = UIImage(named: "icon_favorite.png")
            }
        }
    }
    var delegate: SesionTableViewCellDelegate?
    
    @IBAction func favoriteButtonPress(_ sender: AnyObject) {
        self.delegate?.actionFavorite(self)
    }
}

