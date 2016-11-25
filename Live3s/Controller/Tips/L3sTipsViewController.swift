//
//  L3sTipsViewController.swift
//  Live3s
//
//  Created by phuc on 1/24/16.
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

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}

class L3sTipsViewController: L3sViewController {

    
    @IBOutlet weak var tableView: UITableView!
    var live3sAccount = Live3sAccount()
    fileprivate var segmentedControl: UISegmentedControl!
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    internal var isShowFull:Bool = false
    fileprivate var isReloadingData = false {
        didSet {
            if isReloadingData {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }
    fileprivate var isTipVip = false
    fileprivate var dataTip:[TipsModule] = [TipsModule]()
    fileprivate var dataTipVIP:[TipsModule] = [TipsModule]()
    fileprivate var dataSource: [TipsModule]! {
        didSet {
            for tip:TipsModule in dataSource {
                if tip.vip == "1" {
                   dataTipVIP.append(tip)
                    isTipVip = true
                }else{
                    dataTip.append(tip)
                    isTipVip = false
                }
            }
            self.tableView.reloadData()
            isReloadingData = false
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
        tableView.register(UINib(nibName: "L3sTpsTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
        //addRightBarButtonWithImage(UIImage(named: "rightBarButton.png")!)
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // setupnavigationBar()
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Tips")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        addAvertising()
        self.addAvertisingFull()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    //MARK: - setup navigation bar view
    
    func setupnavigationBar() {
        let tipfree = AL0604.localization(LanguageKey.tip_free)
        let tipvip = AL0604.localization(LanguageKey.tip_vip)
        let items = [tipfree, tipvip]
        segmentedControl = UISegmentedControl(items: items)
        segmentedControl.frame = CGRect(x: 0, y: 0, width: 100, height: 30)
        segmentedControl.selectedSegmentIndex = 0
        let attributes = [
            NSForegroundColorAttributeName: UIColor.white,
            NSFontAttributeName: UIFont.boldSystemFont(ofSize: 12)
        ]
        segmentedControl.setTitleTextAttributes(attributes, for: .selected)
        segmentedControl.backgroundColor = UIColor(white: 0, alpha: 0.1)
        segmentedControl.isUserInteractionEnabled = true
        segmentedControl.addTarget(self, action: #selector(self.changeTypeTip), for: .touchUpInside)
        navigationItem.titleView = segmentedControl
    }
    func changeTypeTip() {
        if isTipVip {
            isTipVip = false
            self.tableView.reloadData()
        }else{
            isTipVip = true
            self.tableView.reloadData()
        }
    }
    // MARK: - get data
    
    func reloadData() {
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getTipsData { [unowned self](tips, error) -> () in
            if error == nil {
                guard let aTips = tips else {return}
                self.dataSource = aTips
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
extension L3sTipsViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }
        
    }
}
extension L3sTipsViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isTipVip {
            return dataTipVIP.count ?? 0
        }else{
            return dataTip.count ?? 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! L3sTpsTableViewCell
        if isTipVip {
            let tip = dataTipVIP[(indexPath as NSIndexPath).row]
            cell.tip = tip
        }else{
            let tip = dataTip[(indexPath as NSIndexPath).row]
            cell.tip = tip
        }
        if (indexPath as NSIndexPath).row % 2 == 1 {cell.backgroundColor = tableViewCellbackgroundCoor}
        else {cell.backgroundColor = UIColor.white}
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tipDetailsVC = L3sTipDetailViewController(nibName: "L3sTipDetailViewController", bundle: nil)
        if isTipVip {
            let tipModule = dataTipVIP[(indexPath as NSIndexPath).row]
            live3sAccount = Live3sAccount.getAccount()
            if live3sAccount.userName != "" {
                if tipModule.tip != ""{
                    let iTip = Int(tipModule.tip)
                    let iCurrentGold = Int(live3sAccount.userGold)
                    if iTip > iCurrentGold {
                        // show alert bao ban ko du gold hay mua them
                    }else{
                        // tru gold dang luu tru va chuyen sang man hinh detail tip
                        live3sAccount.userGold = "\(iCurrentGold! - iTip!)"
                        self.live3sAccount.saveAccount()
                        tipDetailsVC.tip = tipModule
                        navigationController?.pushViewController(tipDetailsVC, animated: true)
                    }
                }
            }else{
                // Show alert yêu cầu login : login or huỷ 
                // Khi người dùng chọn login và cho login bằng facebook xong thi lưu tên và sô gold lúc đầu = 0
            }
            
        }else{
             tipDetailsVC.tip = dataTip[(indexPath as NSIndexPath).row]
            navigationController?.pushViewController(tipDetailsVC, animated: true)
        }
        
    }
}
