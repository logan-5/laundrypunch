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
    var emittedFirstShirt = false
    var quarterCounter: UInt32! // launch a quarter when this == GameState.sharedState.nextQuarter
    
    func didLoadFromCCB() -> Void {
        emitPoint = CGPointMake( self.position.x, self.position.y - self.contentSize.height )
        self.zOrder = 2
        quarterCounter = 0
        GameState.sharedState.getNextQuarterTime()
        
        // launch a shirt
        var emitRate = CCTime( GameState.sharedState.emitRate )
        var delay = CCActionDelay.actionWithDuration( emitRate ) as CCActionDelay
        var launch = CCActionCallFunc.actionWithTarget( self, selector: "launch" ) as CCActionCallFunc
        launchingAction = CCActionSequence.actionWithArray( [delay, launch] ) as CCActionSequence
        self.runAction( launchingAction )
    }
    
    func setUpLaunch() -> Void {
        var stillLaunching: Bool = launchingAction != nil && !launchingAction!.isDone()
        var initialDelays: Bool = !GameState.sharedState.scene!.hasBeenTouched || !emittedFirstShirt
        if stillLaunching || initialDelays {
            return
        }
        var emitRate = CCTime( emittedFirstShirt ? GameState.sharedState.emitRate : GameState.sharedState.emitRate / 2 )
        var delay = CCActionDelay.actionWithDuration( emitRate ) as CCActionDelay
        var launch = CCActionCallFunc.actionWithTarget( self, selector: "launch" ) as CCActionCallFunc
        launchingAction = CCActionSequence.actionWithArray( [delay, launch] ) as CCActionSequence
        self.runAction( launchingAction )
    }
    
    func launch() -> Void {
        if let l = launchingAction {
            self.stopAction( l )
            launchingAction = nil
        }
        var object: CCNode
        if quarterCounter!++ < GameState.sharedState.nextQuarter {
            object = CCBReader.load( "Shirt" ) as Shirt
        } else {
            quarterCounter = 0
            GameState.sharedState.getNextQuarterTime()
            object = CCBReader.load( "Quarter" ) as Quarter
        }
        GameState.sharedState.scene!.physicsNode.addChild( object )
        GameState.sharedState.lastLaunchedObject = object
        object.position = self.parent.convertToNodeSpace( emitPoint )
        emittedFirstShirt = true
        self.setUpLaunch()
    }
    
    override func update( delta: CCTime ) -> Void {
        if launchingAction == nil || launchingAction!.isDone() || GameState.sharedState.lastLaunchedObject == nil {
            self.setUpLaunch()
        }
    }
}
