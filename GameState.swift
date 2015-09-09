//
//  GameState.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

func probabilityOf( probability: Double ) -> Bool {
    return Double(CCRANDOM_0_1()) < probability
}

public class GameState: NSObject {
    class var sharedState: GameState {
        get { return sharedInstance.sharedState }
    }
    private struct sharedInstance { static let sharedState = GameState() }
    
    public enum Mode: String {
        case Easy = "Easy"
        case Medium = "Medium"
        case Hard = "Hard"
        case Efficiency = "Efficiency"
    }
    struct Lives {
        static let Easy = 5//0
        static let Medium = 0
        static let Hard = 3
        static let Efficiency = 10//10000/10
    }
    public var mode: Mode {
        get { return Data.sharedData.mode }
        set {
            Data.sharedData.mode = newValue
            //setLives()
        }
    }
    func getModeString() -> String {
        return mode.rawValue
    }
    
    private(set) var score: Int64 = 0
    private var targetScore: Int64 = 0
    private var scoreUpdateTimer: NSTimer?
    var goldShirts: Int64 = 0
    private var finalScore: Int64 = 0
    private(set) var lives: Int = 0
    private(set) var lost = false
    private var _quarterProbability = 0.16
    func quarterProbability() -> Bool { return probabilityOf( _quarterProbability ) } // for lazy people

    private(set) var lowFXMode = false // ease up on the effects for slower devices (iPhone 4)

    private(set) weak var audioEngine = OALSimpleAudio.sharedInstance()
    weak var scene: MainScene?
    weak var lastLaunchedObject: Dispensable?
    private(set) var emitRate: Float = 0
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    let EFFICIENCY_EMIT_RATE: Float = 0.8
    override init() {
        switch UIDevice.currentDevice().systemVersion.compare("8.0.0", options: NSStringCompareOptions.NumericSearch) {
        case .OrderedSame, .OrderedDescending:
            lowFXMode = false
        case .OrderedAscending:
            lowFXMode = true
        } // thank you NSHipster

        audioEngine?.preloadEffect( "audioFiles/punch.caf" )
        audioEngine?.preloadEffect( "audioFiles/whoosh.caf" )
        audioEngine?.preloadEffect( "audioFiles/explosion.caf" )
        audioEngine?.preloadEffect( "audioFiles/sparkle.caf" )
        audioEngine?.preloadEffect( "audioFiles/flush.caf" )

        super.init()
        refresh()
    }
    
    func setLives() -> Int {
        switch mode {
        case .Efficiency:
            lives = Lives.Efficiency
        case .Hard:
            lives = Lives.Hard
        case .Medium:
            lives = Lives.Medium
        case .Easy:
            fallthrough
        default:
            lives = Lives.Easy
        }
        return lives
    }

    func getEmitRate() -> Float {
        return mode == Mode.Efficiency ? EFFICIENCY_EMIT_RATE : INITIAL_EMIT_RATE
    }
    
    func failure() -> Void {
        --lives
        if lives < 0 {
            scene!.gameOver()
            endGame()
        }
    }

    func cashIn( amount: Int64 ) -> Void {
        if amount <= 0 { return }
        targetScore += amount
        if scoreUpdateTimer == nil {
            scoreUpdateTimer = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "incrementScore", userInfo: nil, repeats: true )
        }
        if scene!.scoreEffect == nil { scene!.scoreEffect?.stopSystem() }
        let effect = CCBReader.load( scene!.nextEffect ) as! CCParticleSystem
        scene!.scoreEffect = effect
        effect.position = scene!.scoreLabel.position
        effect.autoRemoveOnFinish = true
        scene!.addChild( effect )
        if mode != Mode.Efficiency {
            emitRate -= 0.03
        }
    }

    func incrementScore() -> Void {
        if let s = scoreUpdateTimer {
            if ++score >= targetScore {
                s.invalidate()
                scoreUpdateTimer = nil
                if scene!.scoreEffect != nil { scene!.scoreEffect?.stopSystem() }
            }
        }
        scene!.updateScoreLabel()
    }

    func endGame() -> Void {
        lost = true
        finalScore = score * Int64(goldShirts + 1)
        Data.sharedData.score = finalScore
        GCHelper.defaultHelper().reportScore( finalScore, forLeaderboardID:mode.rawValue )
    }
    
    func restart() -> Void {
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        let reset = CCActionCallBlock.actionWithBlock( { () -> Void in
            self.refresh()
            let newScene = CCBReader.loadAsScene( "MainScene" )
            CCDirector.sharedDirector().replaceScene( newScene )
            GameState.sharedState.refresh()
            GameState.sharedState.scene!.updateScoreLabel()
        }) as! CCAction
        scene!.overlay.runAction( CCActionSequence.actionWithArray([fadeIn, reset]) as! CCAction )
    }
    
    func refresh() -> Void {
        emitRate = getEmitRate()
        setLives()
        score = 0
        goldShirts = 0
        targetScore = 0
        lost = false
        AchievementManager.sharedManager.resetAll()
    }
}
