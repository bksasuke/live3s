//
//  L3sLiveTvViewController.swift
//  Live3s
//
//  Created by phuc on 2/26/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
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


class L3sLiveTvViewController: L3sViewController {

    
    /**
     properties
     */
    @IBOutlet weak var tableView: UITableView!
    
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    internal var isShowFull:Bool = false
    fileprivate var datasource:[LeagueTVOBJ] = [LeagueTVOBJ](){
        didSet {
            tableView.reloadData()
            isReloadingData = false
        }
    }
    fileprivate var isFirstTime = true
    fileprivate var isReloadingData = false {
        didSet {
            if isReloadingData {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.separatorStyle = .none
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        tableView.register(UINib(nibName: "L3sLiveTvTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "LiveTV")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        getLiveTVFromServer()
        
        self.addAvertising()
        self.addAvertisingFull()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime {
            isFirstTime = false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    func getLiveTVFromServer(){
        if isReloadingData{return}
        isReloadingData = true
        NetworkService.getLiveTV(true) { [unowned self](league, error) -> Void in
            if error == nil {
                if let leagues = league {
                    self.datasource = leagues                    
                }
            } else {
                // Show alert
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
extension L3sLiveTvViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }
        
    }
}
extension L3sLiveTvViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let league = datasource[section]
        return league.matchs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! L3sLiveTvTableViewCell
        let league:LeagueTVOBJ = self.datasource[(indexPath as NSIndexPath).section]
        let match:MatchTVOBJ = league.matchs[(indexPath as NSIndexPath).row]
        cell.match = match
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        } else {
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let lgFrame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 30)
        let view = UIView(frame:lgFrame)
        view.backgroundColor = UIColor(red: 89/255, green: 88/255, blue: 88/255, alpha: 1.0)
        let flag = UIImageView(frame: CGRect(x: 10, y: 5, width: 25, height: 20))
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 5, width: view.frame.size.width, height: 20))
        titleLabel.font = UIFont.boldSystemFont(ofSize: 14)
        titleLabel.textColor = UIColor.white
        titleLabel.textAlignment = .center
        if let league: LeagueTVOBJ = self.datasource[section]{
            
            let url = URL(string: league.league_logo)!
            flag.af_setImageWithURL(url)
            let seasons = Season.findByID(league.league_id)
            titleLabel.text = seasons?.name
        }
        
        view.addSubview(titleLabel)
        view.addSubview(flag)
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let detailVC =  storyboard.instantiateViewController(withIdentifier: "DetailLiveTVViewController") as! DetailLiveTVViewController
        let league:LeagueTVOBJ = self.datasource[(indexPath as NSIndexPath).section]
        let match:MatchTVOBJ = league.matchs[(indexPath as NSIndexPath).row]
        detailVC.matchLive = match
        detailVC.isLiveTv = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
