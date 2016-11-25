//
//  MatchModle.swift
//  Live3s
//
//  Created by phuc on 1/16/16.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import Foundation
import CoreData


class MatchModle: NSManagedObject {

// Insert code here to add functionality to your managed object subclass
    static func findByID(_ sid: String) -> MatchModle? {
        let fetchRequest = NSFetchRequest()
        let entityDes = NSEntityDescription.entity(forEntityName: "MatchModle", in: L3sAppDelegate.managedObjectContext)
        fetchRequest.entity = entityDes
        fetchRequest.predicate = NSPredicate(format: "id = %@ AND language_code = %@", sid, AL0604.currentLanguage)
        let result = try! L3sAppDelegate.managedObjectContext.fetch(fetchRequest)
        if result.count > 0 {
            return result.first as? MatchModle
        } else {
            return nil
        }
        
    }
    
    static func allsavedMatch() -> [MatchModle] {
        let fetchRequest = NSFetchRequest(entityName: "MatchModle")
        var result: [MatchModle] = try! L3sAppDelegate.managedObjectContext.fetch(fetchRequest) as! [MatchModle]
        for match in result {
            if let startTime = match.time_start?.doubleValue {
                if (startTime < (Date().timeIntervalSince1970 - 7200.0)) {
                    result.removeObject(match)
                    L3sAppDelegate.managedObjectContext.delete(match)
                }
            }
        }
        try! L3sAppDelegate.managedObjectContext.save()
        return result.filter({$0.language_code == AL0604.currentLanguage})
    }
    
    static func saveMatch(_ match: MatchModule) -> Bool {
        if let savedMatch = MatchModle.findByID(match.id) {
            L3sAppDelegate.managedObjectContext.delete(savedMatch)
            return false
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "MatchModle", in: L3sAppDelegate.managedObjectContext)
            let savedmatch = NSManagedObject(entity: entity!, insertInto: L3sAppDelegate.managedObjectContext) as! MatchModle
            savedmatch.id = match.id
            savedmatch.season_id = match.season_id
            savedmatch.away_club_name = match.away_club_name
            savedmatch.away_logo = match.away_club_image
            savedmatch.away_goal = match.away_goal
            savedmatch.home_club_name = match.home_club_name
            savedmatch.home_logo = match.home_club_image
            savedmatch.home_goal = match.home_goal
            savedmatch.home_goalH1 = match.home_goalH1
            savedmatch.away_goalH1 = match.away_goalH1
            savedmatch.time_start = match.time_start
            savedmatch.isFinish = Int(match.is_finish)
            savedmatch.isPosponse = Int(match.is_postponed)
            savedmatch.status = ""
            savedmatch.memo = match.memo
            savedmatch.language_code = AL0604.currentLanguage
            try! L3sAppDelegate.managedObjectContext.save()
            return true
        }
    }
}

extension RangeReplaceableCollection where Iterator.Element : Equatable {
    
    // Remove first collection element that is equal to the given `object`:
    mutating func removeObject(_ object : Iterator.Element) {
        if let index = self.index(of: object) {
            self.remove(at: index)
        }
    }
}
