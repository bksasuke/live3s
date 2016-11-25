//
//  TimeManager.swift
//  Live3s
//
//  Created by phuc on 12/28/15.
//  Copyright © 2015 com.phucnguyen. All rights reserved.
//

import Foundation

let KEY_LIVE_SCORE_DID_UPDATE = "Applicatin did update live score"

class TimeManager:NSObject {
    static var shareManager = TimeManager()
    fileprivate var isPause = false
    fileprivate var timer: Timer!
    fileprivate var liveTimer: Timer!
    fileprivate var runningBlock: (()-> Void)?
    
    override init() {
        super.init()
        startLiveTimer()
    }
    
    func startLiveTimer() {
        liveTimer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(TimeManager.liveTimerRunning), userInfo: nil, repeats: true)
        RunLoop.current.add(liveTimer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func liveTimerRunning() {
        NetworkService.getAllMatchs(.live,isByTime: false) { (matchs, error) -> () in
            if error == nil {
                guard let aMatchs = matchs else {
                      NotificationCenter.default.post(name: Notification.Name(rawValue: KEY_LIVE_SCORE_DID_UPDATE), object: 0)
                    return
                }
                var count = 0
                    let  anonymous = aMatchs.first
                    if ((anonymous as? LeagueModule) != nil) {
                        for league in aMatchs{
                            let leag = league as! LeagueModule
                            count += Int(leag.matchs.count)
                        }
                    }
                    if  ((anonymous as? MatchModule) != nil) {
                        if aMatchs.count > 0{
                            count = aMatchs.count
                        }
                        
                        
                        
                    }

                
                
                NotificationCenter.default.post(name: Notification.Name(rawValue: KEY_LIVE_SCORE_DID_UPDATE), object: count)
            }
        }
    }
    
    func startwithblock(_ block: @escaping () -> Void) {
        runningBlock = block
        timer = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(TimeManager.running), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func pause() {
        isPause = true
    }
    
    func resume() {
        isPause = false
    }
    
    func stop() {
        if timer == nil {return}
        timer.invalidate()
        timer = nil
    }
    @objc func running() {
        if isPause {return}
        runningBlock?()
    }
}
