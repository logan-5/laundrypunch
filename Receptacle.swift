//
//  Receptacle.swift
//  LaundryLaunch
//
//  Created by Logan Smith on 8/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

import UIKit

class Receptacle: CCNode {
    
    weak var sprite: CCNode!
    private(set) var receptacleColor: String!
    private(set) var shirtColor: Shirt.Color!
    private(set) var shirts: [CCNode] = Array()
    let shirtStackOffset: Float = 5
    let receiveTime: Float = 0.3 // seconds
    private var oldPosition = CGPointZero
    
    func didLoadFromCCB() -> Void {
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "receptacle"
        
        switch receptacleColor {
        case "red":
            shirtColor = Shirt.Color.Red
        case "green":
            shirtColor = Shirt.Color.Green
        case "blue":
            shirtColor = Shirt.Color.Blue
        case "yellow":
            shirtColor = Shirt.Color.Yellow
        case "purple":
            fallthrough
        default:
            shirtColor = Shirt.Color.Purple
        }
        
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
    
    func receiveItem( item: CCNode ) -> Void {
        item.physicsBody.sensor = true
        item.physicsBody.affectedByGravity = false
        item.physicsBody.velocity = CGPointZero
        item.physicsBody.angularVelocity = 0
        shirts.append( item )
        var destination = ccp( 0, CGFloat( -shirtStackOffset * Float( shirts.count ) ) )
        destination = ccpRotateByAngle( destination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
        destination = ccpAdd( destination, self.position )
        
        var move: CCAction = CCActionMoveTo.actionWithDuration( CCTime(receiveTime), position: destination ) as CCActionMoveTo
        var rotate: CCAction = CCActionRotateTo.actionWithDuration( CCTime(receiveTime), angle: self.rotation ) as CCActionRotateTo
        move = CCActionEaseSineOut.actionWithAction( move as CCActionMoveTo ) as CCActionEaseSineOut
        rotate = CCActionEaseSineOut.actionWithAction( rotate as CCActionRotateTo ) as CCActionEaseSineOut
        item.runAction( move ); item.runAction( rotate )
        
    }
    
    func killShirt() -> Void {
        if shirts.count == 0 { return }
        let shirt = shirts.removeLast() as Shirt
        shirt.physicsBody.affectedByGravity = true
        shirt.fall()
    }
    
    func doLaundry() -> Void {
        GameState.sharedState.cashIn( shirts.count )
        
        var offScreen = ccp( 0, ( self.contentSize.height + CGFloat( shirtStackOffset * Float( shirts.count ) ) ) )
        offScreen = ccpRotateByAngle( offScreen, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )

        var moveOffScreen: CCAction = CCActionMoveBy.actionWithDuration( 0.3, position: offScreen ) as CCActionMoveBy
        moveOffScreen = CCActionEaseSineInOut.actionWithAction( moveOffScreen as CCActionMoveBy ) as CCAction
        for shirt in shirts {
            let moveShirt = moveOffScreen.copyWithZone( nil ) as CCAction
            shirt.runAction( moveShirt )
        }
        oldPosition = self.position
        var comeBack: CCAction = CCActionMoveTo.actionWithDuration( 0.3, position: oldPosition ) as CCActionMoveTo
        comeBack = CCActionEaseSineInOut.actionWithAction( comeBack as CCActionMoveTo ) as CCAction
        let sequence = CCActionSequence.actionWithArray([moveOffScreen, CCActionCallBlock.actionWithBlock({ () -> Void in
            self.setUpSuccessParticleEffects()
            for shirt in self.shirts {
                shirt.removeFromParent()
            }
            self.shirts.removeAll( keepCapacity: true )
        }), comeBack]) as CCActionSequence
        self.runAction( sequence )
    }
    
    func setUpSuccessParticleEffects() -> Void {
        let rotation: Float = 0 // don't get why this works. adapts correctly to differently-rotated receptacles with no extra code
        // maybe adding a child to a rotated parent rotates the child too?
        // or does something or other to its rotation. I guess probably
        
        // big problems here. can't change particleeffect.totalParticles dynamically. no compiler error, but runtime crashes.  have to resort to hacks.
        var s = 2 * self.shirts.count
        do {
            let successSmellBackground = CCBReader.load( "Effects/SuccessSmellBackground" ) as CCParticleSystem
            successSmellBackground.rotation = rotation
            successSmellBackground.particlePositionType = CCParticleSystemPositionType.Relative
            successSmellBackground.autoRemoveOnFinish = true
            self.addChild( successSmellBackground )
            
            let successSmell = CCBReader.load( "Effects/SuccessSmell" ) as CCParticleSystem
            successSmell.rotation = rotation
            successSmell.particlePositionType = CCParticleSystemPositionType.Relative
            successSmell.autoRemoveOnFinish = true
            self.addChild( successSmell )
            
            let smileyEffect = CCBReader.load( "Effects/Success" ) as CCParticleSystem
            smileyEffect.totalParticles = UInt( 30 * self.shirts.count )
            smileyEffect.rotation = -self.rotation
            smileyEffect.particlePositionType = CCParticleSystemPositionType.Relative
            smileyEffect.autoRemoveOnFinish = true
            self.addChild( smileyEffect )
            s /= 2
        } while s > 2
    }
}
