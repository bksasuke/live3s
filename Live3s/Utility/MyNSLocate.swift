//
//  MyNSLocate.swift
//  Live3s
//
//  Created by codelover2 on 06/05/2016.
//  Copyright © 2016 com.phucnguyen. All rights reserved.
//

import Foundation

extension Locale {
    static func locales1(_ countryName1 : String) -> String {
        let locales : String = ""
        for localeCode in Locale.isoRegionCodes {
            let countryName = (Locale.system as NSLocale).displayName(forKey: NSLocale.Key.countryCode, value: localeCode)!
            if countryName1.lowercased() == countryName.lowercased() {
                return localeCode 
            }
        }
        return locales
    }
    
    
}
