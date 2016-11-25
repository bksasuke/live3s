//
//  L3sLeftMenuViewController.swift
//  Live3s
//
//  Created by phuc nguyen on 11/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import RealmSwift

enum LeftMenu: Int {
    case match = 0
    case fixtures
    case result
    case search
    case rate
    case statistic
    case tvScheldule
    case liveTv
    case tips
    case favorite
    case setting
    case related
    case share
    case review
}

protocol LeftMenuProtocol : class {
    func changeViewController(_ menu: LeftMenu)
}

class L3sLeftMenuViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var matchViewController: UINavigationController!
    var isLogin = false {
        didSet {
            live3sAccount = Live3sAccount.getAccount()
            tableView.reloadData()
        }
    }
    var live3sAccount: Live3sAccount!
    /**
     Private variable
     */
    
    fileprivate let menus = [
        kLeftMenu_Match,
        kLeftMenu_Fixtures,
        kLeftMenu_Result,
        kLeftMenu_Search,
        kLeftMenu_Rate,
        kLeftMenu_Statistic,
        kLeftMenu_Scheldule,
        kLeftMenu_LiveTv,
        kLeftMenu_Tips,
        kLeftMenu_Favorite,
        kLeftMenu_Setting,
        kLeftMenu_Related,
        kLeftMenu_Share,
        kLeftMenu_Review]
    fileprivate var searchViewController: UINavigationController!
    fileprivate var rateViewController: UINavigationController!
    fileprivate var statisticViewController: UINavigationController!
    fileprivate var tvSchelduleViewController: UINavigationController!
    fileprivate var liveTvViewController: UINavigationController!
    fileprivate var tipsViewController: UINavigationController!
    fileprivate var favoriteViewController: UINavigationController!
    fileprivate var settingViewController: UINavigationController!
    fileprivate var relatedViewController: UINavigationController!
    fileprivate var shareViewController: UINavigationController!
    fileprivate var reviewViewController: UINavigationController!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        // create search ViewController
        let searchVC = storyboard!.instantiateViewController(withIdentifier: "SearchViewController") as! SearchViewController
        
        searchViewController = UINavigationController(rootViewController: searchVC)
        
        // create rate Viewcontroller
        let rateVC =  storyboard!.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
        rateViewController = UINavigationController(rootViewController: rateVC)
        
        // create statistic ViewController
        let statisticVC =  storyboard!.instantiateViewController(withIdentifier: "StatisticViewController") as! StatisticViewController
        statisticViewController = UINavigationController(rootViewController: statisticVC)
        
        // create tvScheldule ViewController
        let tvSchelduleVC =  storyboard!.instantiateViewController(withIdentifier: "TVSchelduleViewController") as! TVSchelduleViewController
        tvSchelduleViewController = UINavigationController(rootViewController: tvSchelduleVC)
        
        // create liveTv View Controller
        let liveTvVC = L3sLiveTvViewController(nibName: "L3sLiveTvViewController", bundle: nil)
        liveTvViewController = UINavigationController(rootViewController: liveTvVC)
        
        // create tips ViewController
        let tipsVC =  L3sTipsViewController(nibName: "L3sTipsViewController", bundle: nil)
        tipsViewController = UINavigationController(rootViewController: tipsVC)
        
        // create favorite ViewController
        let favoriteVC = storyboard!.instantiateViewController(withIdentifier: "FavoriteViewController") as! FavoriteViewController
        favoriteViewController = UINavigationController(rootViewController: favoriteVC)
        
        // create setting ViewController
        let settingVc = storyboard!.instantiateViewController(withIdentifier: "SettingViewController") as! SettingViewController
        settingViewController = UINavigationController(rootViewController: settingVc)
        
        // create related ViewController
        let relatedVc = storyboard!.instantiateViewController(withIdentifier: "RelatedViewController") as! RelatedViewController
        relatedViewController = UINavigationController(rootViewController: relatedVc)
        
        // create share ViewController
        let shareVC = storyboard!.instantiateViewController(withIdentifier: "ShareViewController") as! ShareViewController
        shareViewController = UINavigationController(rootViewController: shareVC)
        
        // create review ViewController
        let reviewVC = ReviewViewController()
        reviewViewController = UINavigationController(rootViewController: reviewVC)
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        NotificationCenter.default.addObserver(self, selector: #selector(L3sLeftMenuViewController.reloadMenu), name: NSNotification.Name(rawValue: MENU), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()
        live3sAccount = Live3sAccount.getAccount()
        if live3sAccount.userName == "" {
            isLogin = false
        }else{
            isLogin = true
        }
    }
    func reloadMenu(){
        self.tableView.reloadData()
    }
    
    func loginFB(_ btn: UIButton) {
        FaceBookManager.shareManage.loginFacebook(self){ [unowned self] bool in
            self.isLogin = bool
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func changeViewController(_ menu: String, name: String) {
        switch menu {
        case "livescore":
           
            slideMenuController()?.changeMainViewController(matchViewController, close: true)
            let matchVC = matchViewController.viewControllers[0] as! MatchViewController
            let currentIndex = middleItem
            matchVC.headerScroll.selectedIndex = currentIndex
            matchVC.stringType = "Match"
            matchVC.screenType = 0
            matchVC.isShowFull = true
            matchVC.isLive = false
            matchVC.isByTime = false
            matchVC.reloadData(MatchListType.all,isByTime:false)

            break
        case "live":
            
            slideMenuController()?.changeMainViewController(matchViewController, close: true)
            let matchVC = matchViewController.viewControllers[0] as! MatchViewController
            let currentIndex = middleItem
            matchVC.headerScroll.selectedIndex = currentIndex
            matchVC.stringType = "Live"
            matchVC.screenType = 3
            matchVC.isShowFull = true
            matchVC.isLive = true
            matchVC.isByTime = false
            matchVC.reloadData(MatchListType.live,isByTime:false)
            break
        case "fixtures":
            
            slideMenuController()?.changeMainViewController(matchViewController, close: true)
            let matchVC = matchViewController.viewControllers[0] as! MatchViewController
            let currentIndex = middleItem
            matchVC.stringType = "Fixtures"
            matchVC.screenType = 1
            matchVC.isShowFull = true
            matchVC.isLive = false
            matchVC.isByTime = false
            matchVC.headerScroll.selectedIndex = currentIndex
            matchVC.reloadData(MatchListType.future,isByTime:false)
            break
        case "results":
            slideMenuController()?.changeMainViewController(matchViewController, close: true)
            let matchVC = matchViewController.viewControllers[0] as! MatchViewController
            let currentIndex = middleItem
            matchVC.headerScroll.selectedIndex = currentIndex
            matchVC.stringType = "Result"
            matchVC.screenType = 2
            matchVC.isLive = false
            matchVC.isShowFull = true
            matchVC.isByTime = false
             matchVC.reloadData(MatchListType.finish,isByTime: false)
            break
        case "search":
            slideMenuController()?.changeMainViewController(searchViewController, close: true)
            let controller = searchViewController.viewControllers[0] as! SearchViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "odds":
            slideMenuController()?.changeMainViewController(rateViewController, close: true)
            let controller = rateViewController.viewControllers[0] as! RateViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "standings":
            slideMenuController()?.changeMainViewController(statisticViewController, close: true)
            let controller = statisticViewController.viewControllers[0] as! StatisticViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "matchtv":
            slideMenuController()?.changeMainViewController(tvSchelduleViewController, close: true)
            let controller = tvSchelduleViewController.viewControllers[0] as! TVSchelduleViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "matchtv":
            slideMenuController()?.changeMainViewController(liveTvViewController, close: true)
            let controller = liveTvViewController.viewControllers[0] as! L3sLiveTvViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "tips":
            slideMenuController()?.changeMainViewController(tipsViewController, close: true)
            let controller = tipsViewController.viewControllers[0] as! L3sTipsViewController
            controller.title = name
            controller.isShowFull = true
            break
        case "favourite":
            slideMenuController()?.changeMainViewController(favoriteViewController, close: true)
            let controller = favoriteViewController.viewControllers[0] as! FavoriteViewController
            controller.isShowFull = true
            controller.title = name
            break
        case "language":
            slideMenuController()?.changeMainViewController(settingViewController, close: true)
            let controller = settingViewController.viewControllers[0] as! SettingViewController
            controller.title = name
            break
        case "relatedapps":
            slideMenuController()?.changeMainViewController(relatedViewController, close: true)
            let controller = relatedViewController.viewControllers[0] as! RelatedViewController
            controller.title = name
            break
        case "share":
            slideMenuController()?.changeMainViewController(shareViewController, close: true)
            let controller = shareViewController.viewControllers[0] as! ShareViewController
            controller.title = name
            break
        case "review":
            let url = URL(string:L3sAppDelegate.linkRateApp)
            UIApplication.shared.openURL(url!)
        default:
            return
        }
    }
    
}

/// L3sLefMenuViewController Extensions

extension L3sLeftMenuViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let code = AL0604.currentLanguage
        guard let realm = try? Realm(),
            let menu = realm.objectForPrimaryKey(MenuList.self, key: code) else {return 0}
        return menu.menuItem.count + 1

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeftMenuCell") as! LefMenuTableViewCell
        let code = AL0604.currentLanguage
        cell.btnLogin.isHidden = true
        cell.avatarImageView.isHidden = false
        cell.detailLabel.isHidden = false
        let indexData = (indexPath as NSIndexPath).row - 1
            if (indexPath as NSIndexPath).row != 0 {
                cell.selectionStyle = .default
                guard let realm = try? Realm(),
                    let menu = realm.objectForPrimaryKey(MenuList.self, key: code),
                    let item = menu.menuItem.filter({$0.index == indexData}).first else {return cell}
                cell.configCell(item)
            }else{
                cell.selectionStyle = .none
                if isLogin{
                    let url = URL(string: live3sAccount.imageUrl)
                    cell.avatarImageView.af_setImageWithURL(url!)
                    let myString = NSMutableAttributedString(string: "\(live3sAccount.userName)     ")
                    let myAttributes1 = [ NSForegroundColorAttributeName: UIColor(rgba: "#fab719")]
                    let stringGold = "\(live3sAccount.userGold) Gold"
                    let attrString3 = NSAttributedString(string: stringGold, attributes: myAttributes1)
                    myString.append(attrString3)
                    cell.detailLabel.attributedText = myString
                    cell.btnLogin.isHidden = true
                    cell.avatarImageView.isHidden = false
                    cell.detailLabel.isHidden = false
                }else{
                    cell.btnLogin.isHidden = false
                    cell.avatarImageView.isHidden = true
                    cell.detailLabel.isHidden = true
                }
                cell.btnLogin.addTarget(self, action: #selector(L3sLeftMenuViewController.loginFB(_:)), for: .touchUpInside)
            }
        
        return cell
    }
}

extension L3sLeftMenuViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let code = AL0604.currentLanguage
        var indexData = 0
            indexData = (indexPath as NSIndexPath).row - 1
            if (indexPath as NSIndexPath).row == 0{return}
        guard let realm = try? Realm(),
            let menu = realm.objectForPrimaryKey(MenuList.self, key: code),
            let item = menu.menuItem.filter({$0.index == indexData}).first else {return}
            changeViewController(item.iconUrl, name: item.name)

    }
}

class LefMenuTableViewCell: UITableViewCell {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var detailLabel: UILabel!
    @IBOutlet weak var btnLogin: UIButton!
    
    func configCell(_ menu: MenuModule) {
        avatarImageView.image = UIImage(named: menu.module)
        detailLabel.text = menu.name
    }
    func configCell(_ menu: Menu?) {
        guard let menu = menu else {return}
        avatarImageView.image = UIImage(named: menu.iconUrl)
        detailLabel.text = menu.name
        layoutSubviews()
    }
}
