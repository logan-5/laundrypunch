//
//  Options.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Options: CCNode {
   
    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as CCAction
        self.runAction( fadeIn )
        
        self.userInteractionEnabled = true
    }
    
    func wussMode() -> Void {
        GameState.sharedState.setMode( GameState.Mode.Easy )
    }
    
    func unreasonableMode() -> Void {
        GameState.sharedState.setMode( GameState.Mode.Hard )
    }
    
    func returnButton() -> Void {
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as CCAction
        let dispose = CCActionCallBlock.actionWithBlock( { () -> Void in
            self.removeFromParent()
        } ) as CCAction
        let s = CCActionSequence.actionWithArray([fadeOut, dispose]) as CCAction
        self.runAction( s )
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }
}
