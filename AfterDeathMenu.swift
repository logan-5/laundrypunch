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
    weak var goldInfoLabel: CCLabelTTF?
    var goldInfoRunningActions = false
    weak var highScoreLabel: CCLabelTTF!
    weak var stinkyLabel: CCLabelTTF!
    weak var restartButton: CCButton!
    weak var optionsButton: CCButton!
    weak var leaderboardsButton: CCButton!
    weak var achievementsButton: CCButton!
    weak var unlockablesButton: CCButton!
    weak var dryerModeButton: CCButton!
    weak var soundButton: CCButton!
    weak var creditsButton: CCButton!
    weak var scoreFireworks: CCParticleSystem?
    private(set) var gold: Int64 = GameState.sharedState.goldShirts
    private(set) var score: Int64 = 0
    private var targetScore: Int64 = 0
    private var scoreUpdateTimer: NSTimer?
    private var scoreUpdateStep: Int64 = 1
    private var doubleTapTimer: NSTimer?

    private var ready = false
    private var scoreDisplayed = false

//    weak var __TESTING_ONLY__previewButton: CCButton!
//    func __TESTING_ONLY__previewButtonPressed() {
//        let new = !Data.sharedData.__TESTING_ONLY__previewMode
//        Data.sharedData.__TESTING_ONLY__previewMode = new
//        __TESTING_ONLY__previewButton.label.string = "TESTING ONLY preview mode " + ( new ? "ON" : "OFF" )
//    }

    var chaChingSound = GameState.sharedState.playSound( "audioFiles/chaching.caf", loop: true )

   
    func didLoadFromCCB() -> Void {
        self.cascadeOpacityEnabled = true
        self.opacity = 0
        let fadeIn = CCActionFadeIn.actionWithDuration( menuFadeSpeed ) as! CCAction
        self.runAction( fadeIn )
        self.zOrder = 3
        
        self.userInteractionEnabled = true
        scoreScoreLabel.runAction( CCActionAnimateRainbow.instantiate() )
        goldInfoLabel!.opacity = 0

        highScoreLabel.string = Data.sharedData.modeName + " best:\n" + String.localizedStringWithFormat( "%@", NSNumber( longLong: GameState.sharedState.oldHighScore ) )
        //highScoreLabel.opacity = 0

        setSoundButtonText()

        //__TESTING_ONLY__previewButton.label.string = "TESTING ONLY preview mode " + ( Data.sharedData.__TESTING_ONLY__previewMode ? "ON" : "OFF" )
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

    func dryerModeButtonPressed() {
        let transition = CCTransition( crossFadeWithDuration: 0.5  )
        CCDirector.sharedDirector().replaceScene( CCBReader.loadAsScene( "DryerMode/DryerScene" ), withTransition: transition )
    }

    func soundButtonPressed() -> Void {
        Data.sharedData.soundOn = Data.sharedData.soundOn == false
        setSoundButtonText()
    }

    func setSoundButtonText() {
        soundButton.label.string = Data.sharedData.soundOn ? "sound on" : "muted"
    }

    func creditsButtonPressed() {
        self.addChild( CCBReader.load( "CreditsScreen" ) )
    }
    
    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if doubleTapTimer == nil {
            doubleTapTimer = NSTimer.scheduledTimerWithTimeInterval( 0.4, target: self, selector: "doubleTapExpire", userInfo: nil, repeats: false )
        } else {
            doubleTapExpire()
            scoreUpdateTimer?.invalidate()
            scoreUpdateTimer = nil
            gold = 0
            scoreFireworks?.stopSystem()
            self.stopAllActions()
            chaChingSound?.stop()
            score = GameState.sharedState.finalScore
            updateScoreLabel()
            goldExplosion()
            goldShirtEffectManager()
            return
        }

        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }

    func doubleTapExpire() {
        doubleTapTimer?.invalidate()
        doubleTapTimer = nil
    }

    func displayScore() -> Void {
        score = 0
        targetScore = GameState.sharedState.score
        if targetScore > 0 && scoreUpdateTimer == nil {
            scoreUpdateTimer = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "incrementScore", userInfo: nil, repeats: true )
            if targetScore > 50 {
                scoreUpdateStep = targetScore / 50
            }
            let fireWorks = CCBReader.load( "Effects/RainbowFireworks" ) as! CCParticleSystem
            scoreFireworks = fireWorks
            fireWorks.autoRemoveOnFinish = true
            //fireWorks.positionType = scoreScoreLabel.positionType
            fireWorks.position = scoreScoreLabel.positionInPoints
            self.addChild( fireWorks )
        } else {
            scoreScoreLabel.string = String.localizedStringWithFormat( "%@", NSNumber( longLong: score ) )
            if scoreScoreLabel.texture != nil {
                let l = scoreScoreLabel.texture.contentSize().width
                if  l > ( self.contentSizeInPoints.width ) {
                    scoreScoreLabel.scale = Float(( self.contentSizeInPoints.width ) / scoreScoreLabel.texture.contentSize().width)
                }
            }
            chaChingSound?.stop()
            goldShirtEffectManager()
        }
    }

    var goldCounter: Int64 = 1
    func goldShirtEffectManager() {
        if gold-- > 0 {
            let delay = CCActionDelay.actionWithDuration( 0.22 ) as! CCActionDelay
            let effect = CCActionCallFunc.actionWithTarget( self, selector: "goldShirtEffect" ) as! CCActionCallFunc
            self.runAction( CCActionSequence.actionWithArray([delay, effect] ) as! CCActionSequence )
        } else {
            if !goldInfoRunningActions {
                goldInfoLabel?.string = "x " + String( GameState.sharedState.goldShirts ) + " gold"
                let fade = CCActionFadeOut.actionWithDuration( 1.7 ) as! CCAction
                let die = CCActionCallBlock.actionWithBlock({ () -> Void in
                    self.goldInfoLabel?.removeFromParent()
                }) as! CCAction
                goldInfoLabel?.runAction( CCActionSequence.actionWithArray( [fade, die] ) as! CCAction )
                goldInfoRunningActions = true
            }
            if GameState.sharedState.oldHighScore != Data.sharedData.score {
                highScoreLabel.string = "new " + Data.sharedData.modeName + " best!\n" + String.localizedStringWithFormat( "%@", NSNumber( longLong: Data.sharedData.score ) )
            }
        }
    }

    func goldExplosion() {
        let goldExplosion = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
        goldExplosion.autoRemoveOnFinish = true
        //fireWorks.positionType = scoreScoreLabel.positionType
        goldExplosion.position = scoreScoreLabel.positionInPoints
        self.addChild( goldExplosion )
    }

    func goldShirtEffect() {
        goldExplosion()

        GameState.sharedState.playSound( "audioFiles/explosion.caf" )

        score += targetScore
        updateScoreLabel()
        goldInfoLabel!.string = "x " + String( ++goldCounter ) + " gold"
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
                if gold > 0 {
                    goldInfoLabel!.runAction( CCActionFadeIn.actionWithDuration( 0.2 ) as! CCAction )
                    goldInfoLabel!.runAction( CCActionAnimateRainbow.instantiate( 1 ) )
                } else {
                    goldInfoLabel!.removeFromParent()
                }
                chaChingSound?.stop()
                goldShirtEffectManager()
            }
        }
        updateScoreLabel()
    }

    func updateScoreLabel() {
        scoreScoreLabel.string = String.localizedStringWithFormat( "%@", NSNumber( longLong: score ) )
        labelScaleDirty = true
    }

    var labelScaleDirty = false
    var frameDelay = false // why
    override func update(delta: CCTime) {
        if !ready { ready = true; return }
        if !scoreDisplayed { displayScore(); scoreDisplayed = true }
        if labelScaleDirty {
            if !frameDelay {
                frameDelay = true
            } else {
                frameDelay = false
                labelScaleDirty = false
                if scoreScoreLabel.texture != nil {
                    let l = scoreScoreLabel.texture.contentSize().width
                    if  l > ( self.contentSizeInPoints.width ) {
                        scoreScoreLabel.scale = Float(( self.contentSizeInPoints.width ) / scoreScoreLabel.texture.contentSize().width)
                    }
                }
            }
        }
    }
}
