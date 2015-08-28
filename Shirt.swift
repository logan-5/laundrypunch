//
//  Shirt.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Shirt: CCNode {
    enum Color: UInt32 {
        case Red
        case Blue
        case Green
        case Yellow
        case Purple
        
        // very clever, http://stackoverflow.com/questions/26261011/swift-chose-a-random-enumeration-value
        static func randomColor() -> Color {
            // find the maximum enum value
            var maxValue: UInt32 = 0
            while let _ = self.init( rawValue:++maxValue ) {}
            
            // pick and return a new value
            let rand = arc4random_uniform(maxValue)
            return self.init( rawValue:rand )!
        }
    }
    
    let clothesSprites = ["tee", "polo", "girlstank", "ssbuttondown", "girlshirt", "lsbuttondown", "stripper"]
    
    weak var sprite: CCNode?
    let initialXVelocity: CGFloat = 0
    let initialYVelocity: CGFloat = -8
    let maxInitialAngularMomentum: Float = 10
    let bounceSpeed: CGFloat = 600
    var shirtColor: Color!
    var radius: CGFloat!
    var ready = false
    
    func didLoadFromCCB() -> Void {
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.velocity = ccp( initialXVelocity, initialYVelocity )
        self.physicsBody.angularVelocity = CGFloat( CCRANDOM_0_1() * maxInitialAngularMomentum * ( CCRANDOM_MINUS1_1() > 0 ? 1 : -1 ) )
        //self.physicsBody.allowsRotation = false
        //        self.physicsBody.allowsRotation = false // for noob version
        radius = 2*ccpDistance( self.anchorPointInPoints, CGPointZero )
        ready = true
        self.physicsBody.collisionType = "shirt";
        
        // choose sprite
        var shirtSprite = CCSprite.spriteWithImageNamed( getShirtSprite() ) as CCSprite
        sprite = shirtSprite
        sprite!.anchorPoint = CGPointZero
        sprite!.position = CGPointZero
        self.addChild( sprite )
        sprite!.scale = Float( self.contentSize.height / sprite!.contentSize.height )
        self.contentSize = CGSizeMake( sprite!.contentSize.width * CGFloat( sprite!.scale ), self.contentSize.height )
        
        var tintColor: CCColor!
        switch shirtColor! {
        case .Red:
            tintColor = CCColor.redColor()
        case .Blue:
            tintColor = CCColor.blueColor()
        case .Green:
            tintColor = CCColor.greenColor()
        case .Yellow:
            tintColor = CCColor.yellowColor()
        case .Purple:
            fallthrough
        default:
            tintColor = CCColor.purpleColor()
        }
        self.sprite!.color = tintColor
    }
    
    func getShirtSprite() -> String {
        var numberOfItems = Float( clothesSprites.count ) // types in Swift are a freakin' disaster
        var upperBound = UInt32( min( max( Float( GameState.sharedState.score ) / 3, 1 ), numberOfItems - 1 ) )
        return "clothesSprites/" + clothesSprites[Int( arc4random_uniform( upperBound ) )] + ".png" // file extension apparently required in Swift
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
    
    func fall() -> Void {
        self.physicsBody.sensor = true
        self.physicsBody.velocity = CGPointZero
        self.physicsBody.collisionType = "failedShirt"
    }
}
