//
//  Quarter.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Quarter: Dispensable {
    
    weak var sprite: CCSprite!
    static private let goldProbability: Double = 0.1
    private(set) var gold: Bool = probabilityOf( goldProbability * ( GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0 ) )
    
    override func didLoadFromCCB() -> Void {
        initialXVelocity = 0
        initialYVelocity = -8
        maxInitialAngularMomentum = 0
        bounceSpeed = 600
        super.didLoadFromCCB()
        
        self.physicsBody.collisionType = "quarter"
        self.physicsBody.collisionGroup = "quarter"
        
        sprite.scale = Float(self.contentSize.width / sprite.contentSize.width)

        if gold {
            // make me gold
            self.sprite.color = CCColor.yellowColor()
        }
    }
}
