//
//  Inflow.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Inflow: CCNode {
    var emitPoint: CGPoint!
    var launchingAction: CCAction?
    //var launchingAction: CCTimer?
    var canceled = false
    var quarterCounter: UInt32 = 0
    let quarterThreshold: UInt32 = 20 // launch a quarter if no quarter has been launched in this long

    let preview = Data.sharedData.__TESTING_ONLY__previewMode //gameState.modeInfo.previewNextShirt
    var nextUp: Dispensable!
    var onDeck: Dispensable!

    var ready = false

    let gameState = GameState.sharedState
    
    func didLoadFromCCB() -> Void {
        emitPoint = CGPointMake( self.contentSizeInPoints.width / 2, self.positionInPoints.y + (preview ? 50 : 0) )
        self.zOrder = Int.max
    }
    
    func setUpLaunch() -> Void {
        //let stillLaunching: Bool = launchingAction != nil && !launchingAction!.isDone()
        let initialDelays: Bool = !gameState.scene!.hasBeenTouched && gameState.emittedFirstShirt
        if /*stillLaunching ||*/ initialDelays {
            //launchingAction?.invalidate()
            if launchingAction != nil {
                self.stopAction( launchingAction! )
                launchingAction = nil
            }
            return
        }
        if preview {
            setUpLaunchWithPreview()
        } else {
            setUpLaunchWithNoPreview()
        }
    }

    func setUpLaunchWithPreview() {
        if gameState.emittedFirstShirt && (quarterCounter++ > quarterThreshold || gameState.quarterProbability()) {
            quarterCounter = 0
            onDeck = DispensableCache.sharedCache.nextQuarter()
        } else {
            onDeck = DispensableCache.sharedCache.nextShirt()
        }
        //gameState.scene!.myPhysicsNode.addChild( onDeck )
        onDeck.sprite.scale = 0.5 * onDeck.spriteScale
        onDeck.sprite.anchorPoint = ccp( 0.5, 0.5 )
        onDeck.sprite.position = ccp( onDeck.contentSizeInPoints.width / 2, onDeck.contentSizeInPoints.height / 2 )
        onDeck.physicsBody.affectedByGravity = false
        onDeck.physicsBody.allowsRotation = false
        let e = self.convertToWorldSpace( emitPoint )
        onDeck.position = ccp( e.x, gameState.scene!.contentSizeInPoints.height + onDeck.contentSizeInPoints.height )
        let fall: CCAction = CCActionMoveTo.actionWithDuration( 0.2, position: e ) as! CCActionMoveTo
        onDeck.runAction( fall )
        //nextUp = onDeck

        let emitRate = CCTime( gameState.emittedFirstShirt ? gameState.emitRate : gameState.emitRate / 2 )
        let delay = CCActionDelay.actionWithDuration( emitRate ) as! CCActionDelay
        let launch = CCActionCallFunc.actionWithTarget( self, selector: "launch" ) as! CCActionCallFunc
        launchingAction = CCActionSequence.actionWithArray( [delay, launch] ) as! CCActionSequence
        self.runAction( launchingAction )

//        let emitRate = CCTime( gameState.emittedFirstShirt ? gameState.emitRate : gameState.emitRate / 2 )
//        launchingAction = nil
//        launchingAction = self.scheduleOnce( "launch", delay: emitRate )
    }

    func setUpLaunchWithNoPreview() {
        // old way with no preview
        let emitRate = CCTime( gameState.emittedFirstShirt ? gameState.emitRate : gameState.emitRate / 2 )
        let delay = CCActionDelay.actionWithDuration( emitRate ) as! CCActionDelay
        let launch = CCActionCallFunc.actionWithTarget( self, selector: "launch" ) as! CCActionCallFunc
        launchingAction = CCActionSequence.actionWithArray( [delay, launch] ) as! CCActionSequence
        self.runAction( launchingAction )
//        let emitRate: CCTime = CCTime( gameState.emittedFirstShirt ? gameState.emitRate : gameState.emitRate / 2 )
//        launchingAction = nil
//        launchingAction = self.scheduleOnce( "launch", delay: emitRate )
    }

    func launch() -> Void {
//        if let l = launchingAction {
//            self.stopAction( l )
//            launchingAction = nil
//        }
        if preview {
            launchWithPreview()
        } else {
            launchWithNoPreview()
        }
    }

    func launchWithPreview() {

        if let s = onDeck as? Shirt {
            AchievementManager.sharedManager.notifyShirtLaunch()

            if s.isRainbow == true {
                let rainbowSmoke = CCBReader.load( "Effects/RainbowSmell" ) as! CCParticleSystem
                rainbowSmoke.autoRemoveOnFinish = true
                rainbowSmoke.particlePositionType = CCParticleSystemPositionType.Free
                gameState.scene!.addChild( rainbowSmoke )
                rainbowSmoke.position = self.convertToWorldSpace( emitPoint )
            }
        }

        nextUp = onDeck
        nextUp.physicsBody.affectedByGravity = true
        nextUp.physicsBody.allowsRotation = true
        nextUp.setVelocity()
        let scaleUp: CCAction = CCActionScaleTo.actionWithDuration( 0.3, scale: nextUp.spriteScale ) as! CCActionScaleTo
        let go: CCActionCallBlock = CCActionCallBlock.actionWithBlock { () -> Void in
            self.nextUp.setAngular()
        } as! CCActionCallBlock
        nextUp.sprite.runAction( CCActionSequence.actionWithArray([scaleUp, go]) as! CCActionSequence )
        if !gameState.emittedFirstShirt { nextUp.firstOut = true }
        gameState.emittedFirstShirt = true
        ++gameState.liveObjects

        setUpLaunch()
    }

    func launchWithNoPreview() {

        var object: Dispensable

        if gameState.emittedFirstShirt && (quarterCounter++ > quarterThreshold || gameState.quarterProbability()) {
            quarterCounter = 0
            object = DispensableCache.sharedCache.nextQuarter()
        } else {
            object = DispensableCache.sharedCache.nextShirt()
            AchievementManager.sharedManager.notifyShirtLaunch()

            if (object as! Shirt).isRainbow == true {
                let rainbowSmoke = CCBReader.load( "Effects/RainbowSmell" ) as! CCParticleSystem
                rainbowSmoke.autoRemoveOnFinish = true
                rainbowSmoke.particlePositionType = CCParticleSystemPositionType.Free
                gameState.scene!.addChild( rainbowSmoke )
                rainbowSmoke.position = self.convertToWorldSpace( emitPoint )
            }
        }

        // gameState.scene!.myPhysicsNode.addChild( object )
        object.go()
        gameState.lastLaunchedObject = object
        //object.positionType = CCPositionTypeMake( CCPositionUnit.Normalized, CCPositionUnit.Normalized, CCPositionReferenceCorner.BottomLeft)
        object.position = self.convertToWorldSpace( emitPoint )
        //        println( object.position )
        if !gameState.emittedFirstShirt { object.firstOut = true }
        gameState.emittedFirstShirt = true
        ++gameState.liveObjects

        setUpLaunch()
    }

    func launchDeathFace() -> Void {
        let object: Dispensable = CCBReader.load( probabilityOf( 0.5 ) ? "DeathSadFace" : "DeathHappyFace" ) as! Dispensable
        object.go()
        gameState.scene!.myPhysicsNode.addChild( object )
        gameState.lastLaunchedObject = object
        object.position = self.convertToWorldSpace( emitPoint )
    }
    
    override func update( delta: CCTime ) -> Void {
        if !ready && gameState.scene != nil { ready = true; return }
//        else if ready && ( launchingAction == nil || launchingAction!.isDone() || (gameState.emittedFirstShirt && gameState.lastLaunchedObject == nil) ) && !canceled {
//            self.setUpLaunch()
//        }
        else if launchingAction == nil && !canceled {
            setUpLaunch()
        }
    }
    
    func cancel() -> Void {
        if let l = launchingAction {
            self.stopAction( l )
            //l.invalidate()
            launchingAction = nil
        }
        canceled = true
    }
}
