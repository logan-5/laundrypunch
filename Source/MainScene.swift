import Foundation

class MainScene: CCNode, CCPhysicsCollisionDelegate {
    private(set) weak var bouncer: Bouncer!
    private(set) weak var inflow: Inflow!
    private(set) weak var physicsNode: CCPhysicsNode!
    private(set) weak var scoreLabel: CCLabelTTF!
    private(set) var hasBeenTouched = false
    
    func didLoadFromCCB() -> Void {
        GameState.sharedState.scene = self
        self.userInteractionEnabled = true
        physicsNode.collisionDelegate = self
    }
    
    override func touchBegan( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        hasBeenTouched = true
        
        if GameState.sharedState.currentShirt == nil {
            inflow.launch()
        } else {
            var touchPos = touch.locationInNode( self.parent )
            touchPos = ccp( touchPos.x, touchPos.y )
            var direction = ccpSub( touchPos, bouncer.positionInPoints )
            var angle = Float( ccpToAngle( direction ) )
            angle = 360 - CC_RADIANS_TO_DEGREES( angle )
            bouncer.rotation = angle
        }
    }
    
    override func touchMoved( touch: CCTouch!, withEvent event: CCTouchEvent! ) -> Void {
        self.touchBegan( touch, withEvent: event )
    }
    
    func ccPhysicsCollisionPostSolve( pair:CCPhysicsCollisionPair!, shirt:Shirt!, bouncer:Bouncer! ) -> ObjCBool {
        var shirtSpeed = shirt.bounceSpeed //ccpLength( shirt.physicsBody.velocity )
        var shirtNewVelocity = ccp( shirtSpeed, 0 )
        shirtNewVelocity = ccpRotateByAngle( shirtNewVelocity, CGPointZero, CC_DEGREES_TO_RADIANS( bouncer.rotation - 180 ) )
        shirt.physicsBody.velocity = ccp( -shirtNewVelocity.x, shirtNewVelocity.y )
        
        return true
    }
    
    func ccPhysicsCollisionBegin(pair: CCPhysicsCollisionPair!, shirt: Shirt!, receptacle: Receptacle!) -> ObjCBool {
        if shirt.shirtColor == receptacle.shirtColor {
            GameState.sharedState.success()
            receptacle.receiveShirt( shirt )
        } else {
            GameState.sharedState.failure()
            shirt.physicsBody.sensor = true
            shirt.physicsBody.velocity = CGPointZero
            shirt.physicsBody.collisionType = "failedShirt"
        }
        
        return false
    }
    
    func updateScoreLabel() -> Void {
        scoreLabel.string = String( GameState.sharedState.score )
    }
}
