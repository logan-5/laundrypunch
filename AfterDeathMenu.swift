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
    weak var highScoreLabel: CCLabelTTF!
    weak var stinkyLabel: CCLabelTTF!
    weak var restartButton: CCButton!
    weak var optionsButton: CCButton!
    weak var leaderboardsButton: CCButton!
    weak var achievementsButton: CCButton!
    weak var unlockablesButton: CCButton!
    weak var soundButton: CCButton!
    weak var creditsLabel: CCLabelTTF!
    weak var scoreFireworks: CCParticleSystem?
    private(set) var gold: Int64 = GameState.sharedState.goldShirts
    private(set) var score: Int64 = 0
    private var targetScore: Int64 = 0
    private var scoreUpdateTimer: NSTimer?
    private var scoreUpdateStep: Int64 = 1
    private var ready = false
    private var scoreDisplayed = false

    var chaChingSound = GameState.sharedState.playSound( "audioFiles/chaching.caf", loop: true )

   
    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        self.runAction( fadeIn )
        
        self.userInteractionEnabled = true
        scoreScoreLabel.runAction( CCActionAnimateRainbow.instantiate() )

        highScoreLabel.string = Data.sharedData.modeName + " best:\n" + String.localizedStringWithFormat( "%@", NSNumber( longLong: GameState.sharedState.oldHighScore ) )
        //highScoreLabel.opacity = 0

        setSoundButtonText()
        creditsLabel.string = "© 2015 logan r smith // noisecode.net"
    }
    
    func restartButtonPressed() -> Void {
        GameState.sharedState.restart()
    }
    
//    func optionsButtonPressed() -> Void {
//        self.addChild( CCBReader.load( "OptionsMenu" ) )
//    }

    func difficultyMenu () -> Void {
        self.addChild( CCBReader.load( "DifficultyMenu" ) as CCNode )
    }

    func leaderboardsButtonPressed() -> Void {
        GCHelper.defaultHelper().showLeaderboardOnViewController( CCDirector.sharedDirector() )
    }

    func achievementsButtonPressed() -> Void {
        GCHelper.defaultHelper().showLeaderboardOnViewController( CCDirector.sharedDirector() )
    }

    func unlockablesButtonPressed() -> Void {
        self.addChild( CCBReader.load( "UnlockablesMenu" ) )
    }

    func soundButtonPressed() -> Void {
        Data.sharedData.soundOn = Data.sharedData.soundOn == false
        setSoundButtonText()
    }

    func setSoundButtonText() {
        soundButton.label.string = Data.sharedData.soundOn ? "sound on" : "muted"
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
        if targetScore > 0 && scoreUpdateTimer == nil {
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
            scoreScoreLabel.string = String.localizedStringWithFormat( "%@", NSNumber( longLong: score ) )
            chaChingSound?.stop()
            goldShirtEffectManager()
        }
    }

    func goldShirtEffectManager() {
        if gold-- > 0 {
            var delay = CCActionDelay.actionWithDuration( 0.22 ) as! CCActionDelay
            var effect = CCActionCallFunc.actionWithTarget( self, selector: "goldShirtEffect" ) as! CCActionCallFunc
            self.runAction( CCActionSequence.actionWithArray([delay, effect] ) as! CCActionSequence )
        } else {
            if GameState.sharedState.oldHighScore != Data.sharedData.score {
                highScoreLabel.string = "new " + Data.sharedData.modeName + " best!\n" + String.localizedStringWithFormat( "%@", NSNumber( longLong: Data.sharedData.score ) )
            }
        }
    }

    func goldShirtEffect() {
        var goldExplosion = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
        goldExplosion.autoRemoveOnFinish = true
        //fireWorks.positionType = scoreScoreLabel.positionType
        goldExplosion.position = scoreScoreLabel.positionInPoints
        self.addChild( goldExplosion )

        GameState.sharedState.playSound( "audioFiles/explosion.caf" )

        score += targetScore
        scoreScoreLabel.string = String.localizedStringWithFormat( "%@", NSNumber( longLong: score ) )
        goldShirtEffectManager()
    }

    func incrementScore() -> Void {
        if let s = scoreUpdateTimer {
            score = min( targetScore, score + scoreUpdateStep )
            if score >= targetScore {
                score = targetScore
                s.invalidate()
                scoreUpdateTimer = nil
                if scoreFireworks != nil {
                    scoreFireworks!.stopSystem()
                }
                chaChingSound?.stop()
                goldShirtEffectManager()
            }
        }
        scoreScoreLabel.string = String.localizedStringWithFormat( "%@", NSNumber( longLong: score ) )
    }

    override func update(delta: CCTime) {
        if !ready { ready = true; return }
        if !scoreDisplayed { displayScore(); scoreDisplayed = true }
    }
}
