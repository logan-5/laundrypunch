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
    private(set) var hasReceivedShirt = false
    static let stackOffset: Float = 5
    let receiveTime: Float = 0.3 // seconds
    let lucky: Double = 0.1 * (GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0)
    var luckyQuarter: Quarter?
    private var oldPosition = CGPointZero
    private var doNotDisturb = false
    private var ready = false
    private var positionReady = false
    private var shouldMove = false//GameState.sharedState.mode == GameState.Mode.Hard

    var moveOffScreen: CCAction?

    // for hard mode
    private var initialPosition: CGPoint!
    private var positionLastFrame: CGPoint!
    private var movement: CCAction?
    
    func didLoadFromCCB() -> Void {
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "receptacle"
        GameState.sharedState.receptacles.append( self )

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
        sprite!.scale = Float(self.contentSize.height / sprite!.contentSize.height)
        sprite!.position = ccp( self.contentSize.width / 2, self.contentSize.height / 2 )
        sprite!.rotation = 180 + self.rotation
        //sprite!.position = ccp( 0, sprite.contentSize.width / CGFloat(sprite!.scale) )

        ready = true
    }

    func setUpMovement() {
        if !shouldMove || movement != nil { return }

        let moveDistance: CGFloat = 25 /// GameState.sharedState.scene!.contentSizeInPoints.height // in either direction

        var upperDestination = ccp( moveDistance, 0 )
        var lowerDestination = ccpMult( upperDestination, -1 )
        upperDestination = ccpRotateByAngle( upperDestination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
        lowerDestination = ccpRotateByAngle( lowerDestination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
        upperDestination = ccpAdd( upperDestination, initialPosition )
        lowerDestination = ccpAdd( lowerDestination, initialPosition )

        var moveUp: CCActionInterval = CCActionMoveTo.actionWithDuration( 1, position: upperDestination ) as! CCActionMoveTo
        moveUp = CCActionEaseSineInOut.actionWithAction( moveUp ) as! CCActionInterval
        let wait = CCActionDelay.actionWithDuration( 0.2 ) as! CCActionDelay
        var moveDown: CCActionInterval = CCActionMoveTo.actionWithDuration( 1, position: lowerDestination ) as! CCActionMoveTo
        moveDown = CCActionEaseSineInOut.actionWithAction( moveDown ) as! CCActionInterval
        let wait2 = wait.copyWithZone( nil ) as! CCActionDelay
        let sequence = CCActionSequence.actionWithArray( [moveUp, wait, moveDown, wait2] ) as! CCActionSequence
        movement = CCActionRepeatForever( action: sequence ) as CCActionRepeatForever
        self.runAction( movement )
    }
    
    func receiveItem( item: Dispensable ) -> Void {
        hasReceivedShirt = true
        item.physicsBody.sensor = true
        item.physicsBody.affectedByGravity = false
        item.physicsBody.velocity = CGPointZero
        item.physicsBody.angularVelocity = 0
        item.physicsBody.collisionType = "stacked"
        item.stacked = true
        shirts.append( item )
        var destination = ccp( 0, CGFloat( -Receptacle.stackOffset * Float( shirts.count ) ) )
        destination = ccpRotateByAngle( destination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
        destination = ccpAdd( destination, self.position )
        destination = ccpSub( destination, item.position )
        if item.trickShot { GameState.sharedState.trickShot( self ) }

        item.stack()
        var move: CCAction = CCActionMoveBy.actionWithDuration( CCTime(receiveTime), position: destination ) as! CCActionMoveBy
        var rotate: CCAction = CCActionRotateTo.actionWithDuration( CCTime(receiveTime), angle: self.rotation ) as! CCActionRotateTo
        move = CCActionEaseSineOut.actionWithAction( move as! CCActionMoveBy ) as! CCActionEaseSineOut
        rotate = CCActionEaseSineOut.actionWithAction( rotate as! CCActionRotateTo ) as! CCActionEaseSineOut
        let store: CCAction = CCActionCallBlock.actionWithBlock { () -> Void in
            if let s = item as? Shirt {
                s.stackedPosition = s.position
                s.physicsBody.collisionType = "storedShirt"
                AchievementManager.sharedManager.notifyStackSize( self.shirts.count )
                GameState.sharedState.stackShirt( self, item: s, forPoints: true )
            }
        } as! CCActionCallBlock
        item.runAction( move )
        item.runAction( CCActionSequence.actionWithArray( [rotate, store] ) as! CCActionSequence )

        GameState.sharedState.playSound( "audioFiles/whoosh.caf" )

        if doNotDisturb {
            item.runAction( moveOffScreen?.copyWithZone( nil ) as! CCAction )
            return
        }

        if let q = item as? Quarter {
            doLaundry( q )
            GameState.sharedState.stackShirt( self, item: q, forPoints: false )
        }
//        if shouldMove {
//            // the movement onto a moving basket looks okay, but it would look even better shrouded by a particle effect
//            let particlePosition = ccpMidpoint( self.position, item.position )
//            //particlePosition = self.convertToNodeSpace( particlePosition )
//            let particles = CCBReader.load( "Effects/RainbowSmell" ) as! CCParticleSystem
//            particles.autoRemoveOnFinish = true
//            particles.position = particlePosition
//            self.parent.addChild( particles )
//        }
    }


    func killShirt() -> Void {
        if shirts.count == 0 { return }
        if let shirt = shirts.removeLast() as? Shirt {
            shirt.physicsBody.affectedByGravity = true
            shirt.fall()
        }
    }
    
    func doLaundry( quarter: Quarter ) -> Void {
        var goldCoin = quarter.gold
        if doNotDisturb || GameState.sharedState.lost { return }
        doNotDisturb = true
        if movement != nil { self.stopAction( movement ); movement = nil }
        // animate
        var offScreen = ccp( 0, ( self.contentSize.height + CGFloat( Receptacle.stackOffset * Float( shirts.count ) ) ) )
        offScreen = ccpRotateByAngle( offScreen, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )

        moveOffScreen = (CCActionEaseSineInOut.actionWithAction( CCActionMoveBy.actionWithDuration( 0.3, position: offScreen ) as! CCActionMoveBy ) as! CCAction)

        for shirt in shirts {
            let moveShirt = moveOffScreen!.copyWithZone( nil ) as! CCAction
            shirt.runAction( moveShirt )
        }
        oldPosition = self.position
        var comeBack: CCAction = CCActionMoveTo.actionWithDuration( 0.3, position: oldPosition ) as! CCActionMoveTo
        comeBack = CCActionEaseSineInOut.actionWithAction( comeBack as! CCActionMoveTo ) as! CCAction
        var sequence = CCActionSequence.actionWithArray([moveOffScreen!, CCActionCallBlock.actionWithBlock({ () -> Void in
            self.setUpSuccessParticleEffects()
            self.cashInLoad( quarter.regurgitated )

            if !goldCoin {
                // gold coins cash in the stack but don't destroy it
                // so destroy if not gold coin
                for shirt in self.shirts {
                    if let q = shirt as? Quarter {
                        self.luckyQuarter = q
                        if probabilityOf( self.lucky ) {
                            self.regurgitateQuarter()
                            continue
                        }
                    }
                    shirt.removeFromParent()
                }
                self.shirts.removeAll( keepCapacity: true )
            } else {
                // but if it is, just remove the coin
                self.shirts.removeLast().removeFromParent()
                // and bring the shirts back
                for shirt in self.shirts {
                    var c: CCAction = CCActionMoveTo.actionWithDuration( 0.3, position: (shirt as! Dispensable).stackedPosition! ) as! CCActionMoveTo
                    //c = CCActionEaseSineInOut.actionWithAction( comeBack as! CCActionMoveTo ) as! CCAction
                    shirt.runAction( c )
                }
            }
        }), comeBack, CCActionCallBlock.actionWithBlock({ () -> Void in
            self.doNotDisturb = false
            self.setUpMovement()
            self.quarterKillSweep()
            GameState.sharedState.checkIfFinished()
        }) as! CCActionCallBlock]) as! CCActionSequence

        self.runAction( sequence )

        GameState.sharedState.playSound( "audioFiles/flush.caf" )
        GameState.sharedState.playSound( "audioFiles/chaching.caf" )
    }

    func quarterKillSweep() {
        // destroy any stray quarters that may still be there
        for node in GameState.sharedState.scene!.myPhysicsNode.children {
            if let q = node as? Quarter {
                if q.physicsBody.collisionType == "stacked" {
                    for var i = 0; i < shirts.count; ++i {
                        if shirts[i] == q {
                            shirts.removeAtIndex( i )
                        }
                    }
                    var sequence = CCActionSequence.actionWithArray([moveOffScreen!.copyWithZone( nil ) as! CCAction, CCActionCallBlock.actionWithBlock({ () -> Void in
                        q.removeFromParent()
                    }) as! CCActionCallBlock]) as! CCActionSequence
                    q.runAction( sequence )
                }
            }
        }
    }

    func regurgitateQuarter() {
        let q = luckyQuarter!
        q.physicsBody.affectedByGravity = true
        q.physicsBody.sensor = false

        let viewHeight = CCDirector.sharedDirector().viewSize().height
        let xForce = 90 /* ( viewHeight / self.positionInPoints.y ) */ * (GameState.sharedState.scene!.bouncer.positionInPoints.x - q.positionInPoints.x )
        let yForce = 18_000 * viewHeight / self.positionInPoints.y
        q.physicsBody.applyForce( ccp( xForce , yForce ) )
        q.physicsBody.collisionType = "restoredQuarter"
        q.regurgitated = true
    }

    func cashInLoad( regurgitated: Bool ) -> Void {
        if GameState.sharedState.lost { return }
        // cash in
        var p = countPointsAndCreateString( regurgitated )
        GameState.sharedState.cashIn( p.points )
        AchievementManager.sharedManager.notifyCashedInColor( self.shirtColor, plus: p.points )

        // set up numerical animation
        let label: CCLabelTTF = CCLabelTTF.labelWithString( p.string, fontName: "Courier", fontSize: 20 )
        label.cascadeColorEnabled = true; label.cascadeOpacityEnabled = true
        label.opacity = 0
        GameState.sharedState.scene?.particleLayer.addChild( label )
        var x: CGFloat
        if self.position.x > GameState.sharedState.scene!.contentSize.width / 2 {
            x = GameState.sharedState.scene!.contentSizeInPoints.width - 100
        } else {
            x = 100
        }
        label.position = ccp( x, self.position.y + self.contentSize.height )
        if p.points > 0 { label.runAction( CCActionAnimateRainbow.instantiate() ) }
        label.runAction( CCActionFadeIn.actionWithDuration( 0.3 ) as! CCActionFadeIn )
        let moveUp: CCAction = CCActionMoveBy.actionWithDuration( 2.5, position: ccp( CGFloat(CCRANDOM_MINUS1_1() * 20), self.contentSize.height * 2 ) ) as! CCActionMoveBy
        label.runAction( moveUp )
        let delay: CCAction = CCActionDelay.actionWithDuration( 1.5 ) as! CCActionDelay
        let fadeOut: CCAction = CCActionFadeOut.actionWithDuration( 0.6 ) as! CCActionFadeOut
        let remove: CCAction = CCActionCallBlock.actionWithBlock { () -> Void in
            label.removeFromParent()
            } as! CCActionCallBlock
        label.runAction( CCActionSequence.actionWithArray([delay, fadeOut, remove]) as! CCActionSequence )
    }

    func countPointsAndCreateString( regurgitated: Bool ) -> ( points: Int64, golds: Int64, string: String ) {
        var points: Int64 = 0
        var string: String = ""
        var prefix: String = ""
        var golds: Int64 = 0

        var modifier: Int64 = 0

        GameState.sharedState.scene!.nextEffect = "Effects/RainbowFireworks"
        for shirt in shirts {
            if let s = shirt as? Shirt {
                if s.isRainbow {
                    modifier += 2
                } else if s.isGold {
                    GameState.sharedState.scene!.nextEffect = "Effects/GoldExplosion"
                    ++GameState.sharedState.goldShirts
                    ++golds
                } else {
                    ++points
                }
            }
        }
        if golds > 0 {
            prefix = String( golds ) + " gold "
        }

        var reg = regurgitated && points > 0
        if reg { modifier = max( modifier * 3, 3 ) }

        // create a string of the format:
        // [# gold] +[score] [x [modifiers]]
        string = prefix + "+" + String( points ) + ( modifier > 0 ? " x " + String( modifier ) : "" ) + ( reg ? " combo!" : "" )

        if modifier > 0 { points *= modifier }
        return ( points, golds, string )
    }
    
    func setUpSuccessParticleEffects() -> Void {
        let rotation: Float = 0 // don't get why this works. adapts correctly to differently-rotated receptacles with no extra code
        // maybe adding a child to a rotated parent rotates the child too?
        // or does something or other to its rotation. I guess probably

        var onlyRainbow = true
        var onlyGold = true
        var shirts: Int = 0
        for shirt in self.shirts {
            if let s = shirt as? Shirt {
                ++shirts
                if !s.isRainbow { onlyRainbow = false }
                if s.isGold { onlyGold = false }
            }
        }

        if onlyRainbow { return }
        // big problems here. can't change particleEffect.totalParticles dynamically. no compiler error, but runtime crashes.  have to resort to hacks.
        var s = 3 * shirts
        do {
            if s > 2 {
                let successSmellBackground = CCBReader.load( "Effects/SuccessSmellBackground" ) as! CCParticleSystem
                successSmellBackground.rotation = rotation
                successSmellBackground.particlePositionType = CCParticleSystemPositionType.Relative
                successSmellBackground.autoRemoveOnFinish = true
                self.addChild( successSmellBackground )
                
                let successSmell = CCBReader.load( "Effects/SuccessSmell" ) as! CCParticleSystem
                successSmell.rotation = rotation
                successSmell.particlePositionType = CCParticleSystemPositionType.Relative
                successSmell.autoRemoveOnFinish = true
                self.addChild( successSmell )
                
                let smileyEffect = CCBReader.load( "Effects/Success" ) as! CCParticleSystem
                smileyEffect.totalParticles = UInt( 30 * self.shirts.count )
                smileyEffect.rotation = -self.rotation
                smileyEffect.particlePositionType = CCParticleSystemPositionType.Relative
                smileyEffect.autoRemoveOnFinish = true
                self.addChild( smileyEffect )
                s /= 2
            } else {
                break
            }
        } while !GameState.sharedState.lowFXMode || onlyGold
    }

    override func update(delta: CCTime) {
        if !ready { return }
        if self.parent != nil && !positionReady {
            positionReady = true
            let pos = self.position
            self.positionType = CCPositionTypeMake( CCPositionUnit.Points, CCPositionUnit.Points, CCPositionReferenceCorner.BottomLeft )
            self.position = ccp(pos.x * self.parent.contentSizeInPoints.width, pos.y * self.parent.contentSizeInPoints.height)

            initialPosition = self.position
            positionLastFrame = self.position
        }
        setUpMovement()
        if !doNotDisturb && shouldMove && !CGPointEqualToPoint( positionLastFrame, self.position ) {
            for shirt in shirts {
                shirt.position.y = self.position.y
            }
            positionLastFrame = self.position
        }
    }
}
