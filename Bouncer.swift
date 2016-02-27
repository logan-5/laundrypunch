//
//  Bouncer.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Bouncer: CCNode {
    
    weak var handle: BouncerHandle!
    weak var glove: CCNode!
    weak var sensor: CCNode!
    weak var guide: CCNode?
    var guideDying: Bool = false

    func didLoadFromCCB() -> Void {
        self.rotation = -90
        self.physicsBody.elasticity = 3.35
        self.physicsBody.collisionType = "bouncer"
        self.physicsBody.collisionGroup = "bouncer"
        sensor.physicsBody.collisionGroup = "bouncer"
        sensor.physicsBody.collisionType = "animateSensor"
        sensor.physicsBody.sensor = true
        if !GameState.sharedState.modeInfo.shouldShowGuide {
            guide?.removeFromParent()
        }
    }
    
    func updateAngle( position: CGPoint ) -> Void {
        let direction = ccpSub( position, self.positionInPoints )
        var angle = Float( ccpToAngle( direction ) )
        angle = 180 - CC_RADIANS_TO_DEGREES( angle )
        self.rotation = angle
    }

    override func update(delta: CCTime) {
        if self.physicsBody.type == CCPhysicsBodyType.Dynamic {
            self.physicsBody.affectedByGravity = false
        }
    }

    func animateGlove() {
        glove.animationManager.runAnimationsForSequenceNamed( "Punch" )
        GameState.sharedState.playSound( "audioFiles/punch.caf" )
    }

    func killGuide() {
        if guide != nil && !guideDying {
            guideDying = true
            let die = CCActionCallBlock.actionWithBlock({ () -> Void in
                self.guide?.removeFromParent()
            }) as! CCAction
            let fadeOut = CCActionFadeTo.actionWithDuration( 2, opacity: 0 ) as! CCAction
            guide?.runAction( CCActionSequence.actionWithArray([fadeOut, die]) as! CCAction )
        }
    }
}
