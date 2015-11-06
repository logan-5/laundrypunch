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
    var colorChanged = false
    var acrossScreenStacks: [Shirt.Color] = Array()

    func resetAll() {
        launchedShirts = 0
        firstColor = nil
        acrossScreenStacks.removeAll()
    }

    func notifyShirtLaunch() {
        ++launchedShirts
        if launchedShirts == 50 && GameState.sharedState.score == 0 {
            gc.reportAchievementIdentifier( "procrastinator1", percentComplete: 100 )
        }
    }

    func notifyCashedInColor( color: Shirt.Color, plus: Int64 ) {
        if firstColor == nil {
            firstColor = color
        }
        if !colorChanged && color != firstColor {
            colorChanged = true
        } else if !colorChanged && GameState.sharedState.score + plus >= 50 {
            gc.reportAchievementIdentifier( "procrastinator2", percentComplete: 100 )
        }
    }

    func notifyStackSize( size: Int, color: Shirt.Color ) {
        for c in acrossScreenStacks {
            if c == color { return }
        }
        if ( CGFloat(Float(Shirt.shirtContentSize.width) + Float(size) * Receptacle.stackOffset )) >= GameState.sharedState.scene!.contentSizeInPoints.width {
            gc.reportAchievementIdentifier( "procrastinator3", percentComplete: 100 )
            acrossScreenStacks.append( color )
        }
    }
}
