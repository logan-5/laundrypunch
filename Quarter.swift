//
//  Quarter.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Quarter: Dispensable {
    
    static private let goldProbability: Double = 0.1
    private(set) var gold: Bool!
    var regurgitated = false

    override func initialize() {
        initialXVelocity = 0
        initialYVelocity = -8
        maxInitialAngularMomentum = 0
        bounceSpeed = 600
        regurgitated = false
        super.initialize()

        self.rotation = 0
        self.physicsBody.collisionType = "quarter"
        self.physicsBody.collisionGroup = "quarter"

        sprite.scale = Float(self.contentSize.width / sprite.contentSize.width)
        spriteScale = sprite.scale

        recalculateGold()
        if gold == true {
            // make me gold
            self.sprite.color = CCColor.yellowColor()
        } else {
            self.sprite.color = CCColor.whiteColor()
        }
    }

    func recalculateGold() {
        gold = probabilityOf( Quarter.goldProbability * ( GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0 ) )
    }
}
