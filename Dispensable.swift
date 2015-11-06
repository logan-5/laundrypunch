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
    var bounceSpeed: CGFloat = 600.0 * ( 568.0 / CCDirector.sharedDirector().viewSize().height ) // 568 is the screen height on iPhone 5s, on which this game was primarily developed and tuned.  other launch speeds should be a ratio of that speed
    var radius: CGFloat!
    var ready = false
    var stackedPosition: CGPoint?
    var stacked = false
    weak var sprite: CCSprite!
    var spriteScale: Float!
    var firstOut = false // first from the chute?
    var decremented = false // read in destroying methods; if this has not been subtracted from GameState.liveObjects, do it

    //var comeBack: CCAction!

    static let trickShotTime = 1.4
    var trickShotTimer: NSTimer?
    private(set) var trickShot = false

    func didLoadFromCCB() -> Void {
        initialize()
    }

    var bounces: Int64 = 0
    func initialize() {
        bounces = 0
        decremented = false
        stacked = false
        
        //self.physicsBody.allowsRotation = false
        //        self.physicsBody.allowsRotation = false // for noob version
        radius = 2*ccpDistance( self.anchorPointInPoints, CGPointZero )
        ready = true
        //self.physicsBody.type = CCPhysicsBodyType.Dynamic
    }

    override func update(delta: CCTime) -> Void {
        if !ready || stacked { return }
        let pos = self.parent!.parent!.convertToNodeSpace( self.position )
        if ( pos.x < -radius ||
            pos.x > radius + CCDirector.sharedDirector().viewSize().width ||
            pos.y < -radius ||
            pos.y > radius + CCDirector.sharedDirector().viewSize().height ) {
                DispensableCache.sharedCache.killObject( self )
        }
    }
    
    func fall() -> Void {
        //self.physicsBody.type = CCPhysicsBodyType.Dynamic
        self.physicsBody.affectedByGravity = true
        self.physicsBody.sensor = true
        self.physicsBody.velocity = CGPointZero
        self.physicsBody.collisionType = "faller"
        stacked = false
    }

    func startTrickShotTimer() {
        trickShot = false
        trickShotTimer?.invalidate()
        trickShotTimer = NSTimer.scheduledTimerWithTimeInterval( Dispensable.trickShotTime, target: self, selector: "setTrickShot", userInfo: nil, repeats: false )
    }

    func setTrickShot() {
        trickShot = true
    }

    func stack() {
        trickShotTimer?.invalidate()
        trickShotTimer = nil
    }

    func setVelocity() {
        self.physicsBody.velocity = ccp( initialXVelocity, initialYVelocity )

    }

    func setAngular() {
        self.physicsBody.angularVelocity = CGFloat( CCRANDOM_0_1() * maxInitialAngularMomentum * ( CCRANDOM_MINUS1_1() > 0 ? 1 : -1 ) )

    }

    func go() {
        setVelocity()
        setAngular()
    }

    var justBounced = false
    func startBounceTimer() {
        ++bounces
        justBounced = true
        NSTimer.scheduledTimerWithTimeInterval( 0.05, target: self, selector: "unBounce", userInfo: nil, repeats: false )
    }

    func unBounce() {
        justBounced = false
    }
}
