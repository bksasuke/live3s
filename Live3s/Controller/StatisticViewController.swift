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


class StatisticViewController: L3sViewController {

    @IBOutlet weak var tableView: UITableView!
    var isGetCountryDone = false
    var isGetSessionDone = false
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    internal var isShowFull:Bool = false
    fileprivate var arraySession: [StatisticSession]? = [StatisticSession](){
        didSet {
            
            isGetSessionDone = true
            if isGetCountryDone {
                self.tableView.reloadData()
                self.isReloadingData = false
            }
            
        }
    }
    fileprivate var arrayCountry: [StatisticCountry]? = [StatisticCountry](){
        didSet {
            isGetCountryDone = true
            if isGetSessionDone {
                self.tableView.reloadData()
                self.isReloadingData = false
            }

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
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Statistic")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        getCoutry()
        getCommomLeagues()
        self.addAvertising()
        self.addAvertisingFull()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bannerView?.removeFromSuperview()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func getCoutry(){
        NetworkService.getCountry { (countries, error) -> Void in
            if error == nil {
                if let arrayCoutries = countries{
                    self.arrayCountry = arrayCoutries
                }
            }else{
                self.isReloadingData = false
            }
        }
    }
    
    func getCommomLeagues(){
        NetworkService.getCommomLeague { (commomLeagues, error) -> Void in
            if error == nil {
                if let arrayCommomLeagues = commomLeagues{
                    self.arraySession = arrayCommomLeagues
                }
            }else{
                self.isReloadingData = false
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
        if self.isShowFull{
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
}

// MARK: - GADInterstitialDelegate
extension StatisticViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }
        
    }
}

//MARK - UITableViewDatasource
extension StatisticViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            if let countSeason = arraySession?.count{
                return countSeason
            }else {
                return 0
            }
        }else{
            if let countContry = arrayCountry?.count{
                return countContry
            }else {
                return 0
            }
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatisticCell") as! StatisticCell
        cell.selectionStyle = .none
        cell.delegate = self
        if (indexPath as NSIndexPath).section == 0 {
            cell.imgFavorite.isHidden = false
            let sessionOBJ:StatisticSession = arraySession![(indexPath as NSIndexPath).row]
            cell.lblTitle.text = sessionOBJ.name
            var favorite = seasonfavoriteList()
            if let _ = favorite.index(of: sessionOBJ.id!) {
                cell.imgFavorite.image = UIImage(named: "icon_favorited.png")
            } else  {
                favorite.append(sessionOBJ.id!)
                cell.imgFavorite.image = UIImage(named: "icon_favorite.png")
            }
            let url = URL(string: sessionOBJ.league_logo!)
             cell.imgFlag.af_setImageWithURL(url!)
        }else {
            cell.imgFavorite.isHidden = true
            let countryOBJ:StatisticCountry = arrayCountry![(indexPath as NSIndexPath).row]
            cell.lblTitle.text = countryOBJ.name
            let url = URL(string: countryOBJ.country_logo!)
            cell.imgFlag.af_setImageWithURL(url!)
        }
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white

        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lgFrame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 30)
        let view = UIView(frame:lgFrame)
        view.backgroundColor = UIColor(red: 89/255, green: 88/255, blue: 88/255, alpha: 1.0)
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 5, width: view.frame.size.width, height: 20))
        titleLabel.font = UIFont.systemFont(ofSize: 15)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        if section == 0 {
            titleLabel.text = AL0604.localization(LanguageKey.common)
        }else{
            titleLabel.text = AL0604.localization(LanguageKey.all)
        
        }
        view.addSubview(titleLabel)
        return view
    }
    
}
//MARK - UITableViewDelegate
extension StatisticViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == 0 {
            let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailStatisticViewController") as! DetailStatisticViewController
            let sessionOBJ:StatisticSession = arraySession![(indexPath as NSIndexPath).row]
            detailVC.leagueID = sessionOBJ.id
            detailVC.urlLogo = sessionOBJ.league_logo
            detailVC.isRank = true
            detailVC.isMatch = false
            detailVC.isIndex = false
            navigationController?.pushViewController(detailVC, animated: true)

        }else{
            let sessionVC =  storyboard?.instantiateViewController(withIdentifier: "SessionViewController") as! SessionViewController
            let country = arrayCountry![(indexPath as NSIndexPath).row]
            sessionVC.statisticCountry = country
            navigationController?.pushViewController(sessionVC, animated: true)
        }
    }
    
}
//Mark - StatisticCellDelegate 
extension StatisticViewController: StatisticCellDelegate{
    func actionFavoriteSession(_ cell: StatisticCell) {
        let indexPath = self.tableView.indexPath(for: cell)
        let season = self.arraySession![((indexPath as NSIndexPath?)?.row)!]
        var favorite = seasonfavoriteList()

        if let index = favorite.index(of: season.id!) {
            favorite.remove(at: index)
            cell.imgFavorite.image = UIImage(named: "icon_favorite.png")
        } else  {
            favorite.append(season.id!)
            cell.imgFavorite.image = UIImage(named: "icon_favorited.png")
        }
        setSeasonfavoriteList(favorite)
    }
}

//MARK - StatisticCell
protocol StatisticCellDelegate: NSObjectProtocol {
    func actionFavoriteSession(_ cell: StatisticCell)
}
class StatisticCell: UITableViewCell{

    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgFavorite: UIImageView!
    @IBOutlet weak var buttonFavorite: UIButton!
    var delegate: StatisticCellDelegate?
    @IBAction func actionFavorite(_ sender: AnyObject) {
        self.delegate?.actionFavoriteSession(self)
    }
    

}

