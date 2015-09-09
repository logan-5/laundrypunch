//
//  Dispensable.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

// superclass for any object that can come out of the inflow pipe

import UIKit

class Dispensable: CCNode {
    var initialXVelocity: CGFloat = 0
    var initialYVelocity: CGFloat = -8
    var maxInitialAngularMomentum: Float = 10
    var bounceSpeed: CGFloat = 600
    var radius: CGFloat!
    var ready = false
    var stackedPosition: CGPoint?
    var stacked = false

    func didLoadFromCCB() -> Void {
        self.physicsBody.velocity = ccp( initialXVelocity, initialYVelocity )
        self.physicsBody.angularVelocity = CGFloat( CCRANDOM_0_1() * maxInitialAngularMomentum * ( CCRANDOM_MINUS1_1() > 0 ? 1 : -1 ) )
        //self.physicsBody.allowsRotation = false
        //        self.physicsBody.allowsRotation = false // for noob version
        radius = 2*ccpDistance( self.anchorPointInPoints, CGPointZero )
        ready = true
    }
    
    override func update(delta: CCTime) -> Void {
        if !ready || stacked { return }
        let pos = self.parent.parent.convertToNodeSpace( self.position )
        if ( pos.x < -radius ||
            pos.x > radius + CCDirector.sharedDirector().viewSize().width ||
            pos.y < -radius ||
            pos.y > radius + CCDirector.sharedDirector().viewSize().height ) {
                self.removeFromParent();
        }
    }
    
    func fall() -> Void {
        self.physicsBody.affectedByGravity = true
        self.physicsBody.sensor = true
        self.physicsBody.velocity = CGPointZero
        self.physicsBody.collisionType = "faller"
        stacked = false
    }

}
