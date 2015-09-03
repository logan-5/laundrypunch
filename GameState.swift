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

class GameState: NSObject {
    class var sharedState: GameState {
        get { return sharedInstance.sharedState }
    }
    private struct sharedInstance { static let sharedState = GameState() }
    
    enum Mode {
        case Easy
        case Hard
        case Efficiency
    }
    struct Lives {
        static let Easy = 5
        static let Hard = 0
        static let Efficiency = 10
    }
    private(set) var mode: Mode! // linker errors without '!'. I thought it'd work.  I must not understand
    private(set) var score: Int = 0
    private var targetScore: Int = 0
    private var scoreUpdateTimer: NSTimer?
    private(set) var lives: Int = 0
//    private var quarterFrequency: UInt32 = 10 // best case scenario, with a 30% chance of being 1.5* this
//    private(set) var nextQuarter: UInt32 = 0
    private var _quarterProbability = 0.08
    func quarterProbability() -> Bool { return probabilityOf( _quarterProbability ) } // for lazy people
    
    weak var scene: MainScene?
    weak var lastLaunchedObject: Dispensable?
    private(set) var emitRate: Float = 0
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    let EFFICIENCY_EMIT_RATE: Float = 0.2
    override init() {
        mode = Mode.Hard
        super.init()
        refresh()
    }
    
    func setLives() -> Int {
        switch mode! {
        case .Efficiency:
            lives = Lives.Efficiency
        case .Hard:
            lives = Lives.Hard
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
    
//    func success() -> Void {
//        println( "Success" )
//        switch mode! { // why is '!' necessary here?
//        case Mode.Easy:
//            ++score
//        }
//        scene!.updateScoreLabel()
//    }
//    
    func failure() -> Void {
        //println( "Failure" )
//        switch mode! { // and here
//        case Mode.Easy:
//            --score
//        }
//        scene!.updateScoreLabel()
        --lives
        scene!.updateLivesLabel()
        if lives < 0 {
            scene!.gameOver()
            endGame()
        }
    }

    func cashIn( amount: Int ) -> Void {
        if amount <= 0 { return }
        targetScore += amount
        if scoreUpdateTimer == nil {
            scoreUpdateTimer = NSTimer.scheduledTimerWithTimeInterval( 0.04, target: self, selector: "incrementScore", userInfo: nil, repeats: true )
        }
        if scene!.scoreEffect == nil { scene!.scoreEffect?.stopSystem() }
        let effect = CCBReader.load( "Effects/RainbowFireworks" ) as! CCParticleSystem
        scene!.scoreEffect = effect
        effect.position = scene!.scoreLabel.position
        effect.autoRemoveOnFinish = true
        scene!.addChild( effect )
        if mode != Mode.Efficiency {
            emitRate -= 0.05
        }
    }

    func incrementScore() -> Void {
        if let s = scoreUpdateTimer {
            if ++score >= targetScore {
                s.invalidate()
                scoreUpdateTimer = nil
                if scene!.scoreEffect != nil { scene!.scoreEffect?.stopSystem() }//scene!.scoreEffect!.removeFromParent() }
            }
        }
        scene!.updateScoreLabel()
    }
    
//    func getNextQuarterTime() -> UInt32 {
//        nextQuarter = quarterFrequency
//        if CCRANDOM_0_1() < 0.3 {
//            nextQuarter += quarterFrequency / 2
//        }
//        return nextQuarter
//        // I hate Swift. can't do jack without getting pedantic af
//        // even the dreaded C++ doesn't split hairs between "int" and "unsigned 32-bit int"
//    }
    
    func endGame() -> Void {
        // ?
    }
    
    func restart() -> Void {
        let fadeIn = CCActionFadeIn.actionWithDuration( 0.3 ) as! CCAction
        let reset = CCActionCallBlock.actionWithBlock( { () -> Void in
            let newScene = CCBReader.loadAsScene( "MainScene" )
            CCDirector.sharedDirector().replaceScene( newScene )
            GameState.sharedState.refresh()
            GameState.sharedState.scene!.updateScoreLabel()
            GameState.sharedState.scene!.updateLivesLabel()
        }) as! CCAction
        scene!.overlay.runAction( CCActionSequence.actionWithArray([fadeIn, reset]) as! CCAction )
    }
    
    func refresh() -> Void {
        emitRate = getEmitRate()
        setLives()
        score = 0
    }
    
    func setMode( newMode: Mode ) -> Void {
        mode = newMode;
        refresh()
    }
}
