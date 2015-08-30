//
//  Bouncer.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Bouncer: CCNode {
    
    weak var handle: Handle!
    
    func didLoadFromCCB() -> Void {
        self.rotation = -90
        self.physicsBody.elasticity = 3.35
        self.physicsBody.collisionType = "bouncer"
    }
    
    func updateAngle( position: CGPoint ) -> Void {
        var direction = ccpSub( position, self.positionInPoints )
        var angle = Float( ccpToAngle( direction ) )
        angle = 180 - CC_RADIANS_TO_DEGREES( angle )
        self.rotation = angle
    }
}
