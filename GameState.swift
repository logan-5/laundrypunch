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
    private(set) var mode: Mode! // linker errors without '!'. I thought it'd work.  I must not understand
    private(set) var score: Int = 0
    private var quarterFrequency: UInt32 = 10 // you get a quarter every (1 / (quarterFrequency +/- (quarterFrequency / 5))) shirts
    private(set) var nextQuarter: UInt32!
    
    weak var scene: MainScene?
    weak var lastLaunchedObject: CCNode?
    private(set) var emitRate: Float
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    override init() {
        emitRate = INITIAL_EMIT_RATE
        mode = Mode.Easy
        super.init()
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
//    func failure() -> Void {
//        println( "Failure" )
//        switch mode! { // and here
//        case Mode.Easy:
//            --score
//        }
//        scene!.updateScoreLabel()
//    }

    func cashIn( amount: Int ) -> Void {
        score += amount
    }
    
    func getNextQuarterTime() -> UInt32 {
        nextQuarter = UInt32(quarterFrequency) +  arc4random_uniform( quarterFrequency / 5 ) * UInt32( CCRANDOM_MINUS1_1() > 0 ? 1 : -1 )
        return nextQuarter
        // I hate Swift. can't do jack without getting pedantic af
        // even the dreaded C++ doesn't split hairs between "int" and "unsigned 32-bit int"
    }
}
