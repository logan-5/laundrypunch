import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    private(set) weak var bouncer: Bouncer!
    private(set) weak var inflow: Inflow!
    private(set) weak var physicsNode: CCPhysicsNode!
    private(set) weak var scoreLabel: CCLabelTTF!
    private(set) weak var livesLabel: CCLabelTTF!
    private(set) weak var overlay: CCNodeGradient!
    var hasBeenTouched = false
    
    func didLoadFromCCB() -> Void {
        GameState.sharedState.scene = self
        self.userInteractionEnabled = false
        physicsNode.collisionDelegate = self
        updateScoreLabel(); updateLivesLabel()
        overlay.zOrder = 100
        let fadeOut = CCActionFadeOut.actionWithDuration( 0.3 ) as CCAction
        overlay.runAction( fadeOut )
        
        self.contentSize = CCDirector.sharedDirector().viewSize()
        self.position = CGPointZero
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
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shirt: Shirt!, receptacle: Receptacle!) -> ObjCBool {
        if shirt.shirtColor == receptacle.shirtColor {
            //GameState.sharedState.success()
            receptacle.receiveItem( shirt )
        } else {
            GameState.sharedState.failure()
            shirt.fall()
            receptacle.killShirt()
            runFailParticles( shirt.position )
        }
        
        return false
    }
    
    private func runFailParticles( position: CGPoint ) -> Void {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = position
        self.addChild( failEffectSmell )
        
        let failEffect = CCBReader.load( "Effects/Failure" ) as CCParticleSystem
        failEffect.autoRemoveOnFinish = true
        failEffect.position = position
        let particles = 1.0 / Float( max(GameState.sharedState.lives, 1) ) * 80.0
        failEffect.totalParticles = UInt( 20 + UInt( max( particles, 80.0 ) ) )
        self.addChild( failEffect )
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, quarter: Quarter!, receptacle: Receptacle!) -> ObjCBool {
        if receptacle.shirts.count > 0 {
            receptacle.receiveItem( quarter )
            receptacle.doLaundry()
        } else {
            quarter.fall()
        }
        return false
    }
    
    func updateScoreLabel() -> Void {
        scoreLabel.string = String( GameState.sharedState.score )
    }
    
    func updateLivesLabel() -> Void {
        livesLabel.string = "Lives: " + String( GameState.sharedState.lives )
    }
    
    func gameOver() -> Void {
        var adMenu = CCBReader.load( "AfterDeathMenu" ) as AfterDeathMenu
        self.addChild( adMenu )
        inflow.cancel()
    }
}
