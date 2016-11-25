//
//  SearchViewController.swift
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


class SearchViewController: L3sViewController {

   
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    var arrayResult: [Season]? = [Season](){
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
    internal var isShowFull:Bool = false
    var bannerView: GADBannerView?
    var interstitial: GADInterstitial!
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.tableView.separatorStyle = .none
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.searchBar.delegate = self;
        self.tableView.tableHeaderView = nil;
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        
      
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Search")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        self.addAvertising()
        addAvertisingFull()
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
extension SearchViewController: GADInterstitialDelegate{
    func interstitialDidReceiveAd(_ ad: GADInterstitial!){
        if self.interstitial.isReady {
            self.interstitial.present(fromRootViewController: self)
            self.isShowFull = false
        }

    }
}
//MARK - UITableViewDatasource
extension SearchViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
            if let countSeason = arrayResult?.count{
                return countSeason
            }else {
                return 0
            }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchTableviewCell
        cell.delegate = self
        cell.selectionStyle = .none
        if let searchOBJ:Season = arrayResult?[(indexPath as NSIndexPath).row]{
            cell.searchOBJ = searchOBJ
        }
        if (indexPath as NSIndexPath).row % 2 == 0 {
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        return cell
    }
    
}
extension SearchViewController: SearchTableviewCellDelegate{
    func actionFavorite(_ cell: SearchTableviewCell) {
        var favorite = seasonfavoriteList()
        let id = cell.searchOBJ!.id!
        if let index = favorite.index(of: id) {
            favorite.remove(at: index)
            cell.imgFavorite.image = UIImage(named: "icon_favorite.png")
        } else  {
            favorite.append(cell.searchOBJ!.id!)
            cell.imgFavorite.image = UIImage(named: "icon_favorited.png")
        }
        setSeasonfavoriteList(favorite)
        tableView.reloadData()
    }
}
//MARK - UITableViewDelegate
extension SearchViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
  
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let searchOBJ:Season = (arrayResult?[(indexPath as NSIndexPath).row])!
        let detailVC =  storyboard?.instantiateViewController(withIdentifier: "DetailStatisticViewController") as! DetailStatisticViewController
        detailVC.leagueID = searchOBJ.id
        detailVC.urlLogo = searchOBJ.league_logo
        detailVC.isRank = true
        detailVC.isMatch = false
        detailVC.isIndex = false
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
}
//MARK - SearchTableviewCell
protocol SearchTableviewCellDelegate: NSObjectProtocol {
    func actionFavorite(_ cell: SearchTableviewCell)
}
class SearchTableviewCell: UITableViewCell{
    
    @IBOutlet weak var imgFlag: UIImageView!
    var searchOBJ:Season? {
        didSet {
            lblTitle.text = searchOBJ!.localizationName()
            let url = URL(string: searchOBJ!.league_logo!)
            let placeholderImage = UIImage(named: "bg_headerRate.png")
            imgFlag.af_setImageWithURL(url!, placeholderImage: placeholderImage)
        }
    }
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgFavorite: UIImageView!
    var delegate: SearchTableviewCellDelegate?
    @IBAction func actionFavorite(_ sender: AnyObject) {
        self.delegate?.actionFavorite(self)
    }
  
    
}
//MARK - SearchBar Delegate
extension SearchViewController: UISearchBarDelegate{
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let seasons = Season.findByName(searchText, language: SupportLanguage.english)
        arrayResult = seasons
        
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        return true
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.searchBar.resignFirstResponder()
    }
}
//MARK - Search Object
class SearchOBJ {
    let title:String
    let id:String
    let image:String
    init(title:String, id:String, image:String){
        self.title = title;
        self.id = id
        self.image = image
        
    }
    
}

