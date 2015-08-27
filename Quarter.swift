//
//  Quarter.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 8/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Quarter: CCNode {
    
    weak var sprite: CCSprite!
    
    let initialXVelocity: CGFloat = 0
    let initialYVelocity: CGFloat = -8
    let bounceSpeed: CGFloat = 600
    var radius: CGFloat!
    var ready = false

    func didLoadFromCCB() -> Void {
        self.physicsBody.velocity = ccp( initialXVelocity, initialYVelocity )
        
        radius = 2*ccpDistance( self.anchorPointInPoints, CGPointZero )
        ready = true
        
        self.physicsBody.collisionType = "quarter"
        
        sprite.scale = Float(self.contentSize.width / sprite.contentSize.width)
    }
    
    override func update(delta: CCTime) -> Void {
        if !ready { return }
        var pos = self.parent.parent.convertToNodeSpace( self.position )
        if  pos.x < -radius ||
            pos.x > radius + CCDirector.sharedDirector().viewSize().width ||
            pos.y < -radius ||
            pos.y > radius + CCDirector.sharedDirector().viewSize().height {
                self.removeFromParent();
        }
    }
}
