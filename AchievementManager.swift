//
//  AchievementManager.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/7/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class AchievementManager: NSObject {

    let gc = GCHelper.defaultHelper()

    class var sharedManager: AchievementManager {
        get { return sharedInstance.sharedManager }
    }
    private struct sharedInstance { static let sharedManager = AchievementManager() }

    var launchedShirts: Int64 = 0
    var firstColor: Shirt.Color?

    func resetAll() {
        launchedShirts = 0
        firstColor = nil
    }

    func notifyShirtLaunch() {
        ++launchedShirts
        println( launchedShirts )
        if launchedShirts == 51 && GameState.sharedState.score == 0 {
            gc.reportAchievementIdentifier( "procrastination1", percentComplete: 100 )
        }
    }

    func notifyCashedInColor( color: Shirt.Color, plus: Int64 ) {
        if firstColor == nil {
            firstColor = color
        } else if color == firstColor && GameState.sharedState.score + plus >= 50 {
            gc.reportAchievementIdentifier( "procrastination2", percentComplete: 100 )
        }
    }

    func notifyStackSize( size: Int ) {
        if ( CGFloat(Float(Shirt.shirtContentSize.width) + Float(size) * Receptacle.stackOffset )) >= GameState.sharedState.scene!.contentSizeInPoints.width {
            gc.reportAchievementIdentifier( "procrastination3", percentComplete: 100 )
        }
    }
}
