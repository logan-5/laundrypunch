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

    public var mode: Mode {
        get { return Data.sharedData.mode }
        set {
            Data.sharedData.mode = newValue
            //setLives()
        }
    }

    func getModeString() -> String {
        return mode.rawValue
    } // for Objective-C compatibility.  didn't seem to work without this

    private(set) var modeInfo: ModeInfo!

    private(set) var score: Int64 = 0
    private var targetScore: Int64 = 0
    private var scoreUpdateTimer: NSTimer?
    var goldShirts: Int64 = 0
    private var finalScore: Int64 = 0
    private(set) var lives: Int = 0
    private(set) var lost = false
    var emittedFirstShirt = false
    private var _quarterProbability = 0.16
    func quarterProbability() -> Bool { return probabilityOf( _quarterProbability ) } // for lazy people

    private(set) var lowFXMode = false // ease up on the effects for slower devices (iPhone 4)

    private(set) weak var audioEngine = OALSimpleAudio.sharedInstance()
    weak var scene: MainScene?
    weak var lastLaunchedObject: Dispensable?
    private(set) var emitRate: Float = 0
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
    
    func failure() -> Void {
        if --lives < 0 {
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
        let effect = CCBReader.load( scene!.nextEffect ?? "Effects/RainbowFireworks" ) as! CCParticleSystem
        scene!.scoreEffect = effect
        effect.position = scene!.scoreLabel.positionInPoints
        effect.autoRemoveOnFinish = true
        scene!.addChild( effect )
        emitRate -= modeInfo.emitRateDecay
    }

    func stackShirt() -> Void {
        if modeInfo.scoringModel == ScoringModel.PerShirt {
            cashIn( 1 )
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
        modeInfo = ModeInfo( mode: mode )
        emitRate = modeInfo.initialEmitRate
        lives = modeInfo.initialLives
        score = 0
        goldShirts = 0
        targetScore = 0
        lost = false
        AchievementManager.sharedManager.resetAll()
    }

    func playSound( name: String ) -> ALSoundSource? {
        return playSound( name, loop: false )
    }

    func playSound( name: String, loop: Bool ) -> ALSoundSource? {
        if Data.sharedData.soundOn {
            return audioEngine?.playEffect( name, loop: loop )
        }
        return nil
    }
}

struct ModeInfo {
    var mode: GameState.Mode

    var initialLives: Int {
        get {
            switch mode {
            case .Hard:
                return 0
            case .Efficiency:
                return 10
            default:
                return 5
            }
        }
    }

    var initialEmitRate: Float {
        get {
            switch mode {
            case .Easy:
                return 3
            case .Efficiency:
                return 0.8
            default:
                return 2
            }
        }
    }

    var emitRateDecay: Float {
        get {
            switch mode {
            case .Easy:
                fallthrough
            case .Efficiency:
                return 0
            default:
                return 0.03
            }
        }
    }

    var specialEventsActive: Bool {
        get { return mode != .Easy }
    }

    var shouldShowGuide: Bool {
        get {
            switch mode {
            case .Easy:
                return true
            default:
                return false
            }
        }
    }

    var worldGravity: CGPoint {
        get {
            switch mode {
            case .Easy:
                return ccp( 0, -500 )
            default:
                return ccp( 0, -600 )
            }
        }
    }

    var scoringModel: ScoringModel {
        get {
            switch mode {
            case .Easy:
                return ScoringModel.PerShirt
            default:
                return ScoringModel.PerCashIn
            }
        }
    }
}

enum ScoringModel {
    case PerShirt
    case PerCashIn
}