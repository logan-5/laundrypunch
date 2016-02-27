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
    private(set) var shirts: [Dispensable] = Array()
    private(set) var hasReceivedShirt = false
    static let stackOffset: Float = 5
    let receiveTime: Float = 0.3 // seconds
    let lucky: Double = 0.1 * (GameState.sharedState.modeInfo.specialEventsActive ? 1 : 0)
    var luckyQuarter: Quarter?
    private var oldPosition = CGPointZero
    private var doNotDisturb = false
    private var ready = false
    private var positionReady = false
    private var shouldMove = false//gameState.mode == GameState.Mode.Hard

    var moveOffScreen: CCAction?

    // for hard mode
    private var initialPosition: CGPoint!
    private var positionLastFrame: CGPoint!
    private var movement: CCAction?

    // effects
    let successSmellBackground = CCBReader.load( "Effects/SuccessSmellBackground" ) as! CCParticleSystem
    let successSmell = CCBReader.load( "Effects/SuccessSmell" ) as! CCParticleSystem
    let smileyEffect = CCBReader.load( "Effects/Success" ) as! CCParticleSystem

    let gameState = GameState.sharedState

    func didLoadFromCCB() -> Void {
        shirtColor = Shirt.Color.randomColor()
        self.physicsBody.collisionType = "receptacle"
        gameState.receptacles.append( self )

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

        let moveDistance: CGFloat = 25 /// gameState.scene!.contentSizeInPoints.height // in either direction

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

        //item.physicsBody.type = CCPhysicsBodyType.Static
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
        if item.trickShot { gameState.trickShot( self ) }
        gameState.checkMayhemSkillshot()
        --gameState.liveObjects
        item.decremented = true
        gameState.checkBouncyTrickshot( item.bounces, firstOut: item.firstOut )

        item.stack()
        var move: CCAction = CCActionMoveBy.actionWithDuration( CCTime(receiveTime), position: destination ) as! CCActionMoveBy
        var rotate: CCAction = CCActionRotateTo.actionWithDuration( CCTime(receiveTime), angle: self.rotation ) as! CCActionRotateTo
        move = CCActionEaseSineOut.actionWithAction( move as! CCActionMoveBy ) as! CCActionEaseSineOut
        rotate = CCActionEaseSineOut.actionWithAction( rotate as! CCActionRotateTo ) as! CCActionEaseSineOut
        let store: CCAction = CCActionCallBlock.actionWithBlock { () -> Void in
            if let s = item as? Shirt {
                s.stackedPosition = s.position
                s.physicsBody.collisionType = "storedShirt"
                AchievementManager.sharedManager.notifyStackSize( self.shirts.count, color: self.shirtColor )
                self.gameState.stackShirt( self, item: s, forPoints: true )
            }
        } as! CCActionCallBlock
        item.runAction( move )
        item.runAction( CCActionSequence.actionWithArray( [rotate, store] ) as! CCActionSequence )

        gameState.playSound( "audioFiles/whoosh.caf" )

        if doNotDisturb {
            item.runAction( moveOffScreen?.copyWithZone( nil ) as! CCAction )
            return
        }

        if let q = item as? Quarter {
            doLaundry( q )
            gameState.stackShirt( self, item: q, forPoints: false )
        } else {
            hasReceivedShirt = true
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
            //shirt.physicsBody.affectedByGravity = true
            shirt.fall()
        }
    }
    
    func doLaundry( quarter: Quarter ) -> Void {
        if doNotDisturb || gameState.lost { return }
        doNotDisturb = true
        let goldCoin = quarter.gold
        if movement != nil { self.stopAction( movement ); movement = nil }
        // animate
        var offScreen = ccp( 0, ( self.contentSize.height + CGFloat( Receptacle.stackOffset * Float( shirts.count ) ) ) )
        offScreen = ccpRotateByAngle( offScreen, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )

        moveOffScreen = (CCActionEaseSineInOut.actionWithAction( CCActionMoveBy.actionWithDuration( 0.3, position: offScreen ) as! CCActionMoveBy ) as! CCAction)

        for shirt in shirts {
            let moveShirt = moveOffScreen!.copyWithZone( nil ) as! CCActionFiniteTime
            //shirt.comeBack = ( (moveShirt.copyWithZone( nil ) as! CCActionFiniteTime).reverse() )
            shirt.runAction( moveShirt )
        }
        oldPosition = self.position
        var comeBack: CCAction = CCActionMoveTo.actionWithDuration( 0.3, position: oldPosition ) as! CCActionMoveTo
        comeBack = CCActionEaseSineInOut.actionWithAction( comeBack as! CCActionMoveTo ) as! CCAction
        let sequence = CCActionSequence.actionWithArray([moveOffScreen!, CCActionCallBlock.actionWithBlock({ () -> Void in
            self.setUpSuccessParticleEffects()
            self.cashInLoad( quarter.regurgitated )

            if !goldCoin {
                // print( "silver cash in" )
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
                    DispensableCache.sharedCache.killObject( shirt )
                }
                self.shirts.removeAll( keepCapacity: true )
            } else {
                // print( "gold cash in" )
                // but if it is, just remove the coin(s)
//                var removeList: [Int] = Array()
//                for var i = 0; i < self.shirts.count; ++i {
//                    if let _ = self.shirts[i] as? Shirt { } else {
//                        removeList.append( i )
//                    }
//                }
                var removeList: [Dispensable] = Array()
                for item in self.shirts {
                    guard let _ = item as? Quarter else { continue }
                    removeList.append( item )
                }
                for n in removeList {
                    DispensableCache.sharedCache.killObject( self.shirts.removeAtIndex( self.shirts.indexOf( n )! ) )
                }
                let restackShirts = removeList.count > 1
                removeList.removeAll()

                if restackShirts {
                    // inefficient, I think. so hopefully not. only if multiple quarters flew in at the same time
                    for var i = 0; i < self.shirts.count; ++i {
                        // bring shirts back
                        var destination = ccp( 0, CGFloat( -Receptacle.stackOffset * Float( i + 1 ) ) )
                        destination = ccpRotateByAngle( destination, CGPointZero, CC_DEGREES_TO_RADIANS( self.rotation ) )
                        destination = ccpAdd( destination, self.oldPosition )
                        destination = ccpSub( destination, self.shirts[i].position )

                        var move: CCAction = CCActionMoveBy.actionWithDuration( CCTime(self.receiveTime), position: destination ) as! CCActionMoveBy
                        move = CCActionEaseSineOut.actionWithAction( move as! CCActionMoveBy ) as! CCActionEaseSineOut
                        self.shirts[i].runAction( move )
                    }
                    // print( "re-stacked shirts" )
                } else {
                    // faster I think
                    for shirt in self.shirts {
                        let c: CCAction = CCActionMoveTo.actionWithDuration( 0.3, position: shirt.stackedPosition! ) as! CCActionMoveTo
                        //c = CCActionEaseSineInOut.actionWithAction( comeBack as! CCActionMoveTo ) as! CCAction
                        shirt.runAction( c )
                    }
                }
            }
        }), comeBack, CCActionCallBlock.actionWithBlock({ () -> Void in
            self.doNotDisturb = false
            self.setUpMovement()
            self.quarterKillSweep()
            self.gameState.checkIfFinished()
        }) as! CCActionCallBlock]) as! CCActionSequence

        self.runAction( sequence )

        gameState.playSound( "audioFiles/flush.caf" )
        gameState.playSound( "audioFiles/chaching.caf" )
    }

    func quarterKillSweep() {
        // destroy any stray quarters that may still be there
        for node in gameState.scene!.myPhysicsNode.children {
            if let q = node as? Quarter {
                if q.visible && q.physicsBody.collisionType == "stacked" {
                    for var i = 0; i < shirts.count; ++i {
                        if shirts[i] == q {
                            shirts.removeAtIndex( i )
                        }
                    }
                    let sequence = CCActionSequence.actionWithArray([moveOffScreen!.copyWithZone( nil ) as! CCAction, CCActionCallBlock.actionWithBlock({ () -> Void in
                        DispensableCache.sharedCache.killObject( q )
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
        let xForce = 90 /* ( viewHeight / self.positionInPoints.y ) */ * (gameState.scene!.bouncer.positionInPoints.x - q.positionInPoints.x )
        let yForce = 18_000 * viewHeight / self.positionInPoints.y
        q.physicsBody.applyForce( ccp( xForce , yForce ) )
        q.physicsBody.collisionType = "restoredQuarter"
        q.regurgitated = true
        ++gameState.liveObjects
    }

    func cashInLoad( regurgitated: Bool ) -> Void {
        if gameState.lost { return }
        // cash in
        let p = countPointsAndCreateString( regurgitated )
        gameState.cashIn( p.points )
        AchievementManager.sharedManager.notifyCashedInColor( self.shirtColor, plus: p.points )

        // set up numerical animation
        let label: CCLabelTTF = CCLabelTTF.labelWithString( p.string, fontName: "Courier", fontSize: 20 )
        label.cascadeColorEnabled = true; label.cascadeOpacityEnabled = true
        label.opacity = 0
        gameState.scene?.particleLayer.addChild( label )
        var x: CGFloat
        if self.position.x > gameState.scene!.contentSize.width / 2 {
            x = gameState.scene!.contentSizeInPoints.width - 100
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

        gameState.scene!.nextEffect = "Effects/RainbowFireworks"
        for shirt in shirts {
            if let s = shirt as? Shirt {
                if s.isRainbow == true {
                    modifier += 2
                } else if s.isGold == true {
                    gameState.scene!.nextEffect = "Effects/GoldExplosion"
                    ++gameState.goldShirts
                    ++golds
                } else {
                    ++points
                }
            }
        }
        if golds > 0 {
            prefix = String( golds ) + " gold "
        }

        let reg = regurgitated && points > 0
        if reg { modifier = max( modifier * 3, 3 ) }

        // create a string of the format:
        // [# gold] +[score] [x [modifiers]]
        string = prefix + "+" + String( points ) + ( modifier > 0 ? " \u{00D7} " + String( modifier ) : "" ) + ( reg ? " combo!" : "" )

        if modifier > 0 { points *= modifier }
        return ( points, golds, string )
    }
    
    func setUpSuccessParticleEffects() -> Void {
        var onlyRainbow = true
        for shirt in self.shirts {
            if let s = shirt as? Shirt {
                if s.isRainbow == false {
                    onlyRainbow = false
                    break
                }
            }
        }

        if onlyRainbow { return }

        successSmellBackground.totalParticles = UInt( 30 * max(self.shirts.count / 5, 1) )
        successSmellBackground.particlePositionType = CCParticleSystemPositionType.Relative
        if successSmellBackground.parent == nil {
                self.addChild( successSmellBackground )
        } else {
            successSmellBackground.resetSystem()
        }

        successSmell.totalParticles = UInt( 105 * max(self.shirts.count / 5, 1) )
        successSmell.particlePositionType = CCParticleSystemPositionType.Relative
        if successSmellBackground.parent == nil {
                self.addChild( successSmell )
        } else {
            successSmellBackground.resetSystem()
        }

        smileyEffect.totalParticles = UInt( 30 * self.shirts.count )
        smileyEffect.rotation = -self.rotation
        smileyEffect.particlePositionType = CCParticleSystemPositionType.Relative
        //smileyEffect.autoRemoveOnFinish = true
        if smileyEffect.parent == nil {
            self.addChild( smileyEffect )
        } else {
            smileyEffect.resetSystem()
        }
    }

    override func update(delta: CCTime) {
        if !ready { return }
        if self.parent != nil && !positionReady {
            positionReady = true
            let pos = self.position
            self.positionType = CCPositionTypeMake( CCPositionUnit.Points, CCPositionUnit.Points, CCPositionReferenceCorner.BottomLeft )
            self.position = ccp(pos.x * self.parent!.contentSizeInPoints.width, pos.y * self.parent!.contentSizeInPoints.height)

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
