import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    private(set) weak var bouncer: Bouncer!
    private(set) weak var inflow: Inflow!
    private(set) weak var handle: BouncerHandle!
    private(set) weak var myPhysicsNode: CCPhysicsNode!
    private(set) weak var scoreLabel: CCLabelTTF!
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
    
    func didLoadFromCCB() -> Void {
        GCHelper.defaultHelper().authenticateLocalUserOnViewController( CCDirector.sharedDirector(), setCallbackObject: self, withPauseSelector: nil )
        GCHelper.defaultHelper().registerListener( CCDirector.sharedDirector() )
        GameState.sharedState.scene = self
        println( "loaded main scene" )
        self.userInteractionEnabled = false
        myPhysicsNode.collisionDelegate = self
        updateScoreLabel()
        scoreLabel.zOrder = 2
        restartButton.background.margin = 0
        dieButton.background.margin = 0
        modeLabel.string = Data.sharedData.modeName + " mode"
        modeLabel.runAction( CCActionAnimateRainbow.instantiate( 1.5 ) )

        background.scale = Float(CCDirector.sharedDirector().viewSizeInPixels().width / background.contentSizeInPoints.width)
        overlay.scale = Float(CCDirector.sharedDirector().viewSizeInPixels().width / overlay.contentSizeInPoints.width)
        overlay.zOrder = 100
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as! CCAction
        overlay.runAction( fadeOut )

        myPhysicsNode.gravity = GameState.sharedState.modeInfo.worldGravity
        //let oldContentSize = self.contentSizeInPoints
        //self.contentSize = CCDirector.sharedDirector().viewSize()
        //self.position = CGPointZero
        //myPhysicsNode.contentSize = self.contentSize

//        for node in self.children {
//            let n = node as! CCNode
//            let yPercent = n.position.y / oldContentSize.height
//            n.position = ccp( n.position.x, yPercent * self.contentSize.height )
//        } // dumb. makes the %'s in sb
//        for node in myPhysicsNode.children {
//            let n = node as! CCNode
//            let yPercent = n.position.y / oldContentSize.height
//            n.position = ccp( n.position.x, yPercent * self.contentSize.height )
//        } // dumb. makes the %'s in sb
    }

    override func addChild(node: CCNode!) {
        if let p = node as? CCParticleSystem {
            if particleLayer != nil {
                particleLayer.addChild( node )
                return
            }
        }
        super.addChild( node )
    }

    func pause() {
        if GameState.sharedState.lost { return }
        myPhysicsNode.paused = !myPhysicsNode.paused
        particleLayer.paused = myPhysicsNode.paused
        
        if !myPhysicsNode.paused {
            pauseButton.cascadeOpacityEnabled = true
            pauseButton.enabled = false
            var fadeIn = CCActionFadeIn.actionWithDuration( 2 ) as! CCActionFadeIn
            var enable = CCActionCallBlock.actionWithBlock({ () -> Void in
                self.pauseButton.enabled = true
            }) as! CCActionCallBlock
            pauseButton.runAction( CCActionSequence.actionWithArray([fadeIn, enable]) as! CCActionSequence )
        }
    }
    
//    override func touchBegan( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
//        hasBeenTouched = true
//        
//        if GameState.sharedState.lastLaunchedObject == nil {
//            inflow.launch()
//        }
//    }
//    
//    override func touchMoved( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
//        self.touchBegan( touch, withEvent: event )
//    }

    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, animateSensor: CCNode!, wildcard: CCNode!) -> ObjCBool {
//        println( wildcard.physicsBody.collisionType )
//        if wildcard.physicsBody.collisionType == "storedShirt"{
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//            println( "test" )
//
//        }
        if !GameState.sharedState.lost && ( wildcard.physicsBody.collisionType == "shirt" || wildcard.physicsBody.collisionType == "quarter" || wildcard.physicsBody.collisionType == "restoredQuarter" ) {
            bouncer.animateGlove()
        }
        return false
    }
    
    func ccPhysicsCollisionPostSolve( pair:CCPhysicsCollisionPair!, shirt:Shirt!, bouncer:Bouncer! ) -> ObjCBool {
        var shirtSpeed = shirt.bounceSpeed //ccpLength( shirt.physicsBody.velocity )
        var shirtNewVelocity = ccp( shirtSpeed, 0 )
        shirtNewVelocity = ccpRotateByAngle( shirtNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        shirt.physicsBody.velocity = ccp( -shirtNewVelocity.x, shirtNewVelocity.y )
        
        return true
    }
    
    func ccPhysicsCollisionPostSolve( pair:CCPhysicsCollisionPair!, quarter:Quarter!, bouncer:Bouncer! ) -> ObjCBool {
        var quarterSpeed = quarter.bounceSpeed
        var quarterNewVelocity = ccp( quarterSpeed, 0 )
        quarterNewVelocity = ccpRotateByAngle( quarterNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        quarter.physicsBody.velocity = ccp( -quarterNewVelocity.x, quarterNewVelocity.y )
        return true
    }

    func ccPhysicsCollisionPostSolve(pair: CCPhysicsCollisionPair!, restoredQuarter: Quarter!, bouncer: Bouncer!) -> ObjCBool {
        restoredQuarter.physicsBody.collisionType = "quarter"
        var quarterSpeed = restoredQuarter.bounceSpeed
        var quarterNewVelocity = ccp( quarterSpeed, 0 )
        quarterNewVelocity = ccpRotateByAngle( quarterNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        restoredQuarter.physicsBody.velocity = ccp( -quarterNewVelocity.x, quarterNewVelocity.y )
        return true
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
        if GameState.sharedState.lost { return false }
        if shirt.isRainbow || shirt.isGold || shirt.shirtColor == receptacle.shirtColor {
            receptacle.receiveItem( shirt )
        } else {
            GameState.sharedState.failure()
            shirt.fall()
            if GameState.sharedState.mode != GameState.Mode.Efficiency { // efficiency mode is too hard if it kills previously stacked shirts
                receptacle.killShirt()
            }
            runFailParticles( shirt.position )
            GameState.sharedState.playSound( "audioFiles/explosion.caf" )
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
        let particles = 1.0 / Float( max(GameState.sharedState.lives, 1) ) * 80.0
        failEffect.totalParticles = UInt( 20 + UInt( max( particles, 80.0 ) ) )
        addChild( failEffect )
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, quarter: Quarter!, receptacle: Receptacle!) -> ObjCBool {
        if GameState.sharedState.lost { return false }
        quarter.physicsBody.collisionType = "usedQuarter"
        receptacle.receiveItem( quarter )
        receptacle.doLaundry( quarter.gold )

        return false
    }
    
    func updateScoreLabel() -> Void {
        if scoreLabel != nil {
            scoreLabel.string = String( GameState.sharedState.score )
        }
    }

    func gameOver() {
        gameOver( 0.5 )
    }
    
    func gameOver( delay: CCTime ) -> Void {
        if GameState.sharedState.lost { return } // YOLO
        inflow.cancel()
        let delay = CCActionDelay.actionWithDuration( delay ) as! CCActionDelay
        let effect = CCActionCallBlock.actionWithBlock { () -> Void in
            self.endGameFalling = true
            for node in self.myPhysicsNode.children as! [CCNode] {
                if let i = node as? Inflow {
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
                var adMenu = CCBReader.load( "AfterDeathMenu" ) as! AfterDeathMenu
                self.addChild( adMenu )
                self.schedule( "killSelf", interval: 3.0 )
                } as! CCActionCallBlock
            self.runAction( CCActionSequence.actionWithArray([delay2, finish]) as! CCActionSequence )

            self.handle.cascadeOpacityEnabled = true
            let fadeHandle = CCActionFadeOut.actionWithDuration( 0.5 ) as! CCActionFadeOut
            self.handle.runAction( fadeHandle )

            // launch faces
            var delayTime = 0.025
            var numberOfFaces = arc4random_uniform( 12 ) + 10
            for var i: UInt32 = 0; i < numberOfFaces; ++i, delayTime *= 1.5 {
                var launchFaceDelay = CCActionDelay.actionWithDuration( delayTime ) as! CCActionDelay
                var launchFace = CCActionCallBlock.actionWithBlock({ () -> Void in
                    self.inflow.launchDeathFace()
                }) as! CCActionCallBlock
                self.runAction( CCActionSequence.actionWithArray([launchFaceDelay, launchFace] ) as! CCActionSequence )
            }
        } as! CCActionCallBlock
        self.runAction( CCActionSequence.actionWithArray([delay, effect]) as! CCActionSequence )
    }

    func restartButtonPressed() {
        GameState.sharedState.restart()
        GameState.sharedState.playSound( "audioFiles/flush.caf" )
    }

    func dieButtonPressed() {
        gameOver( 0 )
        GameState.sharedState.endGame()
        GameState.sharedState.playSound( "audioFiles/explosion.caf" )
    }

    func killSelf() {
        self.stopAllActions()
        for node in self.children as! [CCNode] {
            if let n = node as? AfterDeathMenu {
            } else {
                if node != overlay {
                    node.removeFromParent()
                }
            }
        }
    }

    override func update(delta: CCTime) {
        if endGameFalling && ( myPhysicsNode != nil ) {
            for node in myPhysicsNode.children {
                if node.positionInPoints.y < -node.contentSizeInPoints.height {
                    node.removeFromParent()
                }
            }
        }
    }
}
