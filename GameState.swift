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
        //case Impossible
    }
    struct Lives {
        static let Easy = 5
    }
    private(set) var mode: Mode! // linker errors without '!'. I thought it'd work.  I must not understand
    private(set) var score: Int = 0
    private(set) var lives: Int = 0
    private var quarterFrequency: UInt32 = 10 // best case scenario, with a 30% chance of being 1.5* this
    private(set) var nextQuarter: UInt32 = 0
    
    weak var scene: MainScene?
    weak var lastLaunchedObject: Dispensable?
    private(set) var emitRate: Float
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    override init() {
        emitRate = INITIAL_EMIT_RATE
        mode = Mode.Easy
        super.init()
        setLives()
        getNextQuarterTime()
    }
    
    func setLives() -> Int {
        switch mode! {
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
        println( "Failure" )
//        switch mode! { // and here
//        case Mode.Easy:
//            --score
//        }
//        scene!.updateScoreLabel()
        --lives
        scene!.updateLivesLabel()
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
}
