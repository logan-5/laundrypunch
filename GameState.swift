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
    }
    private(set) var mode: Mode! // linker errors without '!'. I thought it'd work.  I must not understand
    private(set) var score: Int = 0
    
    weak var scene: MainScene?
    weak var currentShirt: Shirt?
    private(set) var emitRate: Float
    let INITIAL_EMIT_RATE: Float = 2 // in seconds
    override init() {
        emitRate = INITIAL_EMIT_RATE
        mode = Mode.Easy
        super.init()
    }
    
    func success() -> Void {
        println( "Success" )
        switch mode! { // why is '!' necessary here?
        case Mode.Easy:
            ++score
        }
        scene!.updateScoreLabel()
    }
    
    func failure() -> Void {
        println( "Failure" )
        switch mode! {
        case Mode.Easy:
            --score
        }
        scene!.updateScoreLabel()
    }
}
