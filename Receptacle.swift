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
    private var shirts: [Shirt] = Array()
    let shirtStackOffset: Float = 5
    let receiveTime: Float = 0.3 // seconds
    
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
        case Shirt.Color.Red:
            tintColor = CCColor.redColor()
        case Shirt.Color.Blue:
            tintColor = CCColor.blueColor()
        case Shirt.Color.Green:
            tintColor = CCColor.greenColor()
        case Shirt.Color.Yellow:
            tintColor = CCColor.yellowColor()
        case Shirt.Color.Purple:
            fallthrough
        default:
            tintColor = CCColor.purpleColor()
        }
        self.sprite!.color = tintColor
    }
    
    func receiveShirt( shirt: Shirt ) -> Void {
        println( "shirt received" )
        shirt.physicsBody.sensor = true
        shirt.physicsBody.affectedByGravity = false
        shirt.physicsBody.velocity = CGPointZero
        shirt.physicsBody.angularVelocity = 0
        shirts.append( shirt )
        var destination = ccp( 0, CGFloat( -shirtStackOffset * Float( shirts.count ) ) )
        destination = ccpRotateByAngle( destination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
        destination = ccpAdd( destination, self.position )
        
        var move = CCActionMoveTo.actionWithDuration( CCTime(receiveTime), position: destination ) as CCActionMoveTo
        var rotate = CCActionRotateTo.actionWithDuration( CCTime(receiveTime), angle: self.rotation ) as CCActionRotateTo
        shirt.runAction( move ); shirt.runAction( rotate )
        
    }
}
