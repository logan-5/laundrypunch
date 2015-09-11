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
    
    let isRainbow = true//probabilityOf( 0.04 * (GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0) * (GameState.sharedState.emittedFirstShirt ? 1 : 0) )
    let isGold: Bool = probabilityOf( 0.03 * (GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0) )
    weak var sparkler: FreeParticles?
    var rainbowAnimation: CCAction?
    static var shirtContentSize: CGSize!

    var displayDying = false
    
    weak var sprite: CCNode?
    var shirtColor: Color!
    
    override func didLoadFromCCB() -> Void {
        Shirt.shirtContentSize = self.contentSizeInPoints
        initialXVelocity = 0
        initialYVelocity = -8
        maxInitialAngularMomentum = 10
        bounceSpeed = 600
        super.didLoadFromCCB()
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "shirt"
        self.physicsBody.collisionGroup = "shirt"
        
        // choose sprite
        let shirtSprite = CCSprite.spriteWithImageNamed( getShirtSprite() ) as! CCSprite
        sprite = shirtSprite
        sprite!.position = CGPointZero
        self.addChild( sprite )
        sprite!.scale = Float( self.contentSize.height / sprite!.contentSize.height )
        self.contentSize = CGSizeMake( sprite!.contentSize.width * CGFloat( sprite!.scale ), self.contentSize.height )
        sprite!.anchorPoint = CGPointZero
        
        self.cascadeColorEnabled = true
        if isRainbow && (GameState.sharedState.scene != nil) {
            rainbowAnimation = CCActionAnimateRainbow.instantiate()
            self.runAction( rainbowAnimation )
        } else if isGold {
            if !GameState.sharedState.lowFXMode && GameState.sharedState.scene != nil {
                let sparkle = CCBReader.load( "Effects/GoldSparkle" ) as! FreeParticles
                sparkle.particlePositionType = CCParticleSystemPositionType.Free
                GameState.sharedState.scene!.addChild( sparkle )
                sparkle.object = self
                sparkler = sparkle
            }
        } else {
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
            self.color = tintColor
        }

        if isGold {
            GameState.sharedState.playSound( "audioFiles/sparkle.caf" )
        } else {
            GameState.sharedState.playSound( "audioFiles/whoosh.caf" )
        }
    }
    
    func getShirtSprite() -> String {
        /*let numberOfItems = Float( clothesSprites.count ) // types in Swift are a freakin' disaster
        let upperBound = UInt32( min( max( Float( GameState.sharedState.score ) / 3, 1 ), numberOfItems - 1 ) )
        return "clothesSprites/" + clothesSprites[Int( arc4random_uniform( upperBound ) )] + ".png" // file extension apparently required in Swift*/
        let shirts = Data.sharedData.unlockedShirts
        let shirt = (shirts.objectAtIndex(Int(arc4random_uniform( UInt32(shirts.count) ))) as! String)
        return "clothesSprites/" + shirt + ".png"
    }

//    func stack( color: Color ) -> Void {
//        if let r = rainbowAnimation {
//            self.sprite!.stopAction( rainbowAnimation )
//            var tint: CCActionTintTo?;
//
//            switch color {
//            case .Blue:
//                tint = CCActionTintTo.actionWithDuration( 0, color: CCColor.blueColor() ) as? CCActionTintTo
//            case .Green:
//                tint = CCActionTintTo.actionWithDuration( 0, color: CCColor.greenColor() ) as? CCActionTintTo
//            case .Purple:
//                tint = CCActionTintTo.actionWithDuration( 0, color: CCColor.purpleColor() ) as? CCActionTintTo
//            case .Red:
//                tint = CCActionTintTo.actionWithDuration( 0, color: CCColor.redColor() ) as? CCActionTintTo
//            case .Yellow:
//                fallthrough
//            default:
//                tint = CCActionTintTo.actionWithDuration( 0, color: CCColor.yellowColor() ) as? CCActionTintTo
//            }
//            if let t = tint {
//                self.sprite!.runAction( t )
//            }
//        }
//    }

    // for debugging only
//    override func update(delta: CCTime) {
//        if isGold && sparkler == nil {
//            println( "aha!" )
//        }
//    }
}
