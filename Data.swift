//
//  Data.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Data: NSObject {
    // this is how you do singletons in swift
    class var sharedData: Data {
        get { return sharedInstance.sharedData }
    }
    private struct sharedInstance { static let sharedData = Data() }

    let defaults = NSUserDefaults.standardUserDefaults()
    var jargon: NSDictionary

    override init() {
        var path = NSBundle.mainBundle().pathForResource( "Settings", ofType: "plist" )
        let settings = NSDictionary( contentsOfFile: path! )

        path = NSBundle.mainBundle().pathForResource( "Jargon", ofType: "plist" )
        jargon = NSDictionary( contentsOfFile: path! )!

        defaults.registerDefaults( settings! as [NSObject : AnyObject] )
        super.init()
    }

    var mode: GameState.Mode {
        get { return GameState.Mode(rawValue: defaults.stringForKey( "Game Mode" )!)! }
        set { defaults.setValue( newValue.rawValue, forKey: "Game Mode" ) }
    }

    var modeName: String {
        get { return jargon.objectForKey( GameState.sharedState.mode.rawValue ) as! String }
    }

    var score: Int64 {
        get {
            return Int64( ( defaults.valueForKey( GameState.sharedState.mode.rawValue + " High Score" ) as! NSNumber).integerValue )
        }
        set {
            defaults.setValue( NSNumber(longLong: newValue + totalScore), forKey: "Total Score" )
            if newValue > score {
                defaults.setValue( NSNumber(longLong: newValue), forKey: GameState.sharedState.mode.rawValue + " High Score" )
            }
        }
    }

    var unlockedShirts: NSArray {
        get { return defaults.arrayForKey( "Unlocked Shirts" )! }
    }
    
    func unlockShirt( name: String, price: Int64 ) -> Void {
        var shirts = unlockedShirts.mutableCopy() as! NSMutableArray
        shirts.addObject( name )
        defaults.setValue( shirts, forKey: "Unlocked Shirts" )
        defaults.setValue( NSNumber(longLong: totalScore - price), forKey: "Total Score" )

        GCHelper.defaultHelper().reportAchievementIdentifier( name, percentComplete: 100 )
        let percentOfAllShirts = Float(shirts.count) / 10.0
        GCHelper.defaultHelper().reportAchievementIdentifier( "allShirtsUnlocked", percentComplete: percentOfAllShirts )
    }

    func isUnlocked( shirtName: String ) -> Bool {
        var unlocked = false
        for shirt in unlockedShirts {
            if let s = shirt as? String {
                if s == shirtName { return true }
            }
        }
        return false
    }

    var totalScore: Int64 {
        get {
            return Int64( ( defaults.valueForKey( "Total Score" ) as! NSNumber).integerValue )
        }
    }

    var soundOn: Bool {
        get {
            return defaults.boolForKey( "Sound" )
        }
        set {
            defaults.setBool( newValue, forKey: "Sound" )
        }
    }
}
