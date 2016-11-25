//
//  TVSchelduleViewController.swift
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


class TVSchelduleViewController: L3sViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerScroll: ScrollPager!
    fileprivate var headerView = [MatchDayButton]()
    var bannerView: GADBannerView?
     var interstitial: GADInterstitial!
    internal var isShowFull:Bool = false
    fileprivate var datasource:[LeagueTVOBJ] = [LeagueTVOBJ](){
        didSet {
            tableView.reloadData()
            isReloadingData = false
        }
    }
    fileprivate var selectedHeaderIndex: Int = 0
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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "TVScheldule")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        self.addAvertising()
        self.addAvertisingFull()
        getLiveTVFromServer()
         NotificationCenter.default.addObserver(self, selector: #selector(TVSchelduleViewController.updateDataTable), name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstTime {
            setUpHeader()
            isFirstTime = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }
    
    func updateDataTable() {
        self.tableView.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpHeader() {
        let currentDate = Date().timeIntervalSince1970
        let firstheaderDate = currentDate - Double(86400 * middleItem)
        for index in 0...(maxItem - 1) {
            let timeinterval = firstheaderDate + Double(index * 86400)
            let aDate = Date(timeIntervalSince1970: timeinterval)
            let components = DateManager.shareManager.dateComponentFromString(aDate, format: "dd-MM-yyyy")
            let view = MatchDayButton(frame: CGRect.zero)
            view.title = "\(components.day)-\(components.month)-\(components.year)"
            view.subTitle = components.day
            headerView.append(view)
        }
        headerScroll.addSegmentWithViews(headerView)
        headerScroll.delegate = self
        headerScroll.selectedIndex = middleItem
        headerScroll.delegate?.scrollPagerdidSelectItem!(headerScroll, index: headerScroll.selectedIndex)
        
    }
    func getLiveTVFromServer(){
        if isReloadingData{return}
        isReloadingData = true
        NetworkService.getLiveTV(false) { [unowned self](league, error) -> Void in
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
extension TVSchelduleViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }
        
    }
}
//MARK: - ScrollPgaerDelegate

extension TVSchelduleViewController: ScrollPagerDelegate {
    func scrollPager(_ scrollPager: ScrollPager, changedIndex: Int) {
        headerView[changedIndex].selected = true
        updateButtonColor(changedIndex)
        
    }
    func scrollPagerWillChange(_ scrollPager: ScrollPager, fromIndex: Int) {
        headerView[fromIndex].selected = false
    }
    func scrollPagerdidSelectItem(_ scrollPager: ScrollPager, index: Int) {
        
        //        getDataFromServerWithDate(headerView[index].title!)
        
    }
    func updateButtonColor(_ selectedIndex: Int) {
        for index in 0..<headerView.count {
            headerView[index].type = .noneType
        }
        if selectedIndex > 0 {
            headerView[selectedIndex - 1].type = .semiSelectedType
        }
        if selectedIndex < (headerView.count - 1) {
            headerView[selectedIndex + 1].type = .semiSelectedType
        }
        headerView[selectedIndex].type = .selectedType
    }
    
}

//MARK: - UITableviewDatasource
extension TVSchelduleViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return datasource.count ?? 0
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let league = datasource[section]
        return league.matchs.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TVCell", for: indexPath) as! TVScheduleCell
        let league:LeagueTVOBJ = self.datasource[(indexPath as NSIndexPath).section]
        let match:MatchTVOBJ = league.matchs[(indexPath as NSIndexPath).row]
        cell.match = match
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
}


//MARK: - UITableviewDelegate
extension TVSchelduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailLiveTVViewController") as! DetailLiveTVViewController
        let league:LeagueTVOBJ = self.datasource[(indexPath as NSIndexPath).section]
        let match:MatchTVOBJ = league.matchs[(indexPath as NSIndexPath).row]
        detailVC.matchLive = match
//       detailVC.isLiveTv = true
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

//MARK: - TVScheduleTableViewCell

class TVScheduleCell: UITableViewCell {
    
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var lblHomeName: UILabel!
    @IBOutlet weak var lblAwayname: UILabel!
    @IBOutlet weak var lblListChanel: UILabel!
    @IBOutlet weak var lblHomegoal: UILabel!
    @IBOutlet weak var lblAwayGoal: UILabel!
    var match:MatchTVOBJ?{
        didSet {
            for matchUpdate:MatchUpdateOBJ in L3sAppDelegate.arrayUpdate {
                if match?.id == matchUpdate.match_id {
                    match!.status = matchUpdate.status
                    match!.home_goal = matchUpdate.home_goal
                    match!.away_goal = matchUpdate.away_goal
                    match!.home_goalH1 = matchUpdate.home_goalH1
                    match!.away_goalH1 = matchUpdate.away_goalH1
                    
                }
            }
            let currentDate = Date()
            let currentDateInterval: TimeInterval = currentDate.timeIntervalSinceNow
            let doubleCurrent = Double(NSNumber(value: currentDateInterval as Double))
            let matchTime = Double(match!.time_start)
            if matchTime > doubleCurrent {
                let time = DateManager.shareManager.dateToString(match!.time_start, format: "HH:mm")
                let date = DateManager.shareManager.dateToString(match!.time_start, format: "dd/MM")
                lblStatus.text = String(format: "%@\n%@", date, time)
            }else{
                lblStatus.text = match!.status
            }

                lblHomeName.text = match!.home_club_name
                lblAwayname.text = match!.away_club_name
            if matchTime > Date().timeIntervalSince1970 {
                lblHomegoal.text = "?"
                lblAwayGoal.text = "?"
            } else {
                lblHomegoal.text = match!.home_goal
                lblAwayGoal.text = match!.away_goal
            }
            
        }
    }
    override func awakeFromNib() {
        lblStatus.layer.cornerRadius = 5
        lblStatus.clipsToBounds = true
    }
}
