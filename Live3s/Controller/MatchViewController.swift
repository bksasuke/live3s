//
//  MainViewController.swift
//  Live3s
//
//  Created by phuc nguyen on 11/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import AlamofireImage
import GoogleMobileAds
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


let maxItem = 21
let middleItem = Int(maxItem / 2)
let LiveGif = "http://cdn3.livescore.com/web/img/flash.gif"
enum LIST_MATCH_MODE {
    case all, finish, feature, live
}
class MatchViewController: L3sViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerScroll: ScrollPager!
    fileprivate var rightbarButton: BadgeButton =  {
        let button = BadgeButton(frame: CGRect(x: 0, y: 0, width: 28, height: 30))
        button.setImage(UIImage(named: "clock_live.png"), for: UIControlState())
        button.badgeBackgroundColor = UIColor.black
        return button
    }()
    
    var bannerView: GADBannerView?
    var interstitial: GADInterstitial!
    
    var headerView = [MatchDayButton]()
    var screenType = 0 // 0: match - 1: fixture - 2: finish
    internal var stringType:String?
    internal var isShowFull:Bool = false
    var isByTime = false
    fileprivate var listMatchMode: LIST_MATCH_MODE?
    fileprivate var selectedDropDownIndex: Int = 0
    fileprivate var selectedHeaderIndex: Int = 0
    fileprivate var isReloadingData = false {
        didSet {
            if isReloadingData {
                LoadingView.sharedInstance.showLoadingView(view)
            } else {
                LoadingView.sharedInstance.hideLoadingView()
            }
        }
    }
    fileprivate var isFirstTime = true
    fileprivate var isMiddle = true
    internal var isLive = false {
        didSet {
            tableView.reloadData()
        }
    }

    fileprivate var seasonList = [LeagueModule](){
        didSet {
            self.tableView.reloadData()
            if tableView.numberOfRows(inSection: 0) < 0 {
                tableView.scrollRectToVisible(CGRect.zero, animated: true)
            }
            TimeManager.shareManager.stop()
            isReloadingData = false
            let date = DateManager.shareManager.dateFromCompt(DateManager.shareManager.currentDay - 1,
                MM: DateManager.shareManager.currentMonth,
                yyyy: DateManager.shareManager.currentYear)
            if date != self.headerView[self.selectedHeaderIndex].title! {return}
            TimeManager.shareManager.startwithblock { () -> Void in
                switch self.listMatchMode! {
                case .all:
                    self.reloadData(.all,isByTime: self.isByTime)
                    break
                case .finish:
                    self.reloadData(.finish,isByTime: self.isByTime)
                    break
                case .feature:
                    self.reloadData(.future,isByTime: self.isByTime)
                    break
                case .live:
                    self.reloadData(.live,isByTime: self.isByTime)
                    break
                }
            }
        }

    }
    fileprivate var datasource = [MatchModule]() {
        didSet {
            self.tableView.reloadData()
            if tableView.numberOfRows(inSection: 0) < 0 {
                tableView.scrollRectToVisible(CGRect.zero, animated: true)
            }
            TimeManager.shareManager.stop()
            isReloadingData = false
            let date = DateManager.shareManager.dateFromCompt(DateManager.shareManager.currentDay - 1,
                MM: DateManager.shareManager.currentMonth,
                yyyy: DateManager.shareManager.currentYear)
            if date != self.headerView[self.selectedHeaderIndex].title! {return}
            TimeManager.shareManager.startwithblock { () -> Void in
                switch self.listMatchMode! {
                case .all:
                     self.reloadData(.all,isByTime: self.isByTime)
                    break
                case .finish:
                    self.reloadData(.finish,isByTime: self.isByTime)
                     break
                case .feature:
                    self.reloadData(.future,isByTime: self.isByTime)
                     break
                case .live:
                    self.reloadData(.live,isByTime: self.isByTime)
                    break
                }
            }
        }
    }
    fileprivate var listFavorite = [MatchModle]() {
        didSet {
                tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        LoadingView.sharedInstance.showLoadingView(view)
        isShowNavigationBarMenu = true
        items = [LanguageKey.leagues, LanguageKey.times]
        super.viewDidLoad()
        self.stringType = "Match"
        // Do any additional setup after loading the view, typically from a nib.
        tableView.register(MatchTableViewHeader.self, forHeaderFooterViewReuseIdentifier: "headerCell")
        tableView.separatorStyle = .none
        NotificationCenter.default.addObserver(self, selector: #selector(MatchViewController.reloadLiveScore(_:)), name: NSNotification.Name(rawValue: KEY_LIVE_SCORE_DID_UPDATE), object: nil)
        TimeManager.shareManager.liveTimerRunning()
        rightbarButton.addTarget(self, action: #selector(MatchViewController.rightbarButtonAction(_:)), for: .touchUpInside)
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
         NotificationCenter.default.addObserver(self, selector: #selector(MatchViewController.addAvertising), name: NSNotification.Name(rawValue: ADD_AD), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Home")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        
        TimeManager.shareManager.resume()
        selectedDropDownIndex = 0
        menuView.setMenuTitle(AL0604.localization(items![selectedDropDownIndex]))
        updateUI()
       
        NotificationCenter.default.addObserver(self, selector: #selector(MatchViewController.updateDataTable), name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
        addAvertisingFull()
        
       
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
         addRightBarButton()
        listFavorite.removeAll()
         listFavorite = self.getMatchfavoriteList()
        if isFirstTime {
            setUpHeader()
            isFirstTime = false
        }
        if self.listMatchMode == .live{
            self.rightbarButton.setImage(UIImage(named: "clock_all.png"), for: UIControlState())
        }else{
            self.rightbarButton.setImage(UIImage(named: "clock_live.png"), for: UIControlState())
        }
        
        
    }

    override func viewWillDisappear(_ animated: Bool) {
        TimeManager.shareManager.pause()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: UPDATE_DATA), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateDataTable(){
        self.tableView .reloadData()
    }
    
    override func didSelectNavigationBarMenuItemAtIndex(_ index: Int) {
        selectedDropDownIndex = index
        print("Did select item at index: \(index) : \(items![index])")
        navigationItem.leftBarButtonItem?.isEnabled = true
        switch index {
        case 0:
              self.isByTime = false
            if self.isLive{
                reloadData(.live, isByTime: self.isByTime)
            }else{
                if self.isMiddle {
                    if screenType == 1 {
                        self.reloadData(.future,isByTime: self.isByTime)
                        return
                    } else if screenType == 2 {
                        self.reloadData(.finish,isByTime: self.isByTime)
                        return
                    } else if screenType == 0{
                        self.reloadData(.all,isByTime: self.isByTime)
                    }else{
                        self.reloadData(.live,isByTime: self.isByTime)
                    }

                }else{
                     reloadDataWithDate(headerView[selectedHeaderIndex].title!, isByTime: self.isByTime)
                }
               
            }
          
            
            break
        case 1:
            self.isByTime = true
            if self.isLive{
                reloadData(.live, isByTime: self.isByTime)
            }else{
                if self.isMiddle {
                    if screenType == 1 {
                        self.reloadData(.future,isByTime: self.isByTime)
                        return
                    } else if screenType == 2 {
                        self.reloadData(.finish,isByTime: self.isByTime)
                        return
                    } else if screenType == 0{
                        self.reloadData(.all,isByTime: self.isByTime)
                    }else{
                        self.reloadData(.live,isByTime: self.isByTime)
                    }
                    
                }else{
                    reloadDataWithDate(headerView[selectedHeaderIndex].title!, isByTime: self.isByTime)
                }
            }
            break
        default: break
        }
        
    }
    
    override func willShowDropdownMenu() {
        navigationItem.leftBarButtonItem?.isEnabled = false
    }
    
    override func willHideDropdownMenu() {
        navigationItem.leftBarButtonItem?.isEnabled = true
    }
    
    func getMatchfavoriteList() -> [MatchModle] {
        return MatchModle.allsavedMatch()
    }
    
    func reloadLiveScore(_ notify: Notification) {
        
        if let count = notify.object as? Int {
            rightbarButton.badgeString = "\(count)"
        }
    }
    
    func addRightBarButton(){
            let leftButton: UIBarButtonItem = UIBarButtonItem(customView:self.rightbarButton)
            navigationItem.rightBarButtonItem = leftButton;
       
    }
    
    func rightbarButtonAction(_ button: UIButton) {
        if self.isLive {
            self.rightbarButton.setImage(UIImage(named: "clock_live.png"), for: UIControlState())
            self.reloadData(MatchListType.all,isByTime: self.isByTime)
            self.isLive = false
        }else{
            self.rightbarButton.setImage(UIImage(named: "clock_all.png"), for: UIControlState())
            let currentIndex = middleItem
            self.headerScroll.selectedIndex = currentIndex
            self.reloadData(MatchListType.live,isByTime: self.isByTime)
            self.isLive = true
        }
      
    }
    
    func updateUI() {
       
       
        tableView.reloadData()
        for button in headerView {
            button.layoutSubviews()
        }
    }
    
    func setUpHeader() {
        /* remove old header
        let daysOfMonth = DateManager.shareManager.daysOfMonth
        for index in 1...daysOfMonth {
            let view = MatchDayButton(frame: CGRectZero)
                view.title = DateManager.shareManager.dateFromCompt(index,
                MM: DateManager.shareManager.currentMonth,
                yyyy: DateManager.shareManager.currentYear)
            view.subTitle = "\(index)"
            headerView.append(view)
        }
        */
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
    
    func reloadDataWithDate(_ date: String, isByTime: Bool) {
        TimeManager.shareManager.stop()
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getAllMatchs(date, isByTime: isByTime) { (matchs, error) -> () in
            if error == nil {
                guard let aMatchs = matchs else {
                    return
                }
                if aMatchs.count > 0 {
                    for anonymous in aMatchs{
                        if ((anonymous as? LeagueModule) != nil) {
                            self.seasonList = aMatchs as! [LeagueModule]
                            
                        }
                        if  ((anonymous as? MatchModule) != nil) {
                            self.datasource = aMatchs as! [MatchModule]
                            
                        }
                    }
                }else{
                    self.isReloadingData = false
                    if self.isByTime {
                      self.datasource.removeAll()
                    }else{
                        self.seasonList.removeAll()
                    }
                }
                
            }
        }
    }
    
    func reloadData(_ type: MatchListType , isByTime:Bool) {
        TimeManager.shareManager.stop()
        switch type {
        case .finish:
            listMatchMode = .finish
            break
        case .future:
            listMatchMode = .feature
            break
        case .all:
            listMatchMode = .all
            break
        case .live:
            listMatchMode = .live
        }
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getAllMatchs(type , isByTime: isByTime) { [unowned self](matchs, error) -> () in
            self.isReloadingData = false
            if error == nil {
                    guard let aMatchs = matchs else {
                        if self.isByTime {
                            self.datasource.removeAll()
                        }else{
                            self.seasonList.removeAll()
                        }

                        return
                    }
                if aMatchs.count > 0{
                    for anonymous in aMatchs{
                        if ((anonymous as? LeagueModule) != nil) {
                            self.seasonList = aMatchs as! [LeagueModule]
                        }
                        if  ((anonymous as? MatchModule) != nil) {
                            self.datasource = aMatchs as! [MatchModule]
                        }
                    }
                }else{
                    self.isReloadingData = false
                    if self.isByTime {
                        self.datasource.removeAll()
                    }else{
                        self.seasonList.removeAll()
                    }
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
        addAvertisingFull()
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
extension MatchViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }
        
    }
}
//MARK: - MatchTableViewCellDelegate
extension MatchViewController: MatchTableViewCellDelegate {
    func actionFavorite(_ cell: MatchTableViewCell) {
        
        if listFavorite.count > 0 {
        let indexPath = tableView.indexPath(for: cell)
            if (indexPath as NSIndexPath?)?.section ==  0{
                L3sAppDelegate.managedObjectContext.delete(cell.matchModel!)
                try! L3sAppDelegate.managedObjectContext.save()
                listFavorite.removeObject(cell.matchModel!)
                tableView.reloadData()
            }else {
                let isFavorited = MatchModle.saveMatch(cell.match!)
                if isFavorited {
                    cell.imageFavorite.image = UIImage(named: "icon_favorited.png")
                } else {
                    cell.imageFavorite.image = UIImage(named: "icon_favorite.png")
                }
                
                if self.stringType == "Match" {
                    listFavorite.removeAll()
                    listFavorite = self.getMatchfavoriteList()
                }
            }
        }else {
            let isFavorited = MatchModle.saveMatch(cell.match!)
            if isFavorited {
                cell.imageFavorite.image = UIImage(named: "icon_favorited.png")
            } else {
                cell.imageFavorite.image = UIImage(named: "icon_favorite.png")
            }
            
            if self.stringType == "Match" {
                listFavorite.removeAll()
                listFavorite = self.getMatchfavoriteList()
            }
        }
        switch self.listMatchMode! {
        case .all:
            self.reloadData(.all,isByTime: self.isByTime)
            break
        case .finish:
            self.reloadData(.finish,isByTime: self.isByTime)
            break
        case .feature:
            self.reloadData(.future,isByTime: self.isByTime)
            break
        case .live:
            self.reloadData(.live,isByTime: self.isByTime)
            break
        }

    }
}


//MARK: - ScrollPgaerDelegate

extension MatchViewController: ScrollPagerDelegate {
    func scrollPager(_ scrollPager: ScrollPager, changedIndex: Int) {
        headerView[changedIndex].selected = true
        updateButtonColor(changedIndex)
        selectedHeaderIndex = changedIndex
        
    }
    func scrollPagerWillChange(_ scrollPager: ScrollPager, fromIndex: Int) {
        headerView[fromIndex].selected = false
    }
    
    func scrollPagerdidSelectItem(_ scrollPager: ScrollPager, index: Int) {
        self.rightbarButton.setImage(UIImage(named: "clock_live.png"), for: UIControlState())
        if index == middleItem {
            self.isMiddle = true
            if self.isLive{
                self.reloadData(.live,isByTime: self.isByTime)
            }else{
                if screenType == 1 {
                    self.reloadData(.future,isByTime: self.isByTime)
                    return
                } else if screenType == 2 {
                    self.reloadData(.finish,isByTime: self.isByTime)
                    return
                } else if screenType == 0{
                    self.reloadData(.all,isByTime: self.isByTime)
                }else{
                     self.reloadData(.live,isByTime: self.isByTime)
                }

            }
        } else {
            reloadDataWithDate(headerView[index].title!, isByTime: self.isByTime)
             self.isMiddle = false
        }
   
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

//MARK: UITableViewDatasource

extension MatchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
      
        
                if self.isByTime{
                    if listFavorite.count > 0 {
                        return 2;
                    }else{
                        return 1;
                    }
                }else{
                    if listFavorite.count > 0 {
                        return seasonList.count + 1
                    }else{
                        return seasonList.count
                    }
                }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.isByTime {
            if listFavorite.count > 0 {
                if section == 0 {
                    return listFavorite.count
                    
                }else {
                    return datasource.count
                }
            }else{
                return datasource.count
            }
        }else{
            if listFavorite.count > 0 {
                if section == 0 {
                    return listFavorite.count
                    
                }else {
                    let season = seasonList[section - 1]
                    return season.matchs.count
                }
            }else{
                let season = seasonList[section]
                return season.matchs.count
            }
        
        }        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell") as! MatchTableViewCell
        cell.delegate = self
        var match: MatchModule!
        var matchModel: MatchModle!
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        var isFinish = false
            var isPospone = false
            var isNotPlay = false
            if listFavorite.count > 0{
                if (indexPath as NSIndexPath).section == 0 {
                    matchModel = listFavorite[(indexPath as NSIndexPath).row]
                    cell.matchModel = matchModel
                    if matchModel.isFinish == 1 {
                        isFinish = true
                    } else {
                        isFinish = false
                    }
                    if matchModel.isPosponse == 1 {
                        isPospone = true
                    } else {
                        isPospone = false
                    }
                    if Double(matchModel.time_start!) > Date().timeIntervalSince1970 {
                        isNotPlay = true
                    } else {
                        isNotPlay = false
                    }
                    
                    cell.resultButton.backgroundColor = UIColor.black
                    cell.resultButton .setTitleColor(UIColor(rgba: "#fab719"), for: UIControlState())
                    cell.homeLabel.textColor = UIColor(rgba: "#fab719")
                    cell.awayLabel.textColor = UIColor(rgba: "#fab719")
                    cell.backgroundColor = UIColor(rgba: "#313131");
                    if isPospone {
                        cell.currentTimeButton.isHidden = false
                        cell.currentTimeButton .setTitle(AL0604.localization(LanguageKey.postpone), for: UIControlState())
                    }else{
                        // Chưa đá
                        if isNotPlay {
                            cell.currentTimeButton.isHidden = true
                            cell.currentTimeButton .setTitle("", for: UIControlState())
                            // Đang đá
                        }else{
                            cell.favoriteButton.isHidden = false
                            cell.imageFavorite.isHidden = false
                            cell.currentTimeButton.isHidden = false
                            if let status = matchModel.status {
                                cell.currentTimeButton.isHidden = false
                                cell.imgLive.isHidden = true
                                cell.currentTimeButton .setTitle(status, for: UIControlState())
                            }else{
                                    cell.currentTimeButton.isHidden = true
                                    cell.imgLive.isHidden = false
                                    
                                    let url: URL = URL(string: LiveGif)!
                                    Alamofire.request(.GET, url).response() {
                                        (_, _, data, _) in
                                        cell.imgLive.image = UIImage.animatedImageWithAnimatedGIFData(data)
                                        
                                    }
                            }
                            cell.currentTimeButton.backgroundColor = UIColor(rgba: "#fab719")

                        }
                        
                    }

                }else {
                    if self.isByTime{
                        match = datasource[(indexPath as NSIndexPath).row]
                    }else{
                        let league = seasonList[(indexPath as NSIndexPath).section - 1]
                        match = league.matchs[(indexPath as NSIndexPath).row]
                    }
                    cell.match = match
                    if match.is_finish == "1"{
                     isFinish = true
                    }else {
                     isFinish = false
                    }
                    if match.is_postponed == "1"{
                     isPospone = true
                    }else {
                        isPospone = false
                    }
                    cell.homeLabel.textColor = UIColor.black
                    cell.awayLabel.textColor = UIColor.black
                    if match.time_start > Date().timeIntervalSince1970 {
                        isNotPlay = true
                    }else {
                        isNotPlay = false
                    }
                    if isFinish{
                        cell.favoriteButton.isHidden = true
                        cell.imageFavorite.isHidden = true
                        cell.currentTimeButton.isHidden = false
                        cell.currentTimeButton .setTitle(AL0604.localization(LanguageKey.ft), for: UIControlState())
                        cell.currentTimeButton.backgroundColor = UIColor.clear
                        cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                        cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                    }else{
                        if isPospone {
                            cell.favoriteButton.isHidden = false
                            cell.imageFavorite.isHidden = false
                            cell.currentTimeButton.isHidden = false
                            cell.currentTimeButton .setTitle(AL0604.localization(LanguageKey.postpone), for: UIControlState())
                            cell.currentTimeButton.backgroundColor = UIColor.clear
                            cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                            cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                        }else{
                            // Chưa đá
                            if isNotPlay {
                                cell.favoriteButton.isHidden = false
                                cell.imageFavorite.isHidden = false
                                cell.currentTimeButton.isHidden = true
                                cell.currentTimeButton .setTitle("", for: UIControlState())
                                cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                                cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                                // Đang đá
                            }else{
                                cell.favoriteButton.isHidden = false
                                cell.imageFavorite.isHidden = false
                                cell.currentTimeButton.isHidden = false
                                if match.status != ""{
                                    cell.currentTimeButton.isHidden = false
                                    cell.imgLive.isHidden = true
                                    cell.currentTimeButton .setTitle(match.status, for: UIControlState())
                                }else{
                                    cell.currentTimeButton.isHidden = true
                                    cell.imgLive.isHidden = false
                                    
                                    let url: URL = URL(string: LiveGif)!
                                    Alamofire.request(.GET, url).response() {
                                        (_, _, data, _) in
                                        cell.imgLive.image = UIImage.animatedImageWithAnimatedGIFData(data)
                                        
                                    }
                                }
                                cell.currentTimeButton.backgroundColor = UIColor(rgba: "#fab719")
                                cell.resultButton.backgroundColor = UIColor.black
                                cell.resultButton .setTitleColor(UIColor(rgba: "#fab719"), for: UIControlState())
                                
                            }
                            
                        }
                        
                    }

                }
            }else{
                if self.isByTime{
                    match = datasource[(indexPath as NSIndexPath).row]
                }else{
                    let league = seasonList[(indexPath as NSIndexPath).section]
                    
                    match = league.matchs[(indexPath as NSIndexPath).row]
                }
                cell.match = match
                if match.is_finish == "1"{
                    isFinish = true
                }else {
                    isFinish = false
                }
                if match.is_postponed == "1"{
                    isPospone = true
                }else {
                    isPospone = false
                }

                cell.homeLabel.textColor = UIColor.black
                cell.awayLabel.textColor = UIColor.black
                if match.time_start > Date().timeIntervalSince1970 {
                        isNotPlay = true
                }else {
                        isNotPlay = false
                }
                if isFinish{
                    cell.favoriteButton.isHidden = true
                    cell.imageFavorite.isHidden = true
                    cell.currentTimeButton.isHidden = false
                    cell.currentTimeButton .setTitle(AL0604.localization(LanguageKey.ft), for: UIControlState())
                    cell.currentTimeButton.backgroundColor = UIColor.clear
                    cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                    cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                }else{
                    if isPospone {
                        cell.favoriteButton.isHidden = false
                        cell.imageFavorite.isHidden = false
                        cell.currentTimeButton.isHidden = false
                        cell.currentTimeButton .setTitle(AL0604.localization(LanguageKey.postpone), for: UIControlState())
                        cell.currentTimeButton.backgroundColor = UIColor.clear
                        cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                        cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                    }else{
                        // Chưa đá
                        if isNotPlay {
                            cell.favoriteButton.isHidden = false
                            cell.imageFavorite.isHidden = false
                            cell.currentTimeButton.isHidden = true
                            cell.currentTimeButton .setTitle("", for: UIControlState())
                            cell.resultButton.backgroundColor = UIColor(rgba: "#595858")
                            cell.resultButton .setTitleColor(UIColor.white, for: UIControlState())
                            // Đang đá
                        }else{
                            cell.favoriteButton.isHidden = false
                            cell.imageFavorite.isHidden = false
                            if match.status != ""{
                                cell.currentTimeButton.isHidden = false
                                cell.imgLive.isHidden = true
                                cell.currentTimeButton .setTitle(match.status, for: UIControlState())
                            }else{
                                cell.currentTimeButton.isHidden = true
                                cell.imgLive.isHidden = false

                                let url: URL = URL(string: LiveGif)!
                                Alamofire.request(.GET, url).response() {
                                    (_, _, data, _) in
                                    cell.imgLive.image = UIImage.animatedImageWithAnimatedGIFData(data)
                                    
                                }
                            }
                            cell.currentTimeButton.backgroundColor = UIColor(rgba: "#fab719")
                            cell.resultButton.backgroundColor = UIColor.black
                            cell.resultButton .setTitleColor(UIColor(rgba: "#fab719"), for: UIControlState())
                            
                        }
                        
                    }
                    
                }

            }

    
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerCell") as! MatchTableViewHeader
        if self.isByTime{
            if listFavorite.count > 0 {
                if section == 0{
                    view.league_title.text = AL0604.localization("Favorite")
                    view.background.backgroundColor = UIColor(rgba:"#1a1a1a")
                }else {
                    view.league_title.text = AL0604.localization(LanguageKey.times)
                    view.background.backgroundColor = UIColor(rgba: "#595758")
                }
            }else {
                view.league_title.text = AL0604.localization(LanguageKey.times)
                view.background.backgroundColor = UIColor(rgba: "#595758")
            }

        }else{
            if listFavorite.count > 0 {
                if section == 0{
                    view.league_title.text = AL0604.localization("Favorite")
                    view.background.backgroundColor = UIColor(rgba:"#1a1a1a")
                }else {
                    let league = seasonList[section - 1]
                    let seasons = Season.findByID(league.league_id)
                    view.league_title.text = seasons?.name
                    view.background.backgroundColor = UIColor(rgba: "#595758")
                    let url = URL(string: league.league_logo)!
                    view.league_logo.af_setImageWithURL(url)
                }
            }else {
                let league = seasonList[section]
                let seasons = Season.findByID(league.league_id)
                view.league_title.text = seasons?.name
                view.background.backgroundColor = UIColor(rgba: "#595758")
                let url = URL(string: league.league_logo)!
                view.league_logo.af_setImageWithURL(url)
            }
        }
        
            let viewStanding:UIButton = UIButton(frame:CGRect(x: 0, y: 0, width:  UIScreen.main.bounds.width, height: 30))
            viewStanding.tag = section
            viewStanding.addTarget(self, action: #selector(MatchViewController.actionViewStanding(_:)), for:UIControlEvents.touchUpInside )
            view.addSubview(viewStanding)
        
       
        return view;
    }
    func actionViewStanding(_ sender: UIButton){
        if !isByTime {
            let season: LeagueModule

                if listFavorite.count > 0 {
                    if sender.tag ==  0 {
                        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                        slideMenuController()?.changeMainViewController(detailVC, close: true)
                    }else {
                        season = seasonList[sender.tag - 1]
                        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailStatisticViewController") as! DetailStatisticViewController
                        detailVC.leagueID = season.league_id
                        detailVC.urlLogo = season.league_logo
                        detailVC.isRank = true
                        detailVC.isMatch = false
                        detailVC.isIndex = false
                        navigationController?.pushViewController(detailVC, animated: true)
                    }
                }else {
                    season = seasonList[sender.tag]
                    let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailStatisticViewController") as! DetailStatisticViewController
                    detailVC.leagueID = season.league_id
                    detailVC.urlLogo = season.league_logo
                    detailVC.isRank = true
                    detailVC.isMatch = false
                    detailVC.isIndex = false
                navigationController?.pushViewController(detailVC, animated: true)
                }
            
           
        }else{
            if sender.tag == 0 {
                if listFavorite.count > 0 {
                    if sender.tag ==  0 {
                        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
                        slideMenuController()?.changeMainViewController(detailVC, close: true)
                    }
                }
            }
            
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }

}

// MARK: UITableViewDelegate
extension MatchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let matchDetailVC = L3sMatchDetailViewController(nibName: "L3sMatchDetailViewController", bundle: nil)
        var season: LeagueModule!
        var matchModel : MatchModle!
        if self.isByTime {
            if listFavorite.count > 0 {
                if (indexPath as NSIndexPath).section == 0{
                    matchModel = listFavorite[(indexPath as NSIndexPath).row]
                    matchDetailVC.matchModel = matchModel
                    
                }else{
                    matchDetailVC.match = datasource[(indexPath as NSIndexPath).row]
                }
            }else {
                matchDetailVC.match = datasource[(indexPath as NSIndexPath).row]
                
            }

        }else {
            if listFavorite.count > 0 {
                if (indexPath as NSIndexPath).section == 0{
                    matchModel = listFavorite[(indexPath as NSIndexPath).row]
                    matchDetailVC.matchModel = matchModel
                    
                }else{
                    season = seasonList[(indexPath as NSIndexPath).section - 1]
                    matchDetailVC.match = season.matchs[(indexPath as NSIndexPath).row]
                }
            }else {
                season = seasonList[(indexPath as NSIndexPath).section]
                matchDetailVC.match = season.matchs[(indexPath as NSIndexPath).row]
                
            }
        }
        
        
             navigationController?.pushViewController(matchDetailVC, animated: true)
    }
}

//MARK: MatchViewController - UITableViewCell
protocol MatchTableViewCellDelegate: NSObjectProtocol{
    func actionFavorite(_ cell: MatchTableViewCell)
}

class MatchTableViewCell: UITableViewCell {
    
    @IBOutlet weak var currentTimeButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var imageFavorite: UIImageView!
    @IBOutlet weak var resultButton: UIButton!
    @IBOutlet weak var homeLabel: UILabel!
    @IBOutlet weak var awayLabel: UILabel!
    @IBOutlet weak var imgLive: UIImageView!
    
    var delegate: MatchTableViewCellDelegate?
    var match: MatchModule? {
        didSet {
            guard let match = match else {
                fatalError("cannot setup cel with nil value")
            }
            for updateOBJ in L3sAppDelegate.arrayUpdate {
                if match.id == updateOBJ.match_id {
                    match.status = updateOBJ.status
                    match.home_goal = updateOBJ.home_goal
                    match.away_goal = updateOBJ.away_goal
                    match.home_goalH1 = updateOBJ.home_goalH1
                    match.away_goalH1 = updateOBJ.away_goalH1
                    break
                }
            }
            if Double(match.time_start) > Date().timeIntervalSince1970 {
                let text = DateManager.shareManager.dateToString(match.time_start, format: "HH:mm")
            resultButton.setTitle(text, for: UIControlState())
            } else {
                resultButton.setTitle("\(match.home_goal) - \(match.away_goal)", for: UIControlState())
            }
                homeLabel.text = match.home_club_name
                awayLabel.text = match.away_club_name
            if let _ = MatchModle.findByID(match.id) {
                imageFavorite.image = UIImage(named: "icon_favorited.png")
            } else {
                imageFavorite.image = UIImage(named: "icon_favorite.png")
            }
        }
    }
    var matchModel: MatchModle? {
        didSet {
            guard let matchModel = matchModel else {
                fatalError("cannot setup cel with nil value")
            }
            for updateOBJ in L3sAppDelegate.arrayUpdate {
                if matchModel.id == updateOBJ.match_id {
                    matchModel.status = updateOBJ.status
                    matchModel.home_goal = updateOBJ.home_goal
                    matchModel.away_goal = updateOBJ.away_goal
                    matchModel.home_goalH1 = updateOBJ.home_goalH1
                    matchModel.away_goalH1 = updateOBJ.away_goalH1
                    break
                }
            }
            if Double(matchModel.time_start!) > Date().timeIntervalSince1970 {
                let text = DateManager.shareManager.dateToString(Double(matchModel.time_start!), format: "HH:mm")
                resultButton.setTitle(text, for: UIControlState())
            } else {
                let titleButton = "\(matchModel.home_goal!) - \(matchModel.away_goal!)"
                resultButton.setTitle(titleButton, for: UIControlState())
            }
                homeLabel.text = matchModel.home_club_name
                awayLabel.text = matchModel.away_club_name

            imageFavorite.image = UIImage(named: "icon_favorited_black.png")
        }
    }
    override func layoutSubviews() {
        currentTimeButton.layer.cornerRadius = 5
        resultButton.layer.cornerRadius = 5
        favoriteButton.layer.cornerRadius = 5
        
    }
    
    @IBAction func actionFavorite(_ sender: AnyObject) {
        self.delegate?.actionFavorite(self)
    }
}

class MatchTableViewHeader: UITableViewHeaderFooterView {
    
    var league_logo = UIImageView(frame: CGRect.zero)
    var league_title = UILabel(frame: CGRect.zero)
    let background = UIView(frame: CGRect.zero)
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        background.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        league_title.textAlignment = .center
        league_title.textColor = UIColor.white
        addSubview(background)
        addSubview(league_logo)
        addSubview(league_title)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        league_logo.image = nil
    }
    
    override func layoutSubviews() {
        createView()
    }
    
    func createView() {
        let lgFrame = CGRect(x: 5, y: 4, width: 25, height: 22)
        league_logo.frame = lgFrame
        let titleFrame = CGRect(x: 50, y: 0, width: UIScreen.main.bounds.width - 100, height: 30)
        league_title.frame = titleFrame
        league_title.font = UIFont.boldSystemFont(ofSize: 14)
        
        
    }
    
}
