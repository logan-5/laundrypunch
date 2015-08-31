//
//  GameState.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class GameState: NSObject {
    class var sharedState: GameState {
        get { return sharedInstance.sharedState }
    }
    private struct sharedInstance { static let sharedState = GameState() }
    
    enum Mode {
        case Easy
        case Hard
    }
    struct Lives {
        static let Easy = 5
        static let Hard = 0
    }
    private(set) var mode: Mode! // linker errors without '!'. I thought it'd work.  I must not understand
    private(set) var score: Int = 0
    private(set) var lives: Int = 0
    private var quarterFrequency: UInt32 = 10 // best case scenario, with a 30% chance of being 1.5* this
    private(set) var nextQuarter: UInt32 = 0
    
    weak var scene: MainScene?
    weak var lastLaunchedObject: Dispensable?
    private(set) var emitRate: Float!
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    override init() {
        mode = Mode.Easy
        super.init()
        refresh()
    }
    
    func setLives() -> Int {
        switch mode! {
        case .Hard:
            lives = Lives.Hard
        case .Easy:
            fallthrough
        default:
            lives = Lives.Easy
        }
        return lives
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
        score += amount
        scene!.updateScoreLabel()
    }
    
    func getNextQuarterTime() -> UInt32 {
        nextQuarter = quarterFrequency
        if CCRANDOM_0_1() < 0.3 {
            nextQuarter += quarterFrequency / 2
        }
        return nextQuarter
        // I hate Swift. can't do jack without getting pedantic af
        // even the dreaded C++ doesn't split hairs between "int" and "unsigned 32-bit int"
    }
    
    func endGame() -> Void {
        println( "game over" )
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
        emitRate = INITIAL_EMIT_RATE
        setLives()
        getNextQuarterTime()
        score = 0
    }
    
    func setMode( newMode: Mode ) -> Void {
        mode = newMode;
        setLives()
    }
}
