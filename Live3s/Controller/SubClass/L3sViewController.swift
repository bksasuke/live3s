//
//  L3sViewController.swift
//  Live3s
//
//  Created by phuc nguyen on 11/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import GoogleMobileAds


class L3sViewController: UIViewController {

    var isShowNavigationBarMenu = false
    var items: Array<String>?
    var menuView: L3sNavigationDropDownMenu!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 0.0/255.0, green:180/255.0, blue:220/255.0, alpha: 1.0)
        self.navigationController?.navigationBar.barTintColor = UIColor.orange
        let navigationBarBg = UIImage(named: "bg_navigationBar.png")
        self.navigationController?.navigationBar.setBackgroundImage(navigationBarBg, for: .default)
        if isShowNavigationBarMenu {
            guard let items = self.items else {
                fatalError("items cannot be nil")
            }
            
            menuView = L3sNavigationDropDownMenu(title: AL0604.localization(items.first!), items: items, navigationController: self.navigationController!)
            menuView.cellHeight = 50
            menuView.cellBackgroundColor = UIColor.black
            menuView.cellSelectionColor = UIColor.gray
            menuView.cellTextLabelColor = UIColor.white
            menuView.cellTextLabelFont = UIFont.systemFont(ofSize: 18)
            menuView.arrowPadding = 15
            menuView.animationDuration = 0.5
            menuView.maskBackgroundColor = UIColor.black
            menuView.maskBackgroundOpacity = 0.3
            menuView.didSelectItemAtIndexHandler = {[unowned self](indexPath: Int) -> () in
                self.didSelectNavigationBarMenuItemAtIndex(indexPath)
            }
            menuView.willShowMenuHandler = { [unowned self] in
                self.willShowDropdownMenu()
            }
            
            menuView.willHideMenuHandler = { [unowned self] in
                self.willHideDropdownMenu()
            }
            self.navigationItem.titleView = menuView
        }
        
         
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if isShowNavigationBarMenu {
            menuView.layoutSubviews()
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /**
     Override to handle select item at indexpath
     
     - parameter index: the index of item
     */
    func didSelectNavigationBarMenuItemAtIndex(_ index: Int) {
        
    }
    /**
     Override to handle will show menu
     */
    func willShowDropdownMenu() {
    
    }
    /**
     Override to handle will hide menu
     */
    func willHideDropdownMenu() {
    
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
