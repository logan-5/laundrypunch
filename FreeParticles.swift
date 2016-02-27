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
        //guard self != nil else { return }
        if self.parent == nil { return }
        if !ready && object != nil {
            ready = true
            return
        } else if ready && ( object == nil || object?.visible == false ) && !stopped {
            self.autoRemoveOnFinish = true
            self.stopSystem()
            stopped = true
        } else if ready && !stopped {
            self.position = object!.position
        }
        super.update( delta )
    }

    // for debugging
    override func onExit() {
        super.onExit()
        if object != nil {
            _ = 1
        }
    }
}
