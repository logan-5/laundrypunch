//
//  Inflow.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Inflow: CCNode {
    weak var nozzle: CCSprite!
    var emitPoint: CGPoint!
    var launchingAction: CCAction?
    var canceled = false
    var quarterCounter: UInt32 = 0
    let quarterThreshold: UInt32 = 20 // launch a quarter if no quarter has been launched in this long

    var nextUp: Dispensable!
    var onDeck: Dispensable!

    var ready = false
    
    func didLoadFromCCB() -> Void {
        emitPoint = CGPointMake( self.contentSizeInPoints.width / 2, self.positionInPoints.y )
        self.zOrder = 2
        nozzle.zOrder = 2
    }
    
    func setUpLaunch() -> Void {
        let stillLaunching: Bool = launchingAction != nil && !launchingAction!.isDone()
        let initialDelays: Bool = !GameState.sharedState.scene!.hasBeenTouched && GameState.sharedState.emittedFirstShirt
        if stillLaunching || initialDelays {
            return
        }
        let emitRate = CCTime( GameState.sharedState.emittedFirstShirt ? GameState.sharedState.emitRate : GameState.sharedState.emitRate / 2 )
        let delay = CCActionDelay.actionWithDuration( emitRate ) as! CCActionDelay
        let launch = CCActionCallFunc.actionWithTarget( self, selector: "launch" ) as! CCActionCallFunc
        launchingAction = CCActionSequence.actionWithArray( [delay, launch] ) as! CCActionSequence
        self.runAction( launchingAction )
    }
    
    func launch() -> Void {
        if let l = launchingAction {
            self.stopAction( l )
            launchingAction = nil
        }
        var object: Dispensable

        if GameState.sharedState.emittedFirstShirt && (quarterCounter++ > quarterThreshold || GameState.sharedState.quarterProbability()) {
            quarterCounter = 0
            object = CCBReader.load( "Quarter" ) as! Quarter
        } else {
            object = CCBReader.load( "Shirt" ) as! Shirt
            AchievementManager.sharedManager.notifyShirtLaunch()

            if (object as! Shirt).isRainbow {
                let rainbowSmoke = CCBReader.load( "Effects/RainbowSmell" ) as! CCParticleSystem
                rainbowSmoke.autoRemoveOnFinish = true
                rainbowSmoke.particlePositionType = CCParticleSystemPositionType.Free
                GameState.sharedState.scene!.addChild( rainbowSmoke )
                rainbowSmoke.position = self.convertToWorldSpace( emitPoint )
            }
        }
        GameState.sharedState.scene!.myPhysicsNode.addChild( object )
        GameState.sharedState.lastLaunchedObject = object
        //object.positionType = CCPositionTypeMake( CCPositionUnit.Normalized, CCPositionUnit.Normalized, CCPositionReferenceCorner.BottomLeft)
        object.position = self.convertToWorldSpace( emitPoint )
//        println( object.position )
        GameState.sharedState.emittedFirstShirt = true
        self.setUpLaunch()
    }

    func launchDeathFace() -> Void {
        let object: Dispensable = CCBReader.load( probabilityOf( 0.5 ) ? "DeathSadFace" : "DeathHappyFace" ) as! Dispensable
        GameState.sharedState.scene!.myPhysicsNode.addChild( object )
        GameState.sharedState.lastLaunchedObject = object
        object.position = self.convertToWorldSpace( emitPoint )
    }
    
    override func update( delta: CCTime ) -> Void {
        if !ready && GameState.sharedState.scene != nil { ready = true; return }
        else if ready && ( launchingAction == nil || launchingAction!.isDone() || (GameState.sharedState.emittedFirstShirt && GameState.sharedState.lastLaunchedObject == nil) ) && !canceled {
            self.setUpLaunch()
        }
    }
    
    func cancel() -> Void {
        if let l = launchingAction {
            self.stopAction( l )
            launchingAction = nil
        }
        canceled = true
    }
}
