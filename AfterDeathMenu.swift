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
    weak var scoreFireworks: CCParticleSystem?
    private(set) var gold: Int = GameState.sharedState.goldShirts
    private(set) var score: Int = 0
    private var targetScore: Int = 0
    private var scoreUpdateTimer: NSTimer?
    private var scoreUpdateStep: Int = 1
   
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
        score = 0
        targetScore = GameState.sharedState.score
        if targetScore > 0 {
            scoreUpdateTimer = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "incrementScore", userInfo: nil, repeats: true )
            if targetScore > 50 {
                scoreUpdateStep = targetScore / 50
            }
            var fireWorks = CCBReader.load( "Effects/RainbowFireworks" ) as! CCParticleSystem
            scoreFireworks = fireWorks
            fireWorks.autoRemoveOnFinish = true
            //fireWorks.positionType = scoreScoreLabel.positionType
            fireWorks.position = scoreScoreLabel.positionInPoints
            self.addChild( fireWorks )
        } else {
            scoreScoreLabel.string = String( 0 )
        }
    }

    func goldShirtEffectManager() {
        if gold-- > 0 {
            var delay = CCActionDelay.actionWithDuration( 0.22 ) as! CCActionDelay
            var effect = CCActionCallFunc.actionWithTarget( self, selector: "goldShirtEffect" ) as! CCActionCallFunc
            self.runAction( CCActionSequence.actionWithArray([delay, effect] ) as! CCActionSequence )
        }
    }

    func goldShirtEffect() {
        var goldExplosion = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
        goldExplosion.autoRemoveOnFinish = true
        //fireWorks.positionType = scoreScoreLabel.positionType
        goldExplosion.position = scoreScoreLabel.positionInPoints
        self.addChild( goldExplosion )

        score += targetScore
        scoreScoreLabel.string = String( score )
        goldShirtEffectManager()
    }

    func incrementScore() -> Void {
        if let s = scoreUpdateTimer {
            score = min( targetScore, score + scoreUpdateStep )
            if score >= targetScore {
                s.invalidate()
                scoreUpdateTimer = nil
                scoreFireworks!.stopSystem()
                goldShirtEffectManager()
            }
        }
        scoreScoreLabel.string = String( score )
    }
}
