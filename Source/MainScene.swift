import UIKit

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    private(set) weak var bouncer: Bouncer!
    private(set) weak var inflow: Inflow!
    private(set) weak var nozzle: CCSprite!
    private(set) weak var handle: BouncerHandle!
    private(set) weak var myPhysicsNode: CCPhysicsNode!
    private(set) weak var scoreLabel: CCLabelBMFont!//CCLabelTTF!
    private(set) weak var modeLabel: CCLabelTTF!
    private(set) weak var restartButton: CCButton!
    private(set) weak var dieButton: CCButton!
    private(set) weak var pauseButton: CCButton!
    private(set) weak var particleLayer: CCNode!
    weak var scoreEffect: CCParticleSystem?
    private(set) weak var background: CCSprite!
    private(set) weak var overlay: CCSprite!
    private(set) var endGameFalling = false
    var nextEffect: String!
    var hasBeenTouched = false

    let gameState = GameState.sharedState
    
    func didLoadFromCCB() -> Void {
        gameState.scene = self
        print( "loaded main scene" )
        self.userInteractionEnabled = false
        myPhysicsNode.collisionDelegate = self
        updateScoreLabel()
        nozzle.zOrder = 2
        scoreLabel.zOrder = 2
        scoreLabel.setAlignment( CCTextAlignment.Center )
        restartButton.background.margin = 0
        dieButton.background.margin = 0
        modeLabel.string = Data.sharedData.modeName + " mode"
        modeLabel.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )

        background.scale = Float(CCDirector.sharedDirector().viewSizeInPixels().width / background.contentSizeInPoints.width)
        overlay.scale = Float(CCDirector.sharedDirector().viewSizeInPixels().width / overlay.contentSizeInPoints.width)
        overlay.zOrder = 100
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        overlay.runAction( fadeOut )

        myPhysicsNode.gravity = gameState.modeInfo.worldGravity

        particleLayer.zOrder = 4

//        originalScoreLabelContentSizeWidth = scoreLabel.contentSizeInPoints.width
//        originalScoreLabelContentSizeFrac = Float( originalScoreLabelContentSizeWidth / self.contentSizeInPoints.width)
        //
        //myPhysicsNode.debugDraw = true
    }

    override func addChild(node: CCNode!) {
        if let _ = node as? CCParticleSystem {
            if particleLayer != nil && !gameState.lost {
                particleLayer.addChild( node )
                return
            }
        }
        super.addChild( node )
    }

    func pause() {
        if gameState.lost { return }
        myPhysicsNode.paused = !myPhysicsNode.paused
        particleLayer.paused = myPhysicsNode.paused
        
        if !myPhysicsNode.paused {
            pauseButton.cascadeOpacityEnabled = true
            pauseButton.enabled = false
            pauseButton.opacity = 0
            let fadeIn = CCActionFadeIn.actionWithDuration( 2 ) as! CCActionFadeIn
            let enable = CCActionCallBlock.actionWithBlock({ () -> Void in
                self.pauseButton.enabled = true
            }) as! CCActionCallBlock
            pauseButton.runAction( CCActionSequence.actionWithArray([fadeIn, enable]) as! CCActionSequence )
        }
    }

    func isPaused() -> Bool {
        return myPhysicsNode.paused
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, animateSensor: CCNode!, wildcard: CCNode!) -> ObjCBool {
        if !gameState.lost && ( wildcard.physicsBody.collisionType == "shirt" || wildcard.physicsBody.collisionType == "quarter" || wildcard.physicsBody.collisionType == "restoredQuarter" ) {
            bouncer.animateGlove()
        }
        return false
    }
    
    func ccPhysicsCollisionBegin( pair:CCPhysicsCollisionPair!, shirt:Shirt!, bouncer:Bouncer! ) -> ObjCBool  {
        guard !shirt.justBounced else { return false }
        let shirtSpeed = shirt.bounceSpeed //ccpLength( shirt.physicsBody.velocity )
        //print( "shirt speed = " + String( shirtSpeed ) )
        var shirtNewVelocity = ccp( shirtSpeed, 0 )
        shirtNewVelocity = ccpRotateByAngle( shirtNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        shirt.physicsBody.velocity = ccp( -shirtNewVelocity.x, shirtNewVelocity.y )
        shirt.startTrickShotTimer()
        shirt.startBounceTimer()

        return false
    }

    func ccPhysicsCollisionBegin( pair:CCPhysicsCollisionPair!, quarter:Quarter!, bouncer:Bouncer! ) -> ObjCBool {
        guard !quarter.justBounced else { return false }
        let quarterSpeed = quarter.bounceSpeed
        var quarterNewVelocity = ccp( quarterSpeed, 0 )
        quarterNewVelocity = ccpRotateByAngle( quarterNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        quarter.physicsBody.velocity = ccp( -quarterNewVelocity.x, quarterNewVelocity.y )
        quarter.startTrickShotTimer()
        quarter.startBounceTimer()

        print( "bounce" )
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, restoredQuarter quarter: Quarter!, bouncer: Bouncer!) -> ObjCBool  {
        quarter.physicsBody.collisionType = "quarter"
        guard !quarter.justBounced else { return false }
        let quarterSpeed = quarter.bounceSpeed
        var quarterNewVelocity = ccp( quarterSpeed, 0 )
        quarterNewVelocity = ccpRotateByAngle( quarterNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        quarter.physicsBody.velocity = ccp( -quarterNewVelocity.x, quarterNewVelocity.y )
        quarter.startTrickShotTimer()
        quarter.startBounceTimer()

        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, quarter: CCNode!, shirt: CCNode!) -> ObjCBool {
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, restoredQuarter: CCNode!, shirt: CCNode!) -> ObjCBool {
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, restoredQuarter: CCNode!, receptacle: CCNode!) -> ObjCBool {
        return false
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, restoredQuarter: CCNode!, quarter: CCNode!) -> ObjCBool {
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, quarter: CCNode!, quarter quarter2: CCNode!) -> ObjCBool {
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shirt shirt1: CCNode!, shirt shirt2: CCNode!) -> ObjCBool {
        return false
    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shirt: Shirt!, receptacle: Receptacle!) -> ObjCBool {
        if gameState.lost { return false }
        if shirt.isRainbow == true  || shirt.isGold == true || shirt.shirtColor == receptacle.shirtColor {
            receptacle.receiveItem( shirt )
        } else {
            gameState.failure()
            shirt.fall()
            --gameState.liveObjects
            shirt.decremented = true
            if gameState.mode != GameState.Mode.Efficiency { // efficiency mode is too hard if it kills previously stacked shirts
                receptacle.killShirt()
            }
            runFailParticles( shirt.position )
            gameState.playSound( "audioFiles/explosion.caf" )
        }
        return false
    }
    
    private func runFailParticles( position: CGPoint ) -> Void {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = position
        addChild( failEffectSmell )
        
        let failEffect = CCBReader.load( "Effects/Failure" ) as! CCParticleSystem
        failEffect.autoRemoveOnFinish = true
        failEffect.position = position
        let particles = 1.0 / Float( max(gameState.lives, 1) ) * 80.0
        failEffect.totalParticles = UInt( 20 + UInt( max( particles, 80.0 ) ) )
        addChild( failEffect )
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, quarter: Quarter!, receptacle: Receptacle!) -> ObjCBool {
        if gameState.lost { return false }
        quarter.physicsBody.collisionType = "usedQuarter"
        receptacle.receiveItem( quarter )
        //receptacle.doLaundry( quarter.gold )

        return false
    }

    //var originalScoreLabelContentSizeWidth: CGFloat!
    //var originalScoreLabelContentSizeFrac: Float!
    func updateScoreLabel() -> Void {
        if scoreLabel != nil {
            let string = String.localizedStringWithFormat( "%@", NSNumber( longLong: gameState.score ) )
            scoreLabel.setString( string )
//            if scoreLabel.texture != nil && ready {
//            let l = scoreLabel.texture.contentSize().width
//                if  l > ( self.contentSizeInPoints.width / 4 ) {
//                    scoreLabel.scale = Float(( self.contentSizeInPoints.width / 4 ) / scoreLabel.texture.contentSize().width)
//                }
//                let l = scoreLabel.contentSize.width
                let digits = string.characters.count
                if digits > 4 {
                    //scoreLabel.scale = Float(originalScoreLabelContentSizeWidth)/(Float(digits))
                    scoreLabel.scale = 3.0 / Float( digits )
                }
            //}
        }
    }

    func gameOver() {
        gameOver( 0.5 )
    }
    
    func gameOver( delay: CCTime ) -> Void {
        if gameState.lost { return } // YOLO
        inflow.cancel()
        let delay = CCActionDelay.actionWithDuration( delay ) as! CCActionDelay
        let effect = CCActionCallBlock.actionWithBlock { () -> Void in
            self.endGameFalling = true
            for node in self.myPhysicsNode.children as! [CCNode] {
                if let _ = node as? Inflow {
                    // skip the inflow
                } else {
                    if node.physicsBody != nil {
                        node.physicsBody!.type = CCPhysicsBodyType.Dynamic
                        if let s = node as? Shirt {
                            s.fall()
                        }

                    } else {
                        node.physicsBody = CCPhysicsBody( circleOfRadius: 10, andCenter: node.position )
                        node.physicsBody!.affectedByGravity = true
                        node.physicsBody!.sensor = true
                    }
                    node.physicsBody!.applyTorque( CGFloat( CCRANDOM_MINUS1_1() * 900 ) )
                }
            }
            let delay2 = CCActionDelay.actionWithDuration( 1.5 ) as! CCActionDelay
            let finish = CCActionCallBlock.actionWithBlock { () -> Void in
                let adMenu = CCBReader.load( "AfterDeathMenu" ) as! AfterDeathMenu
                self.addChild( adMenu )
                self.schedule( "killSelf", interval: 3.0 )
                } as! CCActionCallBlock
            self.runAction( CCActionSequence.actionWithArray([delay2, finish]) as! CCActionSequence )

            self.handle.cascadeOpacityEnabled = true
            let fadeHandle = CCActionFadeOut.actionWithDuration( 0.5 ) as! CCActionFadeOut
            self.handle.runAction( fadeHandle )

            // launch faces
            var delayTime = 0.025
            let numberOfFaces = arc4random_uniform( 12 ) + 10
            for var i: UInt32 = 0; i < numberOfFaces; ++i, delayTime *= 1.5 {
                let launchFaceDelay = CCActionDelay.actionWithDuration( delayTime ) as! CCActionDelay
                let launchFace = CCActionCallBlock.actionWithBlock({ () -> Void in
                    self.inflow.launchDeathFace()
                }) as! CCActionCallBlock
                self.runAction( CCActionSequence.actionWithArray([launchFaceDelay, launchFace] ) as! CCActionSequence )
            }
        } as! CCActionCallBlock
        self.runAction( CCActionSequence.actionWithArray([delay, effect]) as! CCActionSequence )
    }

    func restartButtonPressed() {
        gameState.restart()
        gameState.playSound( "audioFiles/flush.caf" )
    }

    func dieButtonPressed() {
        gameOver( 0 )
        myPhysicsNode.paused = false
        particleLayer.paused = false
        gameState.endGame()
        gameState.playSound( "audioFiles/explosion.caf" )
    }

    func killSelf() {
        self.stopAllActions()
        for node in self.children as! [CCNode] {
            if let _ = node as? AfterDeathMenu {
            } else {
                if node != overlay {
                    node.removeFromParent()
                }
            }
        }
    }

    var ready = false
    override func update(delta: CCTime) {
        if !ready {
            ready = true
        }
        if endGameFalling && ( myPhysicsNode != nil ) {
            for node in myPhysicsNode.children {
                if node.positionInPoints.y < -node.contentSizeInPoints.height {
                    node.removeFromParent()
                }
            }
        }
    }
}
