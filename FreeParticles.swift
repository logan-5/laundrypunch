//
//  FreeParticles.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class FreeParticles: CCParticleSystem {

    // fakes a parent-child ccnode relationship between particles and an object
    weak var object: CCNode?
    var ready = false
    var stopped = false

    override func update(delta: CCTime) {
        super.update( delta )
        if !ready && object != nil {
            ready = true
            self.autoRemoveOnFinish = true
            return
        } else if ready && object == nil && !stopped {
            self.stopSystem()
            stopped = true
        } else if ready && !stopped {
            self.position = object!.position
        }
    }

    // for debugging
    override func onExit() {
        super.onExit()
        if object != nil {
            var i = 1
        }
    }
}
