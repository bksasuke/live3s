//
//  L3sMatchDetailViewController.swift
//  Live3s
//
//  Created by phuc on 12/10/15.
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


class L3sMatchDetailViewController: L3sViewController {
    
    
    // header
    @IBOutlet weak var homeClubAvatarImage: UIImageView!
    @IBOutlet weak var homeClubNameLabel: UILabel!
    @IBOutlet weak var awayClubAvatarImage: UIImageView!
    @IBOutlet weak var awayClubHomeLabel: UILabel!
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var currentScorelabel: UILabel!
    @IBOutlet weak var halfTimeLabel: UILabel!
    @IBOutlet weak var memoLable: UILabel!
    
    @IBOutlet weak var headerScrollView: UIScrollView!
    /// content view
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var widthContentSize: NSLayoutConstraint!
    fileprivate var updateTimer: Timer!
    fileprivate var isReloading = false {
        didSet {
            if isReloading {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }
    var isSetUpData = true
    fileprivate var thongtinTableView: L3sMatchTableView!
    fileprivate var dienBienTableView: L3sMatchStatsView!
    fileprivate var thongkeTableView: L3sMatchStaticsView!
    fileprivate var lineUpTableView: L3sMatchLineUpView!
    fileprivate var xepHangTableView: L3sMatchRankingView!
    fileprivate var settingTableView: L3sSettingView!
    fileprivate var headerButton = [L3sMatchDetailHeaderButton]()
    var match: MatchModule!
    var matchModel:MatchModle!
    var bannerView: GADBannerView?
    var interstitial: GADInterstitial!
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(L3sMatchDetailViewController.getDataFromServer), userInfo: nil, repeats: true)
        RunLoop.current.add(updateTimer, forMode: RunLoopMode.defaultRunLoopMode)
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Detail Match")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        NotificationCenter.default.addObserver(self, selector: #selector(L3sMatchDetailViewController.updateDataTable), name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if self.isSetUpData{
            LoadingView.sharedInstance.showLoadingView(view)
            createContentView()
            setupHeader()
            self.addAvertisingFull()
            
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        updateTimer.invalidate()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
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
    func updateDataTable() {
        if match != nil {
             currentScorelabel.text = "\(match.home_goal) - \(match.away_goal)"
            for updateOBJ in L3sAppDelegate.arrayUpdate {
                if match.id == updateOBJ.match_id {
                    match.status = updateOBJ.status
                    match.home_goal = updateOBJ.home_goal
                    match.away_goal = updateOBJ.away_goal
                    match.home_goalH1 = updateOBJ.home_goalH1 ?? "0"
                    match.away_goalH1 = updateOBJ.away_goalH1 ?? "0"
                }
                
            }
            //Chưa đá
            if match.is_finish == "2" {
                currentTimeLabel.isHidden = false
                if match.time_start > Date().timeIntervalSince1970 {
                    currentScorelabel.text = "? - ?"
                    let time = DateManager.shareManager.dateToString(match!.time_start, format: "HH:mm")
                    currentTimeLabel.text = time
                    halfTimeLabel.isHidden = true
                }else{
                    halfTimeLabel.isHidden = false
                    if match.status  != ""{
                        currentTimeLabel.text = match.status
                    }else {
                        currentTimeLabel.text = "Live"
                    }
                    let h1 = match.time_start + 2700
                    if h1 <= Date().timeIntervalSince1970{
                        if match.home_goalH1 != "" && match.away_goalH1 != ""{
                            halfTimeLabel.text =     "(HT: \(match.home_goalH1) - \(match.away_goalH1))"
                              halfTimeLabel.isHidden = false
                        }else{
                            halfTimeLabel.isHidden = true
                        }
                        
                    }else{
                        halfTimeLabel.isHidden = true
                    }
                    currentScorelabel.text = "\(match.home_goal) - \(match.away_goal)"
                }
                
            // Đã xong rồi
            }else{
                halfTimeLabel.isHidden = false
                currentTimeLabel.isHidden = true
                currentScorelabel.text = "\(match.home_goal) - \(match.away_goal)"
                if match.home_goalH1 != "" && match.away_goalH1 != ""{
                    halfTimeLabel.text =     "(HT: \(match.home_goalH1) - \(match.away_goalH1))"
                    halfTimeLabel.isHidden = false
                }else{
                    halfTimeLabel.isHidden = true
                }
                
            }
            memoLable.text = match.memo ?? ""
        }else{
             currentScorelabel.text = "\(matchModel.home_goal) - \(matchModel.away_goal)"
            for updateOBJ in L3sAppDelegate.arrayUpdate {
                if matchModel.id == updateOBJ.match_id {
                    matchModel.status = updateOBJ.status
                    matchModel.home_goal = updateOBJ.home_goal
                    matchModel.away_goal = updateOBJ.away_goal
                    matchModel.home_goalH1 = updateOBJ.home_goalH1 ?? "0"
                    matchModel.away_goalH1 = updateOBJ.away_goalH1 ?? "0"
                }
                
            }
            //Chưa đá
            if matchModel.isFinish == "2" {
                currentTimeLabel.isHidden = false
                if Double(matchModel.time_start!) > Date().timeIntervalSince1970 {
                    currentScorelabel.text = "? - ?"
                    let time = DateManager.shareManager.dateToString(Double(matchModel.time_start!), format: "HH:mm")
                    currentTimeLabel.text = time
                    halfTimeLabel.isHidden = true
                }else{
                    halfTimeLabel.isHidden = false
                    if matchModel.status  != ""{
                        currentTimeLabel.text = matchModel.status
                    }else {
                        currentTimeLabel.text = "Live"
                    }
                    let h1 = Double(matchModel.time_start!) + 2700
                    if h1 <= Date().timeIntervalSince1970{
                        if matchModel.home_goalH1 != "" && matchModel.away_goalH1 != ""{
                            halfTimeLabel.text =     "(HT: \(matchModel.home_goalH1) - \(matchModel.away_goalH1))"
                              halfTimeLabel.isHidden = false
                        }else{
                            halfTimeLabel.isHidden = true
                        }
                    }else{
                        halfTimeLabel.isHidden = true
                    }
                    currentScorelabel.text = "\(matchModel.home_goal) - \(matchModel.away_goal)"
                    
                    
                }
                
                // Đã xong rồi
            }else{
                halfTimeLabel.isHidden = false
                currentTimeLabel.isHidden = true
                currentScorelabel.text = "\(matchModel.home_goal) - \(matchModel.away_goal)"
                if matchModel.home_goalH1 != "" && matchModel.away_goalH1 != ""{
                    halfTimeLabel.text =     "(HT: \(matchModel.home_goalH1) - \(matchModel.away_goalH1))"
                    halfTimeLabel.isHidden = false
                }else{
                    halfTimeLabel.isHidden = true
                }
                
            }
            memoLable.text = matchModel.memo ?? ""

   
        }
        
    }
    
    func createContentView() {
        contentView.backgroundColor = HEADER_BACKGROUND_COLOR
        let frame = contentView.bounds
        thongtinTableView = L3sMatchTableView(frame: frame, style: .plain)
        thongtinTableView.dataSource = self
        thongtinTableView.delegate = self
        contentView.addSubview(thongtinTableView)
        // line up 
        lineUpTableView = L3sMatchLineUpView(frame: frame)
        lineUpTableView.isHidden = true
        contentView.addSubview(lineUpTableView)
        // dien bien tran dau
        dienBienTableView = L3sMatchStatsView(frame: frame)
        dienBienTableView.isHidden = true
        contentView.addSubview(dienBienTableView)
        // ranking
        xepHangTableView = L3sMatchRankingView(frame: frame)
        xepHangTableView.isHidden = true
        contentView.addSubview(xepHangTableView)
        // thong ke
        thongkeTableView = L3sMatchStaticsView(frame: frame)
        thongkeTableView.viewcontroller = self
        thongkeTableView.isHidden = true
        contentView.addSubview(thongkeTableView)
        // setting
        settingTableView = L3sSettingView(frame: frame)
        settingTableView.isHidden = true
        
        contentView.addSubview(settingTableView)
        if match != nil {
            lineUpTableView.setSegmentedSection(match.home_club_name, away: match.away_club_name)
            thongkeTableView.homeName = match.home_club_name
            thongkeTableView.awayName = match.away_club_name
            
        }else {
            if let matchMO = matchModel {
                lineUpTableView.setSegmentedSection(matchMO.home_club_name!, away: matchMO.away_club_name!)
                thongkeTableView.homeName = matchMO.home_club_name
                thongkeTableView.awayName = matchMO.away_club_name
            }
           
        
        }
        
    }
    
    func setupHeader() {
        let headerFrame = headerScrollView.frame
        let width = headerFrame.width / 5
        let contentsize = CGSize(width: width * 5, height: headerFrame.height)
        headerScrollView.contentSize = contentsize
        for index in 0..<5 {
            let btnframe = CGRect(x: CGFloat(index) * width, y: 0, width: width, height: 70)
            let button = L3sMatchDetailHeaderButton(frame: btnframe)
            button.delegate = self
            button.tag = index
            button.selected = false
            headerScrollView.addSubview(button)
            headerButton.append(button)
            
            switch index {
            case 0:
                button.titleText = AL0604.localization(LanguageKey.detail)
                button.iconImage = UIImage(named: "icon_football.png")
                button.iconSelected = UIImage(named: "icon_football_white.png")
                break
            case 1:
                button.titleText = AL0604.localization(LanguageKey.line_up)
                button.iconImage = UIImage(named: "icon_team.png")
                button.iconSelected = UIImage(named: "icon_team_white.png")
                break
            case 2:
                button.titleText = AL0604.localization(LanguageKey.match_stats)
                button.iconImage = UIImage(named: "icon_play.png")
                button.iconSelected = UIImage(named: "icon_stat_white.png")
                break
            case 3:
                button.titleText = AL0604.localization(LanguageKey.alert)
                button.iconImage = UIImage(named: "icon_notify_gray.png")
                button.iconSelected = UIImage(named: "icon_notify.png")
                break
            case 4:
                button.titleText = AL0604.localization(LanguageKey.form)
                button.iconImage = UIImage(named: "icon_standing.png")
                button.iconSelected = UIImage(named: "icon_analytic_white.png")
                break
            case 4:
                button.titleText = AL0604.localization(LanguageKey.table)
                button.iconImage = UIImage(named: "icon_cup.png")
                button.iconSelected = UIImage(named: "icon_cup_white.png")
                break
                
            default: break
            }
        }
        headerButton.first?.selected = true
        getDataFromServer()
        
    }
    func getDataFromServer(){
        if match != nil {
            homeClubNameLabel.text = match.home_club_name
            awayClubHomeLabel.text = match.away_club_name
             memoLable.text = match.memo ?? ""
            // chua bat dau
            currentScorelabel.layer.cornerRadius = 5
            currentScorelabel.clipsToBounds = true
            
            if match.is_finish == "1"{
                currentTimeLabel.text = AL0604.localization(LanguageKey.ft)
                currentScorelabel.text = "\(match.home_goal) - \(match.away_goal)"
                if match.home_goalH1 != "" && match.away_goalH1 != ""{
                    halfTimeLabel.text =     "(HT: \(match.home_goalH1) - \(match.away_goalH1))"
                    halfTimeLabel.isHidden = false
                }else{
                    halfTimeLabel.isHidden = true
                }
                reloadDetailcolum1(true)
                reloadDetailcolum3(true)
            }else {
                if match.time_start > Date().timeIntervalSince1970 {
                    currentTimeLabel.text = DateManager.shareManager.dateToString(match.time_start, format: "HH:mm")
                    currentScorelabel.text = "?-?"
                    halfTimeLabel.text = ""
                    reloadDetailcolum1(false)
                    reloadDetailcolum3(false)
                } else {
                    // dang dien ra
                    if match.status != "" {
                        currentTimeLabel.text = match.status
                    }else {
                        currentTimeLabel.text = "Live"
                    }
                    let h1 = match.time_start + 2700
                    if h1 <= Date().timeIntervalSince1970{
                        if match.home_goalH1 != "" && match.away_goalH1 != ""{
                            halfTimeLabel.text =     "(HT: \(match.home_goalH1) - \(match.away_goalH1))"
                             halfTimeLabel.isHidden = false
                        }else{
                            halfTimeLabel.isHidden = true
                        }
                    }else{
                        halfTimeLabel.isHidden = true
                    }
                    currentScorelabel.text = "\(match.home_goal) - \(match.away_goal)"
                    halfTimeLabel.text = "(HT \(match.home_goalH1) - \(match.away_goalH1))"
                    reloadDetailcolum3(false)
                    reloadDetailcolum1(false)
                }
            }
            
            reloadRanking()
            currentScorelabel.layer.cornerRadius = 4
            if Date().timeIntervalSince1970 - (10 * 86400) <= match.time_start {
                reloadMatchStatic(false)
            } else {
                reloadMatchStatic(true)
            }
            if match.is_postponed == "1" {
                currentTimeLabel.text = AL0604.localization(LanguageKey.postpone)
            }
            
        }else{
            homeClubNameLabel.text = matchModel.home_club_name
            awayClubHomeLabel.text = matchModel.away_club_name
            memoLable.text = matchModel.memo ?? ""
            // chua bat dau
            currentScorelabel.layer.cornerRadius = 5
            currentScorelabel.clipsToBounds = true
            
            if matchModel.isFinish == 1{
                currentTimeLabel.text = AL0604.localization(LanguageKey.ft)
                currentScorelabel.text = "\(matchModel.home_goal!) - \(matchModel.away_goal!)"
                if matchModel.home_goalH1 != "" && matchModel.away_goalH1 != ""{
                    halfTimeLabel.text =     "(HT: \(matchModel.home_goalH1) - \(matchModel.away_goalH1))"
                    halfTimeLabel.isHidden = false
                }else{
                    halfTimeLabel.isHidden = true
                }
                reloadDetailcolum1(true)
                reloadDetailcolum3(true)
            }else {
                if Double(matchModel.time_start!) > Date().timeIntervalSince1970 {
                    currentTimeLabel.text = DateManager.shareManager.dateToString(Double(matchModel.time_start!), format: "HH:mm")
                    currentScorelabel.text = "?-?"
                    halfTimeLabel.text = ""
                    LoadingView.sharedInstance.hideLoadingView()
                    LoadingView.sharedInstance.showTextInView(contentView, text: AL0604.localization(LanguageKey.no_data))
                    reloadDetailcolum3(false)
                } else {
                    // dang dien ra
                    if let status = matchModel.status {
                        currentTimeLabel.text = status
                    }else {
                        currentTimeLabel.text = "Live"
                    }
                    let h1 = Double(matchModel.time_start!) + 2700
                    if h1 <= Date().timeIntervalSince1970{
                        if matchModel.home_goalH1 != "" && matchModel.away_goalH1 != ""{
                            halfTimeLabel.text =     "(HT: \(matchModel.home_goalH1) - \(matchModel.away_goalH1))"
                            halfTimeLabel.isHidden = false
                        }else{
                            halfTimeLabel.isHidden = true
                        }
                    }else{
                        halfTimeLabel.isHidden = true
                    }
                    currentScorelabel.text = "\(matchModel.home_goal!) - \(matchModel.away_goal!)"
                    halfTimeLabel.text =     "(HT: \(matchModel.home_goalH1!) - \(matchModel.away_goalH1!))"
                    reloadDetailcolum3(false)
                    reloadDetailcolum1(false)
                }
            }
            
            reloadRanking()
            currentScorelabel.layer.cornerRadius = 4
            if Date().timeIntervalSince1970 - (10 * 86400) <= Double(matchModel.time_start!) {
                reloadMatchStatic(false)
            } else {
                reloadMatchStatic(true)
            }
            if matchModel.isPosponse == 1{
                currentTimeLabel.text = AL0604.localization(LanguageKey.postpone)
            }
            
        }

    }
    /**
     Lay thong tin dien bien tran dau: thay nguoi, ghi ban,...
     
     - parameter isFinish: tran dau da ket thuc hay chua
     */
    func reloadDetailcolum1(_ isFinish: Bool) {
        var strID = ""
        if match != nil{
            strID = match.id
        }else{
            strID = matchModel.id!
            
        }
        NetworkService.getMatchDetailEvent(strID, isFinish: isFinish) { [unowned self](eventList, error) -> Void in
            self.isReloading = false
            if error == nil {
                guard let eventList = eventList else {
                    return
                }
                    self.thongtinTableView.adatasource = eventList
//                    if eventList.count > 0 {
//                        self.currentScorelabel.text = eventList.last?.score
//                    }
//                
                
            }else{
                
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(self.contentView, text:AL0604.localization(LanguageKey.no_data))
            }
            
        }
    }
    /**
     Lay thong tin doi hinh va stats cua tran dau
     
     - parameter isFinish: tran dau da ket thuc hay chua
     */
    func reloadDetailcolum3(_ isFinish: Bool) {
        var strID = ""
        var timeStart = 0.0
        if match != nil{
            strID = match.id
            timeStart = match.time_start
        }else {
            strID = matchModel.id!
            timeStart = Double(matchModel.time_start!)
        }
        NetworkService.getFormationAndStats(strID, timeStart: timeStart, isFinish: isFinish) { [unowned self](home_formation, away_formation, stats, error) -> () in
            self.isReloading = false
            if error == nil {
                guard let statList = stats,
                    let homeDS = home_formation,
                    let awayDS = away_formation else {
                    return
                }
                self.dienBienTableView.dataSource = statList
                self.lineUpTableView.homeDataSource = homeDS
                self.lineUpTableView.awaySource = awayDS
                self.thongtinTableView.reloadData()

            }
            
        }
    }
    
    func reloadRanking() {
        var strID = ""
        if match != nil {
            strID = match.season_id
        }else{
            strID = matchModel.season_id!
        }
        NetworkService.getRankVDQG(strID,completion:{ (league, roundType ,error) -> () in
            if error == nil {
                self.xepHangTableView.roundType = roundType
                if roundType == "1" {
                    
                    guard let league = league as? LeagueRankRound else {
                        return
                    }
                    self.xepHangTableView.leageRankRounds = league
                    self.xepHangTableView.sessionRankRounds = self.xepHangTableView.leageRankRounds!.arraySession
                    self.xepHangTableView.sessionDisplay = self.xepHangTableView.sessionRankRounds?.first
                    self.xepHangTableView.teamRankRounds = self.xepHangTableView.sessionDisplay?.teams
                }else{
                    guard let league = league as? LeagueRankCup else {
                        return
                    }
                    self.xepHangTableView.leageRankCup = league
                    self.xepHangTableView.sessionRankCups = self.xepHangTableView.leageRankCup!.arraySession
                    self.xepHangTableView.sessionCupDisplay = self.xepHangTableView.sessionRankCups?.first
                    self.xepHangTableView.roundRankCup = self.xepHangTableView.sessionCupDisplay!.rounds
                    self.xepHangTableView.roundCupDiplay = self.xepHangTableView.roundRankCup?.last
                    
                    if self.xepHangTableView.leageRankCup?.current_ranking == "match"{
                        self.xepHangTableView.isTypeMatch = true
                        self.xepHangTableView.isTypeRound = false
                        self.xepHangTableView.isTypeGroup = false
                        self.xepHangTableView.matchRankCups = self.xepHangTableView.leageRankCup?.arrayMatch
                    }else if self.xepHangTableView.leageRankCup?.current_ranking == "group"{
                        self.xepHangTableView.isTypeMatch = false
                        self.xepHangTableView.isTypeRound = false
                        self.xepHangTableView.isTypeGroup = true
                        self.xepHangTableView.groupRankCups = self.xepHangTableView.leageRankCup?.arrayGroup
                    }else{
                        self.xepHangTableView.isTypeMatch = false
                        self.xepHangTableView.isTypeRound = true
                        self.xepHangTableView.isTypeGroup = false
                        self.xepHangTableView.teamRankCups = self.xepHangTableView.leageRankCup?.arrayTeam
                        
                    }
                    
                }
                
            } else {
                
            }
        })

    }
    
    func reloadMatchStatic(_ isPlay: Bool) {
        var strID = ""
        if match != nil {
            strID = match.id
        }else{
            strID = matchModel.id!
        }
        NetworkService.getMatchStatics(strID, isPlaying: isPlay) { [unowned self](staticList, error) -> Void in
            if error == nil {
                guard let staticList = staticList else {
                    return
                }
                self.thongkeTableView.homeDataSource = staticList.0
                self.thongkeTableView.awayDataSource = staticList.1
                self.thongkeTableView.h2hataSource = staticList.2
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
extension L3sMatchDetailViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isSetUpData = false
        }
        
    }
}
extension L3sMatchDetailViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // section detail
        switch section {
        case 0:
            if thongtinTableView.adatasource != nil  {
                return thongtinTableView.adatasource.count
            } else {
                return 0
            }
        // section stat
        case 1:
            if dienBienTableView != nil && dienBienTableView.dataSource != nil  {
                return dienBienTableView.dataSource!.count
            } else {
                return 0
            }
        default: return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
            
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "L3sMatchTableViewCell") as! L3sMatchDetailTableViewCell
            let matchDetail = thongtinTableView.adatasource[(indexPath as NSIndexPath).row]
            if (indexPath as NSIndexPath).row % 2 == 0{
                cell.backgroundColor = UIColor.white
                
            }else{
                cell.backgroundColor = UIColor(rgba: "#f5f5f5")
            }
            cell.infor = matchDetail
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "L3sStatTableViewCell") as! L3sStatNewTableViewCell
            let stat = dienBienTableView.dataSource![(indexPath as NSIndexPath).row]
            if (indexPath as NSIndexPath).row % 2 == 0{
                cell.backgroundColor = UIColor.white
                
            }else{
                cell.backgroundColor = UIColor(rgba: "#f5f5f5")
            }
            cell.stat = stat
            return cell
        default: return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.defaultHeightForHeader()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10
        }
        return tableView.defaultHeightForHeader()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section > 0 {
            return 0
        }
        return tableView.defaultHeightForHeader()
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var timeStart = 0.0
        if match != nil {
            timeStart = match.time_start
        }else{
            timeStart = Double(matchModel.time_start!)
        }
        if section > 0 || timeStart > Date().timeIntervalSince1970  {
            return nil
        }
        
        let viewFrame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.defaultHeightForHeader())
        let view = UIImageView(frame: viewFrame)
        view.image = UIImage(named: "matchDetailFooter.png")
        view.backgroundColor = UIColor(rgba: "#E7E7E7")
        view.contentMode = .scaleAspectFit
        return view
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let viewFrame = CGRect(x: 0, y: 0, width: tableView.frame.size.width , height: 10)
            let view = UILabel(frame: viewFrame)
            view.backgroundColor = UIColor.white
            return view
            
        case 1:
            return tableView.defaultViewForHeader(LanguageKey.match_stats)
        default: return UIView()
        }

    }
    
}

extension L3sMatchDetailViewController: L3sMatchDetailHeaderButtonDelegate {
    func reloadButtonState() {
        for button in headerButton {
            button.selected = false
        }
    }
    
    func reloadViewSection() {
        thongtinTableView.isHidden = true
        dienBienTableView.isHidden = true
        lineUpTableView.isHidden = true
        xepHangTableView.isHidden = true
        thongkeTableView.isHidden = true
        settingTableView.isHidden = true
    }
    func didTapButton(_ button: L3sMatchDetailHeaderButton) {
        reloadButtonState()
        reloadViewSection()
        button.selected = true
        // change section
        var timeStart = 0.0
        if match != nil {
            timeStart = match.time_start
        }else {
            timeStart = Double(matchModel.time_start!)
        }
       
        switch button.tag {
        case 0:
            thongtinTableView.isHidden = false
            if thongtinTableView.adatasource?.count == 0 {
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(contentView, text:AL0604.localization(LanguageKey.no_data))
            }else{
                LoadingView.sharedInstance.hideText()
            }

            break
        case 2:
            dienBienTableView.isHidden = false
            if dienBienTableView.dataSource?.count == 0 {
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(contentView, text: AL0604.localization(LanguageKey.no_data))
            }else{
                 LoadingView.sharedInstance.hideText()
            }
            break
        case 1:
            lineUpTableView.isHidden = false
            if lineUpTableView.homeDataSource.count == 0 && lineUpTableView.awaySource.count == 0{
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(contentView, text: AL0604.localization(LanguageKey.no_data))
            }else{
                LoadingView.sharedInstance.hideText()
            }
            break
        case 4:
            thongkeTableView.isHidden = false
            if thongkeTableView.homeDataSource!.count == 0 && thongkeTableView.awayDataSource!.count == 0 && thongkeTableView.h2hataSource?.count == 0{
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(contentView, text:AL0604.localization(LanguageKey.no_data))
            }else{
                LoadingView.sharedInstance.hideText()
            }
            break
        case 5:
            xepHangTableView.isHidden = false
            if xepHangTableView.teamRankCups?.count == 0 && xepHangTableView.groupRankCups?.count == 0 && xepHangTableView.matchRankCups?.count == 0 {
                LoadingView.sharedInstance.hideLoadingView()
                LoadingView.sharedInstance.showTextInView(contentView, text:AL0604.localization(LanguageKey.no_data))
            }else {
                LoadingView.sharedInstance.hideText()
            }
            break
        case 3:
           
            if match != nil {
                //Chưa đá
                if match.is_finish == "2" {
                     settingTableView.isHidden = false
                    settingTableView.matchID = match.id
                    settingTableView.leagueID = match.season_id
                    LoadingView.sharedInstance.hideText()
                    // Đã xong rồi
                }else{
                     settingTableView.isHidden = true
                    LoadingView.sharedInstance.hideLoadingView()
                    LoadingView.sharedInstance.showTextInView(contentView, text:AL0604.localization(LanguageKey.match_finish))
                }
                
            }else{
                //Chưa đá
                let finish = String("\(matchModel.isFinish!)")
                if finish == "2" {
                     settingTableView.isHidden = false
                    LoadingView.sharedInstance.hideText()
                    // Đã xong rồi
                }else{
                     settingTableView.isHidden = true
                    LoadingView.sharedInstance.hideLoadingView()
                    LoadingView.sharedInstance.showTextInView(contentView, text:AL0604.localization(LanguageKey.match_finish))
                }
                
                
            }

            break
        default:
            break
        }
    }
}
extension String {
    func removePHPSpaceCode() -> String {
        return replacingOccurrences(of: "&nbsp;", with: " ")
    }
}
