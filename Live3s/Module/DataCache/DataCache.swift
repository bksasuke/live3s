//
//  DataCache.swift
//  Live3s
//
//  Created by codelover2 on 10/05/2016.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import Foundation
import CoreData


class DataCache: NSManagedObject {

// Insert code here to add functionality to your managed object subclass

    // Insert code here to add functionality to your managed object subclass
    
    static func findByID(_ sUrl: String) -> DataCache? {
        let fetchRequest = NSFetchRequest()
        let entityDes = NSEntityDescription.entity(forEntityName: "DataCache", in: L3sAppDelegate.managedObjectContext)
        fetchRequest.entity = entityDes
        fetchRequest.predicate = NSPredicate(format: "urlCache = %@", sUrl)
        let result = try! L3sAppDelegate.managedObjectContext.fetch(fetchRequest)
        if result.count > 0 {
            return result.first as? DataCache
        } else {
            return createDataCacheDefault(sUrl)
        }
        
    }
    
    static func saveData(_ cache: DataCache) -> Bool {
        if let dataCache = DataCache.findByID(cache.urlCache!) {
            dataCache.urlCache = cache.urlCache!
            dataCache.dataCache = cache.dataCache!
            dataCache.addedTime = cache.addedTime!
            dataCache.timeCache = cache.timeCache!
            try! L3sAppDelegate.managedObjectContext.save()
            return true
        } else {
            let entity = NSEntityDescription.entity(forEntityName: "DataCache", in: L3sAppDelegate.managedObjectContext)
            let dataCache = NSManagedObject(entity: entity!, insertInto: L3sAppDelegate.managedObjectContext) as! DataCache
            dataCache.urlCache = cache.urlCache!
            dataCache.dataCache = cache.dataCache!
            dataCache.addedTime = cache.addedTime!
            dataCache.timeCache = cache.timeCache!
            try! L3sAppDelegate.managedObjectContext.save()
            return true
        }
    }

    static func createDataCacheDefault(_ sUrl: String) -> DataCache{
        let entity = NSEntityDescription.entity(forEntityName: "DataCache", in: L3sAppDelegate.managedObjectContext)
        let defaultDataCache = NSManagedObject(entity: entity!, insertInto: L3sAppDelegate.managedObjectContext) as! DataCache
        defaultDataCache.urlCache = ""
        defaultDataCache.dataCache = nil
        defaultDataCache.addedTime = 0
        defaultDataCache.timeCache = 0
        try! L3sAppDelegate.managedObjectContext.save()
        return defaultDataCache
    }

}
