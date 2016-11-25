//
//  AppDelegate.swift
//  Live3s
//
//  Created by phuc nguyen on 11/30/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Whisper

let kAppVersion = "KAPPVERSION"

let L3sAppDelegate = UIApplication.shared.delegate as! AppDelegate
// Do any additional setup after loading the view.
let storyboard = UIStoryboard(name: "Main", bundle: nil)
let UPDATE_DATA = "UpdateData"
let ADD_AD = "ADD_AD"
let MENU = "menu"
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, TAGContainerOpenerNotifier {

    var isfirstTime = true
    var window: UIWindow?
    internal var arrayUpdate:[MatchUpdateOBJ] = [MatchUpdateOBJ]()
    internal var linkRateApp: String = String()
    internal var checkUpdateModel: CheckUpdateModule?
    internal var adBanner: AdModulde?
    internal var adFull: AdModulde?
    internal var menuEN: [MenuModule]?
    internal var menuVI: [MenuModule]?
    internal var menuFR: [MenuModule]?
    fileprivate var updateTimer: Timer!
    fileprivate var alertUpdate: UIAlertView!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Configure tracker from GoogleService-Info.plist.
        // Configure tracker from GoogleService-Info.plist.
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        
        // Optional: configure GAI options.
        let gai = GAI.sharedInstance()
        gai?.trackUncaughtExceptions = true  // report uncaught exceptions
        gai?.logger.logLevel = GAILogLevel.verbose  // remove before app release
        
        QorumLogs.enabled = true
        QorumLogs.test()
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        showLoadingScreen()
        return true
    }
    func containerAvailable(_ container: TAGContainer!) {
        container.refresh()
    }
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        if self.checkUpdateModel != nil{
            if self.checkUpdateModel?.app_version != self.checkUpdateModel?.must_update{
                getAdvertising()
                
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if self.checkUpdateModel == nil{
        self.getAdvertising()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveContext()
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//        if url.absoluteString.containsString("com.emobi.live3s") {
//            return GPPURLHandler.handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
//        }
        return FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    // MARK: - Notification delegate
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.hexString
        NotificationService.shareInstance.registerDevietokenForPushServer(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        let randomToken = "4facaa161da3300a3db74d514c11c0aa"
        NotificationService.shareInstance.registerDevietokenForPushServer(randomToken)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        // private func to get top viewcontroller
        func topWindow() -> UIViewController? {
            guard let topController = UIApplication.shared.keyWindow?.rootViewController,
                let nav = topController.slideMenuController()?.mainViewController as? UINavigationController else {return nil}
            return nav.viewControllers[0]
        }
        
        QL2(userInfo)
        if let data = userInfo["aps"]!["data"] as? NSDictionary{
             QL2(data)
            QL2(data["type"])
            let module = PushNotificationModule(data: data)
            if application.applicationState == UIApplicationState.active {
                // show custom banner
                let image = UIImage(named: "icon.png")
                let announcement = Announcement(title: module.title, subtitle: module.message, image: image, duration: 5, action: { () -> Void in
                    
                    if module.push_type == "link" {
                        let url = NSURL(string:module.app_link)
                        UIApplication.sharedApplication().openURL(url!)
                    }else if module.push_type == "match"{
                        if let viewcontrollertoShout = topWindow() {
                            let matchDetailVC = L3sMatchDetailViewController(nibName: "L3sMatchDetailViewController", bundle: nil)
                            let match:MatchModule = MatchModule(matchPush: module)
                            matchDetailVC.match = match
                            viewcontrollertoShout.navigationController?.pushViewController(matchDetailVC, animated: true)
                        }
                    }else if module.push_type == "standing"{
                        if let viewcontrollertoShout = topWindow() {
                            let detailVC =  storyboard.instantiateViewControllerWithIdentifier("DetailStatisticViewController") as! DetailStatisticViewController
                            detailVC.leagueID = module.league_id
                            detailVC.urlLogo = module.league_logo
                            detailVC.isRank = true
                            detailVC.isMatch = false
                            detailVC.isIndex = false
                            viewcontrollertoShout.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    }else if module.push_type == "topscore"{
                        if let viewcontrollertoShout = topWindow() {
                            let detailVC =  storyboard.instantiateViewControllerWithIdentifier("DetailStatisticViewController") as! DetailStatisticViewController
                            detailVC.leagueID = module.league_id
                            detailVC.urlLogo = ""
                            detailVC.isRank = false
                            detailVC.isMatch = false
                            detailVC.isIndex = true
                            viewcontrollertoShout.navigationController?.pushViewController(detailVC, animated: true)
                        }
                    }else{
                        // Chỉ hiển thị message ko làm gì hết
                    }
                })
                guard let viewcontrollertoShout = topWindow() else {return}
                Shout(announcement, to: viewcontrollertoShout)
            } else {
                
            }

        }
    }
    
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.plymouthsoftware.core_data" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Live3sDB", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        
        
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Live3sDB.sqlite")
        deleteOldDB(url)
        QL2("setup core data stack at path: \(url)")
        var failureReason = "There was an error creating or loading the application's saved data."
        let option = [NSMigratePersistentStoresAutomaticallyOption: true,
                      NSInferMappingModelAutomaticallyOption: true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: option)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    func topWindow() -> UIViewController? {
        guard let topController = UIApplication.shared.keyWindow?.rootViewController,
            let nav = topController.slideMenuController()?.mainViewController as? UINavigationController else {return nil}
        return nav.viewControllers[0]
    }

    
    
    

    func getAdvertising(){
        NetworkService.getAdvertising { (checkUpdateModule, advertisings, error) -> Void in
            if error == nil {
                self.checkUpdateModel = checkUpdateModule?.first
                if self.checkUpdateModel?.app_version != self.checkUpdateModel?.must_update{
                    let message = AL0604.localization(LanguageKey.update_app_title) + " " +  (self.checkUpdateModel?.must_update)!
                    self.alertUpdate = UIAlertView(title: AL0604.localization(LanguageKey.update_app_title), message: message, delegate: self, cancelButtonTitle: "OK")
                    self.alertUpdate.show()

                }
                for dic: NSDictionary in advertisings!{
                    for (key, value) in dic {
                        if key as! String == "pos1"{
                            self.adBanner = value as? AdModulde
                        }else if key as! String == "pos2"{
                            self.adFull = value as? AdModulde
                        }
                    }
                }
                NotificationCenter.default.post(name: Notification.Name(rawValue: ADD_AD), object: nil)
            }
        }
    }
    
}

extension AppDelegate: UIAlertViewDelegate{
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView == alertUpdate{
            let url = URL(string:(self.checkUpdateModel?.link)!)
            UIApplication.shared.openURL(url!)
        }
    }
    
    func showApp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let leftViewController = storyboard.instantiateViewController(withIdentifier: "L3sLeftMenuViewController") as! L3sLeftMenuViewController
        let rightViewController = L3sRightViewController(nibName: "L3sRightViewController", bundle: nil)
        /// MatchViewController
        let matchViewController = storyboard.instantiateViewController(withIdentifier: "MatchViewController") as! MatchViewController
        let nvc: UINavigationController = UINavigationController(rootViewController: matchViewController)
        UINavigationBar.appearance().tintColor = UIColor.black
        leftViewController.matchViewController = nvc
        
        let slideMenuController = L3sSlideMenuViewController(mainViewController: nvc, leftMenuViewController: leftViewController)
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
    }
    
    func showLoadingScreen() {
        let loadingScreen = DownloadViewController()
        loadingScreen.didFinishDownload = {
            self.showApp()
        }
        self.window?.rootViewController = loadingScreen
        self.window?.makeKeyAndVisible()
    }
    
}

extension Data {
    var hexString: String {
        let bytes = UnsafeBufferPointer<UInt8>(start: (self as NSData).bytes.bindMemory(to: UInt8.self, capacity: self.count), count:self.count)
        return bytes.map { String(format: "%02hhx", $0) }.reduce("", { $0 + $1 })
    }
}

func deleteOldDB(_ url: URL) {
    let oldversion = UserDefaults.standard.string(forKey: kAppVersion)
    if oldversion == nil {
        if FileManager.default.fileExists(atPath: url.absoluteString) {
            let _  = try? FileManager.default.removeItem(at: url)
        }
    }
}

//MARK: Download Screen

class DownloadViewController: UIViewController {
    
    var didFinishDownload: (()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let imageView = UIImageView(frame:UIScreen.main.bounds)
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "ls.png")
        view.addSubview(imageView)
        
        loadData()
    }
    
    fileprivate func loadData() {
        getRateAppLink()
        updateTimerRunning()
        DBManager.shareInstance
        L3sAppDelegate.updateTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(DownloadViewController.updateTimerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(L3sAppDelegate.updateTimer, forMode: RunLoopMode.defaultRunLoopMode)
        
        NotificationService.shareInstance.registerUserNotification()
        Language.create()
        NetworkService.requestLanguage() {
            self.didFinishDownload?()
        }
    }
    
    fileprivate func getRateAppLink() {
        NetworkService.getLinkRateApp { (strLink, error) -> Void in
            if error == nil {
                L3sAppDelegate.linkRateApp = strLink!
            }
        }
    }
    func updateTimerRunning() {
        L3sAppDelegate.arrayUpdate.removeAll()
        NetworkService.getUpdateMatch { (matchUpdate, error) -> Void in
            L3sAppDelegate.arrayUpdate = matchUpdate ?? [MatchUpdateOBJ]();
            NotificationCenter.default.post(name: Notification.Name(rawValue: UPDATE_DATA), object: nil)
        }
        
    }
}
