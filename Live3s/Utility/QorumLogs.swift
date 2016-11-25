//
//  QorumLogs.swift
//  Qorum
//
//  Created by Goktug Yilmaz on 27/08/15.
//  Copyright (c) 2015 Goktug Yilmaz. All rights reserved.
//

import Foundation

#if os(OSX)
    import Cocoa //TODO: Check if this works on OSX apps, maybe use NSColor?
#elseif os(iOS)
    import UIKit
#endif

public struct QorumLogs {
    /// While enabled QorumOnlineLogs does not work
    public static var enabled = false
    /// 1 to 4
    public static var minimumLogLevelShown = 1
    /// Change the array element with another UIColor. 0 is info gray, 5 is purple, rest are log levels
    public static var colorsForLogLevels: [UIColor] = [
        UIColor(redC: 120, greenC: 120, blueC: 120), //0
        UIColor(redC: 0, greenC: 180, blueC: 180),  //1
        UIColor(redC: 0, greenC: 150, blueC: 0),  //2
        UIColor(redC: 255, greenC: 190, blueC: 0), //3
        UIColor(redC: 255, greenC: 0, blueC: 0),   //4
        UIColor(redC: 160, greenC: 32, blueC: 240)] //5
    fileprivate static var showFile: String?

    //==========================================================================================================
    // MARK: - Public Methods
    //==========================================================================================================

    /// Ignores all logs from other files
    public static func onlyShowThisFile<T>(_ fileName: T) {
        minimumLogLevelShown = 1
        if let name = fileName as? String {
            showFile = name
            print(ColorLog.colorizeString("QorumLogs: Only Showing: \(name)", colorId: 5))
            return
        }

        var classString = ""
        if let obj: AnyObject = fileName as? AnyObject {
            classString = String(describing: type(of: obj))
        } else {
            classString = String(describing: fileName)
        }
        let classStringWithoutPrefix = classString.ns.pathExtension
        showFile = classStringWithoutPrefix
        print(ColorLog.colorizeString("QorumLogs: Only Showing: \(classStringWithoutPrefix)", colorId: 5))
    }

    /// Test to see if its working
    public static func test() {
        let oldDebugLevel = minimumLogLevelShown
        minimumLogLevelShown = 1
        QL1("Debug")
        QL2("Info")
        QL3("Warning")
        QL4("Error")
        minimumLogLevelShown = oldDebugLevel
    }

    //==========================================================================================================
    // MARK: - Private Methods
    //==========================================================================================================

    fileprivate static func shouldPrintLine(level: Int, fileName: String) -> Bool {
        if !QorumLogs.enabled {
            return false
        } else if QorumLogs.minimumLogLevelShown <= level {
            if showFile == nil {
                return true
            } else {
                if showFile == fileName {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }

}

public struct QorumOnlineLogs {
    fileprivate static let appVersion = versionAndBuild()
    fileprivate static var googleFormLink: String!
    fileprivate static var googleFormAppVersionField: String!
    fileprivate static var googleFormUserInfoField: String!
    fileprivate static var googleFormMethodInfoField: String!
    fileprivate static var googleFormErrorTextField: String!
    /// Online logs does not work while QorumLogs is enabled
    public static var enabled = false
    /// 1 to 4
    public static var minimumLogLevelShown = 1
    /// Empty dictionary, add extra info like user id, username here
    public static var extraInformation = [String: String]()

    //==========================================================================================================
    // MARK: - Public Methods
    //==========================================================================================================

    /// Test to see if its working
    public static func test() {
        let oldDebugLevel = minimumLogLevelShown
        minimumLogLevelShown = 1
        QL1("Debug")
        QL2("Info")
        QL3("Warning")
        QL4("Error")
        minimumLogLevelShown = oldDebugLevel
    }

    /// Setup Google Form links
    public static func setupOnlineLogs(formLink: String, versionField: String, userInfoField: String, methodInfoField: String, textField: String) {
        googleFormLink = formLink
        googleFormAppVersionField = versionField
        googleFormUserInfoField = userInfoField
        googleFormMethodInfoField = methodInfoField
        googleFormErrorTextField = textField
    }

    //==========================================================================================================
    // MARK: - Private Methods
    //==========================================================================================================

    fileprivate static func sendError<T>(classInformation: String, textObject: T, level: String) {
        var text = ""
        if let stringObject = textObject as? String {
            text = stringObject
        }
        let versionLevel = (appVersion + " - " + level)

        let url = URL(string: googleFormLink)
        var postData = googleFormAppVersionField + "=" + versionLevel
        postData += "&" + googleFormUserInfoField + "=" + extraInformation.description
        postData += "&" + googleFormMethodInfoField + "=" + classInformation
        postData += "&" + googleFormErrorTextField + "=" + text

        let request = NSMutableURLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = postData.data(using: String.Encoding.utf8)
        NSURLConnection(request: request as URLRequest, delegate: nil)?.start()

        let printText = "OnlineLogs: \(extraInformation.description) - \(versionLevel) - \(classInformation) - \(text)"
        print(" \(ColorLog.colorizeString(printText, colorId: 5))\n", terminator: "")
    }

    fileprivate static func shouldSendLine(level: Int, fileName: String) -> Bool {
        if !QorumOnlineLogs.enabled {
            return false
        } else if QorumOnlineLogs.minimumLogLevelShown <= level {
            if QorumLogs.showFile == nil {
                return true
            } else {
                if QorumLogs.showFile == fileName {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }

}

///Detailed logs only used while debugging
public func QL1<T>(_ debug: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let level = 1
    let levelText = "1Debug"
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: debug, level: level)
    } else if QorumOnlineLogs.shouldSendLine(level: level, fileName: filename) {
        let informationPart = "()\(filename).\(function)[\(line)]"
        QorumOnlineLogs.sendError(classInformation: informationPart, textObject: debug, level: levelText)
    }
}

///General information about app state
public func QL2<T>(_ info: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let level = 2
    let levelText = "2Info"
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: info, level: level)
    } else if QorumOnlineLogs.shouldSendLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]"
        QorumOnlineLogs.sendError(classInformation: informationPart, textObject: info, level: levelText)
    }
}

///Indicates possible error
public func QL3<T>(_ warning: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let level = 3
    let levelText = "3Warning"
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: warning, level: level)
    } else if QorumOnlineLogs.shouldSendLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]"
        QorumOnlineLogs.sendError(classInformation: informationPart, textObject: warning, level: levelText)
    }
}

///En unexpected error occured
public func QL4<T>(_ error: T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let level = 4
    let levelText = "4Error"
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: error, level: level)
    } else if QorumOnlineLogs.shouldSendLine(level: level, fileName: filename) {
        let informationPart = "\(filename).\(function)[\(line)]"
        QorumOnlineLogs.sendError(classInformation: informationPart, textObject: error, level: levelText)
    }
}

private func printLog<T>(_ informationPart: String, text: T, level: Int) {
    print(" \(ColorLog.colorizeString(informationPart, colorId: 0))", terminator: "")
    print(" \(ColorLog.colorizeString(text, colorId: level))\n", terminator: "")
}

///=====
public func QLShortLine(_ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: 2, fileName: filename) {
        let lineString = "====================================="
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: lineString, level: 5)
    }
}

///+++++
public func QLPlusLine(_ file: String = #file, _ function: String = #function, _ line: Int = #line) {
    let filename = file.ns.lastPathComponent.ns.deletingPathExtension
    if QorumLogs.shouldPrintLine(level: 2, fileName: filename) {
        let lineString = "+++++++++++++++++++++++++++++++++++++"
        let informationPart = "\(filename).\(function)[\(line)]:"
        printLog(informationPart, text: lineString, level: 5)
    }
}

private struct ColorLog {
    fileprivate static let ESCAPE = "\u{001b}["
    fileprivate static let RESET_FG = ESCAPE + "fg;" // Clear any foreground color
    fileprivate static let RESET_BG = ESCAPE + "bg;" // Clear any background color
    fileprivate static let RESET = ESCAPE + ";"      // Clear any foreground or background color

    static func colorizeString<T>(_ object: T, colorId: Int) -> String {
        return "\(ESCAPE)fg\(QorumLogs.colorsForLogLevels[colorId].redC),\(QorumLogs.colorsForLogLevels[colorId].greenC),\(QorumLogs.colorsForLogLevels[colorId].blueC);\(object)\(RESET)"
    }
}

private func versionAndBuild() -> String {
    let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    return version == build ? "v\(version)" : "v\(version)(\(build))"
}

private extension String {
    /// Qorum Extension
    var ns: NSString {
        return self as NSString
    }
}

private extension UIColor {
    convenience init(redC: CGFloat, greenC: CGFloat, blueC: CGFloat) {
        self.init(red: redC / 255.0, green: greenC / 255.0, blue: blueC / 255.0, alpha: 1)
    }
    var redC: Int {
        var r: CGFloat = 0
        getRed(&r, green: nil, blue: nil, alpha: nil)
        return Int(r * 255)
    }
    var greenC: Int {
        var g: CGFloat = 0
        getRed(nil, green: &g, blue: nil, alpha: nil)
        return Int(g * 255)
    }
    var blueC: Int {
        var b: CGFloat = 0
        getRed(nil, green: nil, blue: &b, alpha: nil)
        return Int(b * 255)
    }
}
