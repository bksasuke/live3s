//
//  RelatedViewController.swift
//  Live3s
//
//  Created by codelover2 on 13/12/2015.
//  Copyright © Năm 2015 com.phucnguyen. All rights reserved.
//

import Foundation
import UIKit
import GoogleMobileAds

class RelatedViewController : L3sViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var bannerView: GADBannerView?
    var appArray:[RelatedAppOBJ] = [RelatedAppOBJ](){
        didSet {
            tableView.reloadData()
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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let tracker = GAI.sharedInstance().defaultTracker
        tracker?.set(kGAIScreenName, value: "Related App")
        
        let builder = GAIDictionaryBuilder.createScreenView()
        tracker?.send(builder?.build() as [AnyHashable: Any])
        
        self.addAvertising()
        LoadingView.sharedInstance.showLoadingView(view)
        getRelatedAppFromServer()
        
    }
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.separatorStyle = .none
      
        
        super.viewDidLoad()
        addLeftBarButtonWithImage(UIImage(named: "icon_menu.png")!)
        
        // Do any additional setup after loading the view.
    }
    func getRelatedAppFromServer() {
        if isReloadingData {return}
        isReloadingData = true
        NetworkService.getRelatedApp { (relatedApps, error) -> Void in
            if error == nil {
                if let array = relatedApps {
                    self.appArray = array
                }

            }else{
                 self.isReloadingData = false
            }
        }
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
}
// MARK - Tableview Datasource
extension RelatedViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
            return appArray.count;
       
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RelatedCell") as! RelatedTablewViewCell
         let obj:RelatedAppOBJ = appArray[(indexPath as NSIndexPath).row]
            cell.titleApp.text = obj.name
        if let urlString: String = obj.icon {
            let url = URL(string: urlString)!
           cell.iconApp.af_setImageWithURL(url)
        }
        if (indexPath as NSIndexPath).row % 2 == 0{
            cell.backgroundColor = UIColor.white
            
        }else{
            cell.backgroundColor = UIColor(rgba: "#f5f5f5")
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let obj:RelatedAppOBJ = appArray[(indexPath as NSIndexPath).row]
        let url = URL(string:obj.link)
        UIApplication.shared.openURL(url!)

    }

}

// MARK - Reladted TableViewCell

class RelatedTablewViewCell: UITableViewCell {
    
    @IBOutlet weak var iconApp: UIImageView!
    @IBOutlet weak var titleApp: UILabel!
}
