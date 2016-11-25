//
//  DetailStatisticViewController.swift
//  Live3s
//
//  Created by codelover2 on 17/12/2015.
//  Copyright © Năm 2015 com.phucnguyen. All rights reserved.
//

import Foundation
import GoogleMobileAds
import UIKit
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



class DetailStatisticViewController: UIViewController{
    
    // Info Title
    @IBOutlet weak var flagImage: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var sessionLabel: UILabel!
    @IBOutlet weak var selectSessionButton: UIButton!
    //  Info Action
        //View Rank
    @IBOutlet weak var viewRank: UIView!
    @IBOutlet weak var titleRank: UILabel!
    @IBOutlet weak var imageRank: UIImageView!
        //View Match
    @IBOutlet weak var viewMatch: UIView!
    @IBOutlet weak var titleMatch: UILabel!
    @IBOutlet weak var imageMatch: UIImageView!
        //View Index
    @IBOutlet weak var viewIndex: UIView!
    @IBOutlet weak var titleIndex: UILabel!
    @IBOutlet weak var imageIndex: UIImageView!


    // Info Detail
        // Detail Rank
    @IBOutlet weak var viewDetailRank: UIView!
    
    // View Contain RoundPlay
    @IBOutlet weak var viewRoundPlay: UIView!
    @IBOutlet weak var lblDisplayRoundPlay: UILabel!
    
    
    @IBOutlet weak var tableView: UITableView!
    internal var roundType: String?
    internal var leagueID: String?
    internal var urlLogo: String?
    fileprivate var myTableView: UITableView?
    fileprivate var myView: UIView?
    fileprivate var arraySession: [String]?
    fileprivate var arrayRound: [String]?
    fileprivate var isSession: Bool = true

    
    // Local variable
    var interstitial: GADInterstitial!
    internal var isRank = true
    internal var isMatch = false
    internal var isIndex = false
    internal var isAnalytic = false
    fileprivate var isTypeRound = false
    fileprivate var isTypeGroup = false
    fileprivate var isTypeMatch = false
    fileprivate var isReloadingData = false {
        didSet {
            if isReloadingData {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }
    // Round Type == 1
    fileprivate var leageRankRounds: LeagueRankRound?
    fileprivate var sessionRankRounds: [SessionRankRound]?
    fileprivate var sessionDisplay: SessionRankRound?
    fileprivate var teamRankRounds: [TeamRankRound]? {
        didSet {
            setUpUI()
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    // Round Type == 2
    fileprivate var leageRankCup: LeagueRankCup?
    fileprivate var roundRankCup: [RoundOBJ]?
    fileprivate var roundCupDiplay: RoundOBJ?
    fileprivate var sessionRankCups: [SessionRankCup]?
    fileprivate var sessionCupDisplay: SessionRankCup?
    fileprivate var teamRankCups: [TeamOBJ]? {
        didSet {
            setUpUI()
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    fileprivate var groupRankCups: [GroupOBJ]? {
        didSet {
            setUpUI()
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    fileprivate var matchRankCups: [MatchOBJ]? {
        didSet {
            setUpUI()
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    fileprivate var fixtures: [StaticMatchModule]? {
        didSet {
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    
    fileprivate var arrayResult: [StaticMatchModule]? {
        didSet {
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }
    
    fileprivate var topScoreResult: [TopScoreStandingModule]? {
        didSet {
            self.tableView.reloadData()
            self.isReloadingData = false
        }
    }

    var bannerView: GADBannerView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
         tableView.register(UINib(nibName: "BXHRoundCell", bundle: nil), forCellReuseIdentifier: "RoundCell")
        tableView.register(UINib(nibName: "BXHMatchCupCell", bundle: nil), forCellReuseIdentifier: "MatchCupCell")
        tableView.register(UINib(nibName: "BXHGroupCupCell", bundle: nil), forCellReuseIdentifier: "GroupCupCell")
        tableView.register(UINib(nibName: "MatchCell", bundle: nil), forCellReuseIdentifier: "MatchCell")
        tableView.register(UINib(nibName: "L3sTopScoreCell", bundle: nil), forCellReuseIdentifier: "L3sTopScoreCell")
        self.addAvertisingFull()
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         LoadingView.sharedInstance.showLoadingView(view)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        getDataFromServer(self.leagueID!)
        self.getFixtures(self.leagueID!)
        self.getResult(self.leagueID!)
        self.getTopScore(self.leagueID!)
        self.viewRoundPlay.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(DetailStatisticViewController.updateDataTable), name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)


       
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func getDataFromServer(_ leagueID : String) {
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getRankVDQG(leagueID,completion:{ (league, roundType ,error) -> () in
            if error == nil {
                self.roundType = roundType
                if roundType == "1" {
                    
                    guard let league = league as? LeagueRankRound else {
                        return
                    }
                    self.leageRankRounds = league
                    self.sessionRankRounds = self.leageRankRounds!.arraySession
                    self.sessionDisplay = self.sessionRankRounds?.first
                    self.teamRankRounds = self.sessionDisplay?.teams
                }else{
                    guard let league = league as? LeagueRankCup else {
                        return
                    }
                    self.leageRankCup = league
                    self.sessionRankCups = self.leageRankCup!.arraySession
                    self.sessionCupDisplay = self.sessionRankCups?.first
                    self.roundRankCup = self.sessionCupDisplay!.rounds
                    self.roundCupDiplay = self.roundRankCup?.last
                    
                    if self.leageRankCup?.current_ranking == "match"{
                        self.isTypeMatch = true
                        self.isTypeRound = false
                        self.isTypeGroup = false
                        self.matchRankCups = self.leageRankCup?.arrayMatch
                        
                    }else if self.leageRankCup?.current_ranking == "group"{
                        self.isTypeMatch = false
                        self.isTypeRound = false
                        self.isTypeGroup = true
                        self.groupRankCups = self.leageRankCup?.arrayGroup
                      

                    }else{
                        self.isTypeMatch = false
                        self.isTypeRound = true
                        self.isTypeGroup = false

                        self.teamRankCups = self.leageRankCup?.arrayTeam
                      
                    }
                    self.lblDisplayRoundPlay.text = self.leageRankCup?.nameRound

                }
                
            } else {
                let alert = UIAlertController(title:AL0604.localization(LanguageKey.alert), message: LanguageKey.no_data, preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.cancel), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.isReloadingData = false
            }
        })
        
        
    }
    func getBXHFolowRound(_ typeRank: String, leagueID:String, sesionID: String, roundID: String){
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getBXHFollowRound(typeRank, league_id: leagueID, session_id: sesionID, round_id: roundID) { (leagues, error) -> () in
            if error == nil {
                if leagues == nil {
                    let alert = UIAlertController(title: AL0604.localization(LanguageKey.alert), message: AL0604.localization(LanguageKey.no_data), preferredStyle: UIAlertControllerStyle.alert)
                    alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.cancel), style: UIAlertActionStyle.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    self.tableView.isHidden = true
                    self.isReloadingData = false
                }else{
                    if typeRank == "v1_group_ranking" {
                        self.tableView.isHidden = false
                        if let groups = leagues as? [GroupOBJ]{
                            self.groupRankCups = groups
                            self.leageRankCup?.arrayGroup = groups
                        }
                    }else if typeRank == "v1_round_ranking" {
                        if let teams = leagues as? [TeamOBJ]{
                            self.teamRankCups = teams
                            self.leageRankCup?.arrayTeam = teams
                        }
                    }else {
                        if let matchs = leagues as? [MatchOBJ] {
                            self.matchRankCups = matchs
                            self.leageRankCup?.arrayMatch = matchs
                        }
                    }
                    self.tableView.isHidden = false
                }
            }else{
                let alert = UIAlertController(title: AL0604.localization(LanguageKey.alert), message: AL0604.localization(LanguageKey.no_data), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.cancel), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                self.isReloadingData = false

            }
        }
    }
    func getFixtures(_ leagueID: String){
    
            NetworkService.getFixturesOfLeague(leagueID, completionBlock: { (staticMatchModule, error) -> Void in
                if error == nil {
                        self.fixtures = staticMatchModule;
                }
            })

        
     }

    func getResult(_ leagueID: String){
        
        NetworkService.getResultOfLeague(leagueID, completionBlock: { (staticMatchModule, error) -> Void in
            if error == nil {
                self.arrayResult = staticMatchModule;
            }
        })
        
        
    }
    func getTopScore(_ leagueID: String) {
        NetworkService.getTopScoreStanding(leagueID) { [unowned self](topScores, error) -> () in
            if error == nil {
                self.topScoreResult = topScores
            }
        }
    }
    
    func updateDataTable(){
        self.tableView .reloadData()
    }
    
    func setUpUI(){
        if let urlString: String = self.urlLogo {
            let url = URL(string: urlString)!
            self.flagImage.af_setImageWithURL(url)
        }
       
        if self.leageRankRounds != nil{
            self.nameLable.text = self.leageRankRounds?.name
            self.sessionLabel.text = self.sessionDisplay?.season_name
            self.viewRoundPlay.isHidden = true
        }else{
            self.nameLable.text = self.leageRankCup?.name
            self.sessionLabel.text = self.sessionCupDisplay?.season_name
            self.viewRoundPlay.isHidden = false
            
            
        }
        
        self.titleRank.text = AL0604.localization(LanguageKey.rank)
        self.titleMatch.text = AL0604.localization(LanguageKey.match)
        self.titleIndex.text = AL0604.localization(LanguageKey.top_scorers)
        
        if isRank{
            self.viewRank.backgroundColor = UIColor(red: 89.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1)
            self.viewMatch.backgroundColor = UIColor.white
            self.viewIndex.backgroundColor = UIColor.white
            self.titleRank.textColor = UIColor.white
            self.titleMatch.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            self.titleIndex.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            self.imageRank.image = UIImage(named:"icon_cup_white.png")
            self.imageMatch.image = UIImage(named:"icon_football.png")
            self.imageIndex.image = UIImage(named:"icon_team.png")
        }else{
            self.viewRank.backgroundColor = UIColor.white
            self.viewMatch.backgroundColor = UIColor.white
            self.viewIndex.backgroundColor = UIColor(red: 89.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1)
            
            self.titleRank.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            self.titleMatch.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            self.titleIndex.textColor = UIColor.white
            
            self.imageRank.image = UIImage(named:"icon_cup.png")
            self.imageMatch.image = UIImage(named:"icon_football.png")
            self.imageIndex.image = UIImage(named:"icon_team_white.png")
        }
      
        

        
    }
//MARK - Action
    @IBAction func actionViewRank(_ sender: AnyObject) {
        self.viewRank.backgroundColor = UIColor(red: 89.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1)
        self.viewMatch.backgroundColor = UIColor.white
        self.viewIndex.backgroundColor = UIColor.white
  
        
        isRank = true
        isMatch = false
        isIndex = false
        isAnalytic = false
        self.tableView.reloadData()
        
        self.titleRank.textColor = UIColor.white
        self.titleMatch.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        self.titleIndex.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)

        
        self.imageRank.image = UIImage(named:"icon_cup_white.png")
        self.imageMatch.image = UIImage(named:"icon_football.png")
        self.imageIndex.image = UIImage(named:"icon_team.png")
        
    }
    
    @IBAction func actionViewMatch(_ sender: AnyObject) {
        if !isMatch {
            
            self.viewRank.backgroundColor = UIColor.white
            self.viewMatch.backgroundColor = UIColor(red: 89.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1)
            self.viewIndex.backgroundColor = UIColor.white
            
            isRank = false
            isMatch = true
            isIndex = false
            isAnalytic = false
            self.tableView.reloadData()
            
            self.titleRank.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            self.titleMatch.textColor = UIColor.white
            self.titleIndex.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
            
            
            self.imageRank.image = UIImage(named:"icon_cup.png")
            self.imageMatch.image = UIImage(named:"icon_football_white.png")
            self.imageIndex.image = UIImage(named:"icon_team.png")
       

        }
        
    }
    @IBAction func actionViewIndex(_ sender: AnyObject) {
        self.viewRank.backgroundColor = UIColor.white
        self.viewMatch.backgroundColor = UIColor.white
        self.viewIndex.backgroundColor = UIColor(red: 89.0/255.0, green: 88.0/255.0, blue: 88.0/255.0, alpha: 1)
       
        
        isRank = false
        isMatch = false
        isIndex = true
        isAnalytic = false
        self.tableView.reloadData()
        
        self.titleRank.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        self.titleMatch.textColor = UIColor(red: 185.0/255.0, green: 185.0/255.0, blue: 185.0/255.0, alpha: 1)
        self.titleIndex.textColor = UIColor.white
        
        self.imageRank.image = UIImage(named:"icon_cup.png")
        self.imageMatch.image = UIImage(named:"icon_football.png")
        self.imageIndex.image = UIImage(named:"icon_team_white.png")
        
        

    }
 
    @IBAction func actionChooseSession(_ sender: AnyObject) {
        let xTB = self.sessionLabel.frame.origin.x - 7
        let yTB = self.sessionLabel.frame.origin.y + self.sessionLabel.frame.size.height
        let wTB = self.sessionLabel.frame.size.width + 10
        let hTB = self.view.frame.size.height/3
        let rect:CGRect = CGRect(x: xTB, y: yTB, width: wTB, height: hTB)
        isSession = true
        self.setupCustomTableView(rect);

    
     
    }
    
    @IBAction func actionChooseRoundPlay(_ sender: AnyObject) {
        let xTB = self.viewRoundPlay.frame.origin.x
        let yTB = self.viewRoundPlay.frame.origin.y + self.viewRoundPlay.frame.size.height
        let wTB = self.viewRoundPlay.frame.size.width
        let hTB = self.view.frame.size.height/3
        let rect:CGRect = CGRect(x: xTB, y: yTB, width: wTB, height: hTB)
        isSession = false
        self.setupCustomTableView(rect);
    }
    
    func setupCustomTableView(_ rectTable: CGRect)
    {
        myView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        myView?.backgroundColor = UIColor.clear
        let tap = UITapGestureRecognizer(target: self, action: #selector(DetailStatisticViewController.hiddenMyView))
        tap.numberOfTapsRequired = 2
        myView?.addGestureRecognizer(tap)
        myTableView = UITableView(frame: rectTable)
        myTableView?.backgroundColor = UIColor.white
        myTableView?.layer.borderColor = UIColor.black.cgColor
        myTableView?.layer.borderWidth = 1
        myTableView?.dataSource = self
        myTableView?.delegate = self
        myTableView?.reloadData()
        myView?.addSubview(myTableView!)
        self.view.addSubview(myView!)
        
    }
    func hiddenMyView(){
        myView?.isHidden = true
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
extension DetailStatisticViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
        }
        
    }
}
//MARK - UITableViewDatasource
extension DetailStatisticViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if tableView == myTableView {
            return 1
        }else{
            // Xem BXH
            if isRank{
                // Giải đấu Quốc Gia
                if self.leageRankRounds != nil{
                    return 1
                    
                    // Giải đấu cúp
                }else{
                    
                    if self.isTypeMatch{
                        return 1
                        
                    }else if self.isTypeGroup{
                        if let countGroup = self.groupRankCups?.count{
                            return countGroup
                        }else{
                            return 0
                        }
                    }else{
                        return 1
                    }
                }
                // Xem Danh Sách Trận
            }else if(isMatch){
                return 2
                
                // Xem Chỉ Số
            }else if(isIndex){
                return 1
                
                // Xem thống kê
            }else{
                return 1
            }

        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == myTableView {
            if isSession {
                if self.roundType == "1" {
                    if let count = self.sessionRankRounds?.count{
                        return count
                    }else{
                        return 0
                    }
                }else{
                    if let count = self.sessionRankCups?.count{
                        return count
                    }else{
                        return 0
                    }
                }

                
            }else{
                if let count = self.roundRankCup?.count{
                    return count
                }else{
                    return 0
                }

            }
        } else {
            // Xem BXH
            if isRank{
                // Giải đấu Quốc Gia
                if self.leageRankRounds != nil{
                    
                    if let countSeason = teamRankRounds?.count{
                        return countSeason
                    }else {
                        return 0
                    }
                    // Giải đấu cúp
                }else{
                    if leageRankCup != nil {
                        if self.isTypeMatch{
                            if let countMatch = self.matchRankCups?.count{
                                return countMatch
                            }else{
                                return 0
                            }
                            
                        }else if self.isTypeGroup{
                            if let groups = self.groupRankCups{
                                let group = groups[section]
                                return group.teams.count
                                
                            }else{
                                return 0
                            }
                        }else{
                            if let countGroup = self.teamRankCups?.count{
                                return countGroup
                            }else{
                                return 0
                            }
                        }
                    }else{
                        return 0
                    }
                    
                }
                
                // Xem Danh Sách Trận
            }else if(isMatch){
                if section == 0{
                    if let count = self.fixtures?.count{
                        return count
                    }else{
                        return 0
                    }

                }else{
                    
                    if let count = self.arrayResult?.count{
                        return count
                    }else{
                        return 0
                    }
                }
                
                // Xem Chỉ Số
            }else if(isIndex){
                
                let count = topScoreResult?.count ?? 0
                return count + 1
                
                // Xem thống kê
            }else{
                return 0
            }
      
        }

    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == myTableView {
            var cell: UITableViewCell?
            if cell == nil {
                cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "CELL")
            }else{
                cell = tableView.dequeueReusableCell(withIdentifier: "CELL")! as UITableViewCell
            }
            cell?.backgroundColor = UIColor.clear
            
            var textDisplay: String = ""
            if isSession {
                    if self.roundType == "1" {
                        if let str: SessionRankRound = self.sessionRankRounds?[(indexPath as NSIndexPath).row]{
                            textDisplay = str.season_name
                        }
                    }else{
                        if let str: SessionRankCup = self.sessionRankCups?[(indexPath as NSIndexPath).row]{
                            textDisplay = str.season_name
                        }
                    }
                }else {
                    if let str:RoundOBJ =  roundRankCup?[(indexPath as NSIndexPath).row]{
                        textDisplay = str.name
                    }
            }
            cell!.textLabel?.text = textDisplay
            cell!.textLabel?.font = UIFont.systemFont(ofSize: 10)
            cell!.textLabel?.textColor = UIColor.black
            cell!.textLabel?.textAlignment = .left
            return cell!
        }else{
            // Xem BXH
            if isRank {
                // Giải đấu Quốc Gia
                
                if self.leageRankRounds != nil {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell") as! BXHRoundCell
                    let teamOBJ:TeamRankRound = teamRankRounds![(indexPath as NSIndexPath).row]
                    cell.lblIndex.text = "\((indexPath as NSIndexPath).row+1)"
                    cell.lblName.text = teamOBJ.football_club_name
                    cell.lblSotran.text = teamOBJ.total_match
                    cell.lblThang.text = teamOBJ.total_win
                    cell.lblHoa.text = teamOBJ.total_draw
                    cell.lblThua.text = teamOBJ.total_lose
                    cell.lblHieuSo.text = teamOBJ.goal
                    cell.lblDiem.text = teamOBJ.point
                    cell.selectionStyle = .none
                    if (indexPath as NSIndexPath).row % 2 == 0{
                        cell.backgroundColor = UIColor.white
                        
                    }else{
                        cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                    }


                    return cell
                    
                    // Giải đấu cúp
                }else{
                    
                    if self.isTypeMatch{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCupCell") as! BXHMatchCupCell

                        if (indexPath as NSIndexPath).row % 2 == 0{
                            cell.backgroundColor = UIColor.white
                            
                        }else{
                            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                        }
                        if let array = self.matchRankCups{
                            
                            let matchOBJ:MatchOBJ = array[(indexPath as NSIndexPath).row]
                            for matchUpdate:MatchUpdateOBJ in L3sAppDelegate.arrayUpdate {
                                if matchOBJ.id == matchUpdate.match_id {
                                    matchOBJ.status = matchUpdate.status
                                    matchOBJ.home_goal = matchUpdate.home_goal
                                    matchOBJ.away_goal = matchUpdate.away_goal
                                    matchOBJ.home_goalH1 = matchUpdate.home_goalH1
                                    matchOBJ.away_goalH1 = matchUpdate.away_goalH1
                                    
                                }
                            }
                            cell.lblHomeClub.text = matchOBJ.home_club_name
                            cell.lblAwayClub.text = matchOBJ.away_club_name
                            
                            if let intTime:Int = Int(matchOBJ.time_start){
                                if let timeInterval:TimeInterval = TimeInterval(intTime){
                                    let startDate = Date(timeIntervalSince1970:timeInterval)
                                    let dateFomatter = DateFormatter()
                                    dateFomatter.dateFormat = "dd/MM HH:mm"
                                    let strTime = dateFomatter.string(from: startDate)
                                    cell.lblDatetime.text = strTime
                                }
                                
                                
                            }
                            if matchOBJ.is_finish == "1" {
                                cell.lblStatus.text = AL0604.localization(LanguageKey.ft)
                                cell.lblStatus.isHidden = false
                                cell.lblHomeGoal.text = matchOBJ.home_goal
                                cell.lblAwayGoal.text = matchOBJ.away_goal
                            }else{
                                if matchOBJ.is_postponed == "1" {
                                    cell.lblStatus.text = AL0604.localization(LanguageKey.postpone)
                                    cell.lblStatus.isHidden = false
                                    cell.lblHomeGoal.text = "?"
                                    cell.lblAwayGoal.text = "?"
                                } else {
                                    let currentDate = Date()
                                    let currentDateInterval: TimeInterval = currentDate.timeIntervalSinceNow
                                    let doubleCurrent = Double(NSNumber(value: currentDateInterval as Double))
                                    // Chưa đá
                                    let timeStart = Double(matchOBJ.time_start)
                                    if timeStart > doubleCurrent {
                                        cell.lblStatus.isHidden = true
                                        cell.lblStatus.text = ""
                                        cell.lblHomeGoal.text = "?"
                                        cell.lblAwayGoal.text = "?"
                                        // Đang đá
                                    }else{
                                        if matchOBJ.status == "" {
                                             cell.lblStatus.text = "Live"
                                        }else {
                                             cell.lblStatus.text = matchOBJ.status
                                        }
                                        
                                        cell.lblHomeGoal.text = matchOBJ.home_goal
                                        cell.lblAwayGoal.text = matchOBJ.away_goal
                                        cell.lblStatus.isHidden = false
                                       
                                            
                                    }
                                }
                            }
                        }
                        
                        return cell
                        
                    }else if self.isTypeGroup{
                        
                        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCupCell") as! BXHGroupCupCell
                        if (indexPath as NSIndexPath).row % 2 == 0{
                            cell.backgroundColor = UIColor.white
                            
                        }else{
                            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                        }
                        if let array = self.groupRankCups{
                            let groupOBJ:GroupOBJ = array[(indexPath as NSIndexPath).section]
                            let arrayTeam  = groupOBJ.teams
                            if  arrayTeam.count > 0{
                                let team:TeamOfGroupOBJ = arrayTeam[(indexPath as NSIndexPath).row]
                                cell.lblSothutu.text = "\((indexPath as NSIndexPath).row+1)"
                                cell.lblTen.text = team.fc_name
                                cell.lblSotran.text = team.total_match
                                cell.lblTranthang.text = team.total_win
                                cell.lblTranhoa.text = team.total_draw
                                cell.lblTranthua.text = team.total_lose
                                cell.lblBanthang.text = team.total_goal
                                cell.lblBanbai.text = team.total_goal_lose
                                cell.lblDiem.text = team.point
                                cell.lblHieuSo.text = team.subNum
                                
                            }
                        }
                        return cell
                    }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell") as! BXHRoundCell
                        if (indexPath as NSIndexPath).row == 0 || (indexPath as NSIndexPath).row == 1 || (indexPath as NSIndexPath).row == 2 || (indexPath as NSIndexPath).row == 3{
                            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                        }else{
                            cell.backgroundColor = UIColor.white
                        }

                        if let array = self.teamRankCups{
                            let teamOBJ:TeamOBJ = array[(indexPath as NSIndexPath).row]
                            cell.lblIndex.text = "\((indexPath as NSIndexPath).row+1)"
                            cell.lblName.text = teamOBJ.football_club_name
                            cell.lblSotran.text = teamOBJ.total_match
                            cell.lblThang.text = teamOBJ.total_win
                            cell.lblHoa.text = teamOBJ.total_draw
                            cell.lblThua.text = teamOBJ.total_lose
                            cell.lblHieuSo.text = teamOBJ.goal
                            cell.lblDiem.text = teamOBJ.total_point
                            cell.selectionStyle = .none
                            
                        }
                        return cell
                        
                    }
    
                }
                // Xem Danh Sách Trận
            }else if isMatch{
               let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell") as! MatchCell
                if (indexPath as NSIndexPath).row % 2 == 0{
                    cell.backgroundColor = UIColor.white
                    
                }else{
                    cell.backgroundColor = UIColor(rgba: "#f5f5f5")
                }
                if (indexPath as NSIndexPath).section == 0 {
                   
                    if let array = self.fixtures{
                        let match:StaticMatchModule = array[(indexPath as NSIndexPath).row]
                        cell.awayname.text = match.awayName
                        cell.homename.text = match.homeName
                        let time = DateManager.shareManager.dateToString(Double(match.timeStart), format: "HH:mm")
                        let date = DateManager.shareManager.dateToString(Double(match.timeStart), format: "dd/MM")
                        cell.lblDate.text = date
                        cell.lblTime.text = time
                        cell.btnFavorite.isEnabled = true
                        cell.imageFavorite.isHidden = false
                        cell.selectionStyle = .none
                        
                    }
 
                }else{
                    
                    if let array = self.arrayResult{
                        let match:StaticMatchModule = array[(indexPath as NSIndexPath).row]
                        cell.awayname.text = match.awayName
                        cell.homename.text = match.homeName
                        let date = DateManager.shareManager.dateToString(Double(match.timeStart), format: "dd/MM")
                        cell.lblDate.text = date
                        cell.lblTime.text = "\(match.homeGoal) - \(match.awayGoal)"
                        cell.btnFavorite.isEnabled = false
                        cell.imageFavorite.isHidden = true
                        cell.selectionStyle = .none
                        
                    }
                    
                }
                
                return cell
                
                // Xem Chỉ Số
            }else if isIndex{
                let cell = tableView.dequeueReusableCell(withIdentifier: "L3sTopScoreCell") as! L3sTopScoreCell
                if (indexPath as NSIndexPath).row == 0 {
                    
                    cell.backgroundColor = UIColor(rgba: "#595858")
                    cell.lblPlayerName.text = AL0604.localization(LanguageKey.player)
                    cell.lblPlayerName.textColor = UIColor.white
                    cell.lblTeamName.text = AL0604.localization(LanguageKey.team)
                    cell.lblTeamName.textColor = UIColor.white
                    cell.lblGoal.text = AL0604.localization(LanguageKey.goal)
                    cell.lblGoal.textColor = UIColor.white
                    cell.lblPen.text = AL0604.localization(LanguageKey.penalty_goals)
                    cell.lblPen.textColor = UIColor.white
                    cell.lblFirstGoal.text = AL0604.localization(LanguageKey.first_goals)
                    cell.lblFirstGoal.textColor = UIColor.white
                } else {
                    cell.backgroundColor = UIColor.white
                    cell.lblPlayerName.textColor = UIColor.black
                    cell.lblTeamName.textColor = UIColor.black
                    cell.lblGoal.textColor = UIColor.black
                    cell.lblPen.textColor = UIColor.black
                    cell.lblFirstGoal.textColor = UIColor.black
                    let entity = topScoreResult![(indexPath as NSIndexPath).row - 1]
                    cell.entity = entity
                    
                }
              
                return cell
                
                // Xem thống kê
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "RoundCell") as! BXHRoundCell
                
                return cell
            }

        }
        
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if tableView == myTableView{
            return nil
        }else{
            var view:UIView!
            // Xem BXH
            
            if isRank {
                // Giải đấu Quốc Gia
                
                if self.leageRankRounds != nil {
                    view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
                    view.backgroundColor = UIColor(rgba: "#595858")
                    
                    
                    let lblMatch = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/1.96 , y: 10, width: 50, height: 20))
                    lblMatch.textColor = UIColor.white
                    lblMatch.font = UIFont.systemFont(ofSize: 13)
                    lblMatch.text = AL0604.localization(LanguageKey.label_total_match)
                    
                    view.addSubview(lblMatch)
                    
                    let lblWin = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.32, y: 10, width: 50, height: 20))
                    lblWin.textColor = UIColor.white
                    lblWin.font = UIFont.systemFont(ofSize: 13)
                    lblWin.text = AL0604.localization(LanguageKey.label_total_win)
                    view.addSubview(lblWin)
                    
                    let lblDraw = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.9, y: 10, width: 50, height: 20))
                    lblDraw.textColor = UIColor.white
                    lblDraw.font = UIFont.systemFont(ofSize: 13)
                    lblDraw.text = AL0604.localization(LanguageKey.label_total_draw)
                    view.addSubview(lblDraw)
                    
                    let lblLose = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/3.9, y: 10, width: 50, height: 20))
                    lblLose.textColor = UIColor.white
                    lblLose.font = UIFont.systemFont(ofSize: 13)
                    lblLose.text = AL0604.localization(LanguageKey.label_total_lose)
                    view.addSubview(lblLose)
                    
                    let lblHS = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/5.5, y: 10, width: 50, height: 20))
                    lblHS.textColor = UIColor.white
                    lblHS.font = UIFont.systemFont(ofSize: 13)
                    lblHS.text = "+/-"
                    view.addSubview(lblHS)
                    
                    let lblPoint = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/12, y: 10, width: 50, height: 20))
                    lblPoint.textColor = UIColor.white
                    lblPoint.font = UIFont.systemFont(ofSize: 13)
                    lblPoint.text = AL0604.localization(LanguageKey.label_total_point)
                    view.addSubview(lblPoint)
                    
                    // Giải đấu cúp
                }else{
                    if self.isTypeMatch{
                        view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 0))
                        
                    }else if self.isTypeGroup{
                        let subView:UIView!
                        if section == 0 {
                            view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 21))
                            view.backgroundColor = UIColor(rgba: "#595858")
                            subView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 21))
                            view.backgroundColor = UIColor(rgba: "#595858")
                            view.addSubview(subView)
                            let labelTop = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
                            labelTop.backgroundColor = UIColor(rgba: "#4b4a4a")
                            subView.addSubview(labelTop)
                        }else{
                            view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 31))
                            view.backgroundColor = UIColor.white
                            subView = UIView(frame: CGRect(x: 0, y: 10, width: tableView.frame.size.width, height: 21))
                            subView.backgroundColor = UIColor(rgba: "#595858")
                            view.addSubview(subView)
                            
                        }
                        
                        let image = UIImageView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 21))
                        image.image = UIImage(named: "bg_cellGroup.png")
                        subView.addSubview(image)
                        
                        let lblBang = UILabel(frame: CGRect(x: 8, y: 1, width: 50, height: 20))
                        lblBang.textColor = UIColor.white
                        lblBang.font = UIFont.systemFont(ofSize: 11)
                        let groupOBJ = self.leageRankCup?.arrayGroup[section]
                        lblBang.text = groupOBJ?.name
                        subView.addSubview(lblBang)
                        
                        let lblTen = UILabel(frame: CGRect(x: 27, y: 1, width: 100, height: 20))
                        lblTen.textColor = UIColor.white
                        lblTen.font = UIFont.systemFont(ofSize: 13)
                        lblTen.text = AL0604.localization(LanguageKey.team)
                        subView.addSubview(lblTen)
                        
                        let lblTran = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.08 , y: 1, width: 50, height: 20))
                        lblTran.textColor = UIColor.white
                        lblTran.font = UIFont.systemFont(ofSize: 13)
                        lblTran.text = AL0604.localization(LanguageKey.label_total_match)
                        subView.addSubview(lblTran)
                        
                        let lblWin = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.4 , y: 1, width: 50, height: 20))
                        lblWin.textColor = UIColor.white
                        lblWin.font = UIFont.systemFont(ofSize: 12)
                        lblWin.text = AL0604.localization(LanguageKey.label_total_win)
                        
                        subView.addSubview(lblWin)
                        
                        let lblDraw = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.84 , y: 1, width: 50, height: 20))
                        lblDraw.textColor = UIColor.white
                        lblDraw.font = UIFont.systemFont(ofSize: 12)
                        lblDraw.text = AL0604.localization(LanguageKey.label_total_draw)
                        
                        subView.addSubview(lblDraw)
                        
                        let lbllose = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/3.4, y: 1, width: 50, height: 20))
                        lbllose.textColor = UIColor.white
                        lbllose.font = UIFont.systemFont(ofSize: 12)
                        lbllose.text = AL0604.localization(LanguageKey.label_total_lose)
                        subView.addSubview(lbllose)
                        
                        let lblBT = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/4.3, y: 1, width: 50, height: 20))
                        lblBT.textColor = UIColor.white
                        lblBT.font = UIFont.systemFont(ofSize: 12)
                        lblBT.text = AL0604.localization(LanguageKey.label_goal_for)
                        subView.addSubview(lblBT)
                        
                        let lblBB = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/5.9, y: 1, width: 50, height: 20))
                        lblBB.textColor = UIColor.white
                        lblBB.font = UIFont.systemFont(ofSize: 12)
                        lblBB.text = AL0604.localization(LanguageKey.label_goal_against)
                        subView.addSubview(lblBB)
                        
                        let lblHS = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/9, y: 1, width: 50, height: 20))
                        lblHS.textColor = UIColor.white
                        lblHS.font = UIFont.systemFont(ofSize: 12)
                        lblHS.text = "+/-"
                        subView.addSubview(lblHS)
                        
                        let lblPoint = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/19, y: 1, width: 50, height: 20))
                        lblPoint.textColor = UIColor.white
                        lblPoint.font = UIFont.systemFont(ofSize: 12)
                        lblPoint.text = AL0604.localization(LanguageKey.label_total_point)
                        subView.addSubview(lblPoint)
                    }else{
                        view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
                        view.backgroundColor = UIColor(rgba: "#595858")
                        let lblMatch = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.7 , y: 10, width: 50, height: 20))
                        lblMatch.textColor = UIColor.white
                        lblMatch.font = UIFont.systemFont(ofSize: 11)
                        lblMatch.text = AL0604.localization(LanguageKey.label_total_match)
                        
                        view.addSubview(lblMatch)
                        
                        let lblWin = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/3.25, y: 10, width: 50, height: 20))
                        lblWin.textColor = UIColor.white
                        lblWin.font = UIFont.systemFont(ofSize: 11)
                        lblWin.text = AL0604.localization(LanguageKey.label_total_win)
                        view.addSubview(lblWin)
                        
                        let lblDraw = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/3.95, y: 10, width: 50, height: 20))
                        lblDraw.textColor = UIColor.white
                        lblDraw.font = UIFont.systemFont(ofSize: 11)
                        lblDraw.text = AL0604.localization(LanguageKey.label_total_draw)
                        view.addSubview(lblDraw)
                        
                        let lblLose = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/5.25, y: 10, width: 50, height: 20))
                        lblLose.textColor = UIColor.white
                        lblLose.font = UIFont.systemFont(ofSize: 11)
                        lblLose.text = AL0604.localization(LanguageKey.label_total_lose)
                        view.addSubview(lblLose)
                        
                        let lblHS = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/7.2, y: 10, width: 50, height: 20))
                        lblHS.textColor = UIColor.white
                        lblHS.font = UIFont.systemFont(ofSize: 11)
                        lblHS.text = "+/-"
                        view.addSubview(lblHS)
                        
                        let lblPoint = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/15.5, y: 10, width: 50, height: 20))
                        lblPoint.textColor = UIColor.white
                        lblPoint.font = UIFont.systemFont(ofSize: 11)
                        lblPoint.text = AL0604.localization(LanguageKey.label_total_point)
                        view.addSubview(lblPoint)
                    }
                    
                }
                
                // Xem Danh Sách Trận
            }else if isMatch {
                view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
                view.backgroundColor = UIColor(rgba: "#595858")
                let lblTitle = UILabel(frame: CGRect(x: 0, y: 10, width: view.frame.size.width, height: 20))
                lblTitle.textColor = UIColor.white
                lblTitle.font = UIFont.systemFont(ofSize: 14)
                if section == 0 {
                    lblTitle.text = AL0604.localization(LanguageKey.fixtures)
                }else {
                    lblTitle.text = AL0604.localization(LanguageKey.result)
                }
                
                lblTitle.textAlignment = .center
                view.addSubview(lblTitle)
                
                // Xem Chỉ Số
            }else if isIndex {
                return nil
//                view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
//                view.backgroundColor = UIColor(rgba: "#595858")
//                let imageGoal = UIImageView(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.2, y: 12, width: 16, height: 16))
//                imageGoal.image = UIImage(named: "icon_football_white.png")
//                view.addSubview(imageGoal)
//                
//                let lblMatch = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.8, y: 10, width: 50, height: 20))
//                lblMatch.textColor = UIColor.whiteColor()
//                lblMatch.font = UIFont.systemFontOfSize(11)
//                lblMatch.text = "M"
//                
//                view.addSubview(lblMatch)
//                
//                let lblHS = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/3.3, y: 10, width: 120, height: 20))
//                lblHS.textColor = UIColor.whiteColor()
//                lblHS.font = UIFont.systemFontOfSize(10)
//                lblHS.text = AL0604.localization("Goal") + "/" +  AL0604.localization("Match")
//                
//                view.addSubview(lblHS)
                
                
                // Xem thống kê
            }else{
                view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
                view.backgroundColor = UIColor(rgba: "#595858")
                let lblTotalMatch = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.35, y: 10, width: 100, height: 20))
                lblTotalMatch.textColor = UIColor.white
                lblTotalMatch.font = UIFont.systemFont(ofSize: 10)
                lblTotalMatch.text = AL0604.localization(LanguageKey.label_total_match)
                view.addSubview(lblTotalMatch)
                
                let lblMatch = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/2.8, y: 10, width: 100, height: 20))
                lblMatch.textColor = UIColor.white
                lblMatch.font = UIFont.systemFont(ofSize: 10)
                lblMatch.text = "5 trận gần đây"
                view.addSubview(lblMatch)
                
                let lblPoint = UILabel(frame: CGRect(x: view.frame.size.width - (view.frame.size.width)/11, y: 10, width: 50, height: 20))
                lblPoint.textColor = UIColor.white
                lblPoint.font = UIFont.systemFont(ofSize: 10)
                lblPoint.text = AL0604.localization(LanguageKey.label_total_point)
                view.addSubview(lblPoint)
            }
            return view

        }
    }
}
extension DetailStatisticViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView == myTableView {
            return 0
        }else{
            // Xem BXH
            if isRank {
                // Giải đấu Quốc Gia
                if self.leageRankRounds != nil {
                    
                    return 40
                    
                    // Giải đấu cúp
                }else{
                    
                    if self.isTypeMatch{
                        return 0
                    }else if self.isTypeGroup{
                        if section == 0{
                            return 21
                        }else{
                            return 31
                        }
                        
                    }else{
                        return 40
                    }
                    
                }
                // Xem Danh Sách Trận
            }else if isMatch{
                
                return 40
                
                // Xem Chỉ Số
            }else if isIndex{
                return 0
                
                // Xem thống kê
            }else{
                return 40
            }

        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == myTableView {
            return 40;
        }else{
            // Xem BXH
            if isRank {
                // Giải đấu Quốc Gia
                if self.leageRankRounds != nil {
                    return 44
                    
                    // Giải đấu cúp
                }else{
                    
                    if self.isTypeMatch{
                        return 55
                    }else if self.isTypeGroup{
                        return 21
                    }else{
                        return 44
                        
                    }
                    
                }
                // Xem Danh Sách Trận
            }else if isMatch{
                
                return 44
                
                // Xem Chỉ Số
            }else if isIndex{
                return 44
                
                // Xem thống kê
            }else{
                return 0
            }

        }
        
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == myTableView {
            if self.isRank{
                if self.leageRankRounds != nil {
                    self.sessionDisplay = self.sessionRankRounds![(indexPath as NSIndexPath).row];
                    self.sessionLabel.text = self.sessionDisplay?.season_name
                    if isRank {
                        self.teamRankRounds = self.sessionDisplay?.teams
                        myView?.isHidden = true
                    }
                    // Giải đấu cúp
                }else{
                    if isSession {
                        self.sessionCupDisplay = self.sessionRankCups![(indexPath as NSIndexPath).row]
                        self.sessionLabel.text = self.sessionCupDisplay?.season_name
                        self.lblDisplayRoundPlay.text = "------"
                        self.roundRankCup = self.sessionCupDisplay?.rounds
                        myView?.isHidden = true
                        
                    }else{
                        LoadingView.sharedInstance.showLoadingView(view)
                        self.roundCupDiplay = self.roundRankCup![(indexPath as NSIndexPath).row]
                        self.lblDisplayRoundPlay.text = self.roundCupDiplay?.name
                        myView?.isHidden = true
                        var strTypeRank = ""
                        if self.roundCupDiplay?.having_group == "1" {
                            strTypeRank = "v1_group_ranking"
                            self.isTypeGroup = true
                            self.isTypeMatch = false
                            self.isTypeRound = false
                        }else if self.roundCupDiplay?.log_rank == "1" {
                            strTypeRank = "v1_round_ranking"
                            self.isTypeGroup = false
                            self.isTypeMatch = false
                            self.isTypeRound = true
                        }else {
                            strTypeRank = "v1_match_ranking"
                            self.isTypeGroup = false
                            self.isTypeMatch = true
                            self.isTypeRound = false
                        }
                        getBXHFolowRound(strTypeRank, leagueID: (self.leageRankCup?.id)!, sesionID: (self.sessionCupDisplay?.season_id)!, roundID: (self.roundCupDiplay?.id)!)
                    }
                    
                }

            }else{
                let alert = UIAlertController(title: AL0604.localization(LanguageKey.alert), message: AL0604.localization(LanguageKey.view_more_at_web), preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: AL0604.localization(LanguageKey.ok), style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
                 myView?.isHidden = true
            }
        }else{
            if(isMatch){
                if (indexPath as NSIndexPath).section == 0 {
                    
                    if let array = self.fixtures{
                        let match:StaticMatchModule = array[(indexPath as NSIndexPath).row]
                        let matchModule = fillDataForMatch(match)
                        let matchDetailVC = L3sMatchDetailViewController(nibName: "L3sMatchDetailViewController", bundle: nil)
                        matchDetailVC.match = matchModule
                         navigationController?.pushViewController(matchDetailVC, animated: true)
                    }
                    
                }else{
                    
                    if let array = self.arrayResult{
                        let match:StaticMatchModule = array[(indexPath as NSIndexPath).row]
                        let matchModule = fillDataForMatch(match)
                        let matchDetailVC = L3sMatchDetailViewController(nibName: "L3sMatchDetailViewController", bundle: nil)
                        matchDetailVC.match = matchModule
                         navigationController?.pushViewController(matchDetailVC, animated: true)
                  
                        
                    }
                    
                }

            }
        }
    }
    func fillDataForMatch(_ matchStatic: StaticMatchModule) -> (MatchModule){
        let match: MatchModule = MatchModule()
        match.id = matchStatic.matchid
        match.season_id = matchStatic.season_id
        match.season_name = matchStatic.season_name
        match.country_id = matchStatic.country_id
        match.country_name = matchStatic.country_name
        match.home_club_name = matchStatic.homeName
        match.away_club_name = matchStatic.awayName
        match.home_club_image = matchStatic.home_club_image
        match.away_club_image = matchStatic.away_club_image
        match.home_goal = matchStatic.homeGoal
        match.away_goal = matchStatic.awayGoal
        match.is_finish = matchStatic.is_finish
        match.is_postponed = matchStatic.is_postponed
        match.memo = matchStatic.memo
        match.time_start = matchStatic.timeStart
        match.status = ""
        match.home_goalH1 = matchStatic.first_time_home_goal
        match.away_goalH1 = matchStatic.first_time_away_goal
        match.match_vi = matchStatic.match_vi
        match.match_fr = matchStatic.match_fr
        
        
        return match
    }
}
