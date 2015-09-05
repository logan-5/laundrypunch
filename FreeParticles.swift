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

    func didLoadFromCCB() -> Void {
        self.autoRemoveOnFinish = true
    }

    override func update(delta: CCTime) {
        if ready && object == nil {
            self.stopSystem()
        } else if ready {
            self.position = object!.position
        }
        super.update( delta )
    }
}
