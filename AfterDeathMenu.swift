//
//  AfterDeathMenu.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/29/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class AfterDeathMenu: CCNode {

    weak var scoreLabel: CCLabelTTF!
    weak var scoreScoreLabel: CCLabelTTF!
    weak var stinkyLabel: CCLabelTTF!
    weak var restartButton: CCButton!
    weak var optionsLabel: CCLabelTTF!
    weak var optionsButton: CCButton!
    private var score = 0
   
    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        self.runAction( fadeIn )
        
        self.userInteractionEnabled = true
        displayScore()
        scoreScoreLabel.runAction( CCActionAnimateRainbow.instantiate() )
    }
    
    func restartButtonPressed() -> Void {
        GameState.sharedState.restart()
    }
    
    func optionsButtonPressed() -> Void {
        self.addChild( CCBReader.load( "OptionsMenu" ) )
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }

    func displayScore() -> Void {
        score = GameState.sharedState.score
        scoreScoreLabel.string = String( score )
    }
}
