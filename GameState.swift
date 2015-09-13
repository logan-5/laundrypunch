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
    private(set) var oldHighScore: Int64 = 0
    var goldShirts: Int64 = 0
    private var finalScore: Int64 = 0
    private(set) var lives: Int = 0
    private(set) var lost = false
    var emittedFirstShirt = false
    private var _quarterProbability: Double = 0.16
    func quarterProbability() -> Bool { return probabilityOf( _quarterProbability ) } // for lazy people

    private(set) var lowFXMode = false // ease up on the effects for slower devices (iPhone 4)

    var receptacles: [Receptacle] = Array()
    var allReceptaclesHaveReceivedShirts = false

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
        inARow = 1
        lastColor = nil
    }

    func cashIn( amount: Int64 ) {
        cashIn( amount, speedUp: true )
    }

    func cashIn( amount: Int64, speedUp: Bool ) -> Void {
        if amount <= 0 || lost { return }

        targetScore += amount
        if scoreUpdateTimer == nil {
            scoreUpdateTimer = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "incrementScore", userInfo: nil, repeats: true )
        }
        if scene!.scoreEffect == nil { scene!.scoreEffect?.stopSystem() }
        //if scene!.nextEffect == "Effects/GoldExplosion" {
            let effect = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
            scene!.scoreEffect = effect
            effect.position = scene!.scoreLabel.positionInPoints
            effect.autoRemoveOnFinish = true
            scene!.addChild( effect )
        //}
        if speedUp {
            emitRate -= modeInfo.emitRateDecay
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

    func syncScoreAndTargetScore() {
        if let s = scoreUpdateTimer {
            score = targetScore
            s.invalidate()
            scoreUpdateTimer = nil
            if scene!.scoreEffect != nil { scene!.scoreEffect?.stopSystem() }
        }
        scene!.updateScoreLabel()
    }

    var comboTimer: NSTimer?
    var waitingForCombo = false
    var firstReceptacle: Receptacle?
    var lastColor: Shirt.Color?
    var inARow: Int64 = 1
    func stackShirt( receptacle: Receptacle, item: Dispensable, forPoints: Bool ) -> Void {
        if lost { return }

        if let q = item as? Quarter {
            inARow = 1
            lastColor = nil
        } else {
            if lastColor == nil {
                lastColor = receptacle.shirtColor
            } else if lastColor == receptacle.shirtColor {
                if ++inARow % 3 == 0 {
                    cashIn( inARow, speedUp: false )
                    setUpComboTextAnimation( String(inARow) + " in a row!\n+" + String(inARow) )
                }
            } else {
                inARow = 1
                lastColor = nil
            }
        }

        if waitingForCombo {
            waitingForCombo = false
            //comboTimer?.invalidate(); comboTimer = nil
            combo( firstReceptacle!, r2: receptacle )
        } else {
            firstReceptacle = receptacle
            comboTimer = NSTimer.scheduledTimerWithTimeInterval( 0.5, target: self, selector: "invalidateCombo", userInfo: nil, repeats: false )
            waitingForCombo = true
        }

        if forPoints && modeInfo.scoringModel == ScoringModel.PerShirt {
            cashIn( 1 )
        }
    }

    func setUpComboTextAnimation( string: String ) {
        setUpComboTextAnimation( string, rainbow: true )
    }

    func setUpComboTextAnimation( string: String, rainbow: Bool ) {
        // set up numerical animation
        let label: CCLabelTTF = CCLabelTTF.labelWithString( string, fontName: "Courier", fontSize: 20 )
        label.cascadeColorEnabled = true; label.cascadeOpacityEnabled = true
        label.opacity = 0
        GameState.sharedState.scene?.particleLayer.addChild( label )
        label.position = ccp( scene!.contentSizeInPoints.width / 2, scene!.contentSizeInPoints.height / 2 )
        if rainbow { label.runAction( CCActionAnimateRainbow.instantiate() ) }
        label.runAction( CCActionFadeIn.actionWithDuration( 0.3 ) as! CCActionFadeIn )
        let moveUp: CCAction = CCActionMoveBy.actionWithDuration( 2.5, position: ccp( CGFloat(CCRANDOM_MINUS1_1() * 20), receptacles[0].contentSize.height * 2 ) ) as! CCActionMoveBy
        label.runAction( moveUp )
        let delay: CCAction = CCActionDelay.actionWithDuration( 1.5 ) as! CCActionDelay
        let fadeOut: CCAction = CCActionFadeOut.actionWithDuration( 0.6 ) as! CCActionFadeOut
        let remove: CCAction = CCActionCallBlock.actionWithBlock { () -> Void in
            label.removeFromParent()
            } as! CCActionCallBlock
        label.runAction( CCActionSequence.actionWithArray([delay, fadeOut, remove]) as! CCActionSequence )
    }

    func combo( r1: Receptacle, r2: Receptacle ) {
        if lost { return }

        // bounce combos that involve a quarter hitting an empty bin
        if r1.shirts.count == 1 {
            if let q = r1.shirts[0] as? Quarter { return }
        }
        if r2.shirts.count == 1 {
            if let q = r2.shirts[0] as? Quarter { return }
        }

        var points: Int64
        var golds: Int64
        if r1 != r2 {
            var r1Result = r1.countPointsAndCreateString( false )
            var r2Result = r2.countPointsAndCreateString( false )

            points = r1Result.points + r2Result.points
            golds = r1Result.golds + r2Result.golds
        } else {
            var r1Result = r1.countPointsAndCreateString( false )
            points = r1Result.points
            golds = r1Result.golds
        }
        cashIn( points, speedUp: false )
        let resultString = "combo!! " + ( golds > 0 ? String(golds) + " gold " : "" ) + ( "+" + String(points) )

        setUpComboTextAnimation( resultString )
    }

    func invalidateCombo() {
        waitingForCombo = false
        comboTimer?.invalidate()
        comboTimer = nil
    }

    func checkIfFinished() {
        if !allReceptaclesHaveReceivedShirts {
            var all = true
            for r in receptacles {
                if !r.hasReceivedShirt {
                    all = false
                    break
                }
            }
            allReceptaclesHaveReceivedShirts = all
            if !allReceptaclesHaveReceivedShirts { return }
        }

        for r in receptacles {
            if r.shirts.count > 0 { return }
        }

        finishedCombo()
    }

    func finishedCombo() {
        let result = score * 2
        if result <= 0 { return }
        var goldString = ""
        if goldShirts > 0 && goldShirts < 10 {
            goldShirts *= 2
            goldString = "gold x 2"
        } else if goldShirts > 0 {
            goldShirts += 10
            goldString = "gold + 10"
        }
        cashIn( result, speedUp: false )
        let resultString = "incredible! finished laundry!\n+score x 3\n" + goldString

        setUpComboTextAnimation( resultString )
    }

    func trickShot( receptacle: Receptacle ) {
        if receptacle.shirts.count == 0 { return }
        var rainbow = false
        var insane = receptacle.shirts.count > 6
        let quarter = receptacle.shirts[0] as? Quarter
        if receptacle.shirts.count == 1 && quarter != nil {
            rainbow = false
        } else {
            goldShirts += insane ? 2 : 1
            rainbow = true
        }
        let resultString = ( insane ? "insane " : "" ) + (rainbow ? "trick shot!\n+" + String(insane ? 2 : 1) + " gold" : "trick shot!\n+0")
        setUpComboTextAnimation( resultString, rainbow: rainbow )
    }

    func endGame() -> Void {
        lost = true
        invalidateCombo()
        syncScoreAndTargetScore()
        finalScore = score * Int64(goldShirts + 1)
        oldHighScore = Data.sharedData.score
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
        invalidateCombo()
        emittedFirstShirt = false
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

    var allowAdvancedCombos: Bool {
        get {
            switch mode {
            case .Easy:
                return false
            default:
                return true
            }
        }
    }
}

enum ScoringModel {
    case PerShirt
    case PerCashIn
}