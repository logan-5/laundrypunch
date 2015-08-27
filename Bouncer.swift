//
//  Bouncer.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Bouncer: CCNode {
    
    func didLoadFromCCB() -> Void {
        self.rotation = -90
        self.physicsBody.elasticity = 3.35
        self.physicsBody.collisionType = "bouncer"
    }
}
