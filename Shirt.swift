//
//  Shirt.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Shirt: Dispensable {
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
    var shirtColor: Color!
    
    override func didLoadFromCCB() -> Void {
        initialXVelocity = 0
        initialYVelocity = -8
        maxInitialAngularMomentum = 10
        bounceSpeed = 600
        super.didLoadFromCCB()
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "shirt";
        
        // choose sprite
        let shirtSprite = CCSprite.spriteWithImageNamed( getShirtSprite() ) as CCSprite
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
        let numberOfItems = Float( clothesSprites.count ) // types in Swift are a freakin' disaster
        let upperBound = UInt32( min( max( Float( GameState.sharedState.score ) / 3, 1 ), numberOfItems - 1 ) )
        return "clothesSprites/" + clothesSprites[Int( arc4random_uniform( upperBound ) )] + ".png" // file extension apparently required in Swift
    }
}
