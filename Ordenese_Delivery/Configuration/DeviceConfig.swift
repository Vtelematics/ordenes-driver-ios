//
//  DeviceConfig.swift
//  PreeSwift
//
//  Created by eph132 on 18/08/15.
//  Copyright © 2015 prem. All rights reserved.
//

import Foundation
import UIKit

enum UIUserInterfaceIdiom : Int
{
    case Unspecified
    case Phone
    case Pad
}

extension NSIndexSet {
    func toArray() -> [Int] {
        var indexes:[Int] = [];
        self.enumerate({ (index:Int, _) in
            indexes.append(index);
        })
        return indexes;
    }
}

extension NSMutableArray
{
    
    func sw_addNewUtilityButtonWithColor(color : UIColor, title : String)
    {
        let button = UIButton();
        //button.buttonType = UIButtonType.Custom;
        button.backgroundColor = color;
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitle(title, for: .normal)
        button.titleLabel?.adjustsFontSizeToFitWidth;
        self.add(button)
    }
}

extension NSDate
{
    /*
    func yearsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Year, fromDate: date, toDate: self, options: []).year
    }
    func monthsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Month, fromDate: date, toDate: self, options: []).month
    }
    func weeksFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.WeekOfYear, fromDate: date, toDate: self, options: []).weekOfYear
    }
    func daysFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Day, fromDate: date, toDate: self, options: []).day
    }
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Hour, fromDate: date, toDate: self, options: []).hour
    }
    func minutesFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Minute, fromDate: date, toDate: self, options: []).minute
    }
    func secondsFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar.components(.Second, fromDate: date, toDate: self, options: []).second
    }
    func offsetFrom(date:NSDate) -> String {
        if yearsFrom(date: date)   > 0 { return "\(yearsFrom(date: date))y"   }
        if monthsFrom(date: date)  > 0 { return "\(monthsFrom(date: date))M"  }
        if weeksFrom(date: date)   > 0 { return "\(weeksFrom(date: date))w"   }
        if daysFrom(date: date)    > 0 { return "\(daysFrom(date: date))d"    }
        if hoursFrom(date: date)   > 0 { return "\(hoursFrom(date: date))h"   }
        if minutesFrom(date: date) > 0 { return "\(minutesFrom(date: date))m" }
        if secondsFrom(date: date) > 0 { return "\(secondsFrom(date: date))s" }
        return ""
    }
    */
}

extension UIImage {
    var uncompressedPNGData: NSData      { return self.pngData() as NSData?        ?? NSData() }
    var highestQualityJPEGNSData: NSData { return self.jpegData(compressionQuality: 1.0) as NSData?  ?? NSData() }
    var highQualityJPEGNSData: NSData    { return self.jpegData(compressionQuality: 0.75) as NSData? ?? NSData() }
    var mediumQualityJPEGNSData: NSData  { return self.jpegData(compressionQuality: 0.5) as NSData?  ?? NSData() }
    var lowQualityJPEGNSData: NSData     { return self.jpegData(compressionQuality: 0.25) as NSData? ?? NSData() }
    var lowestQualityJPEGNSData:NSData   { return self.jpegData(compressionQuality: 0.0) as NSData?  ?? NSData() }
    var preeThumpImageCompression:NSData   {
        
        return self.jpegData(compressionQuality: 0.0) as NSData?  ?? NSData()
    
    }
}
extension Int
{
public func currencyString(_ decimals: Int) -> String {
    
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.maximumFractionDigits = decimals
    return formatter.string(from: NSNumber(value: decimals))!
}
}

/*
extension Int {
    var asLocaleCurrency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = NSLocale.current
        return formatter.stringFromNumber(NSNumber(self))!
    }
}
*/

struct ScreenSize
{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}

struct ConfigUrl
{    
    static let baseUrl = "https://www.ordenesdelivery.com/api/driver/"
    static let imageUrl = ""
}

struct ConfigTheme
{
    static var themeMode = "Dark"
    static var textColor = "#13A920"
    static var borderColor = "#00FF00"
    static var backgroundColor = "#3C0158"
}

struct DeviceType
{
    static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
    static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
    static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
    static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
    static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024.0
}

extension UIView{
    func dropShadow(cornerRadius : CGFloat, opacity : Float, radius: CGFloat) {
        layer.masksToBounds = false
        layer.rasterizationScale = UIScreen.main.scale
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOpacity = opacity
        layer.shadowOffset = CGSize.zero
        layer.shadowRadius = radius
    }
}
    
