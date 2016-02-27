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
    
    var isRainbow: Bool!
    var isGold: Bool!
    weak var sparkler: FreeParticles?
    var rainbowAnimation: CCAction?
    static var shirtContentSize: CGSize!

    var displayDying = false
    
    var shirtColor: Color!

    override func initialize() {
        Shirt.shirtContentSize = self.contentSizeInPoints
        initialXVelocity = 0
        initialYVelocity = -8
        maxInitialAngularMomentum = 10
        bounceSpeed = 600
        super.initialize()
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "shirt"
        self.physicsBody.collisionGroup = "shirt"

        // choose sprite
        let shirtSprite = CCSprite.spriteWithImageNamed( getShirtSprite() ) as! CCSprite
        sprite?.removeFromParent()
        sprite = shirtSprite
        sprite!.position = CGPointZero
        self.addChild( sprite )
        sprite!.scale = Float( self.contentSize.height / sprite!.contentSize.height )
        spriteScale = sprite.scale
        self.contentSize = CGSizeMake( sprite!.contentSize.width * CGFloat( sprite!.scale ), self.contentSize.height )
        sprite!.anchorPoint = CGPointZero

        self.cascadeColorEnabled = true
        recalculateRainbowOrGold()
        if isRainbow == true && (GameState.sharedState.scene != nil) {
            rainbowAnimation = CCActionAnimateRainbow.instantiate()
            self.runAction( rainbowAnimation )
        } else if isGold == true {
            if !GameState.sharedState.lowFXMode && GameState.sharedState.scene != nil {
                let sparkle = CCBReader.load( "Effects/GoldSparkle" ) as! FreeParticles
                sparkle.particlePositionType = CCParticleSystemPositionType.Free
                GameState.sharedState.scene!.addChild( sparkle )
                sparkle.object = self
                sparkler = sparkle
                GameState.sharedState.playSound( "audioFiles/sparkle.caf" )
            }
        } else {
            if rainbowAnimation != nil { stopAction( rainbowAnimation ) }
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
            GameState.sharedState.playSound( "audioFiles/whoosh.caf" )
        }
    }

    func recalculateRainbowOrGold() {
        isRainbow = probabilityOf( 0.04 * (GameState.sharedState.modeInfo.allowRainbowShirts ? 1 : 0) * (GameState.sharedState.emittedFirstShirt ? 1 : 0) )
        isGold = probabilityOf( 0.04 * (GameState.sharedState.modeInfo.allowGoldShirts ? 1 : 0) * (GameState.sharedState.emittedFirstShirt ? 1 : 0) )
    }
    
    func getShirtSprite() -> String {
        let shirts = Data.sharedData.unlockedShirts
        let shirt = (shirts.objectAtIndex(Int(arc4random_uniform( UInt32(shirts.count) ))) as! String)
        return "clothesSprites/" + shirt + ".png"
    }
}
