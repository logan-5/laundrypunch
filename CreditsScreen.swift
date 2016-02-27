//
//  CreditsScreen.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 2/13/16.
//  Copyright © 2016 Apportable. All rights reserved.
//

let githubLink: NSString = "as yet unknown URL"

class CreditsScreen: CCNode {

    weak var titleLabel: CCLabelTTF!
    weak var doneButton: CCButton!
    weak var creditsLabel: CCLabelTTF!
    var creditsDisplay:CCLabelTTF!

    let creditsString: [String] =
        ["all design/programming/artwork by logan\u{00A0}r\u{00A0}smith",
         "noisecode.net",
         "",
         "developed with cocos2D/SpriteBuilder",
         "cocos2d.spritebuilder.com",
         "",
         "immeasureable thanks to my friends/beta-testers/idea-factories:",
         "matthew fisher",
         "julia fisher",
         "andy leong",
         "emily leong",
         "christian koons",
         "jordan nakamura",
         "darryl scroggins",
         "joel hasemeyer",
         "alison urbank",
         "robert smith",
         "marin smith",
         "paul hinschberger",
         "melissa brooks",
         "",
         "and special thanks to @mugunthkumar for his iCloud wizardry",
         "",]
         //String(  NSString( format: "the source code for this game is available at %@", githubLink ) ) ]

    var labelContainer: CCNode!

    func didLoadFromCCB() {
        self.cascadeOpacityEnabled = true
        let fadeIn = CCActionFadeIn.actionWithDuration( menuFadeSpeed ) as! CCActionFadeIn
        self.runAction( fadeIn )
        self.userInteractionEnabled = true
    }

    override func onEnter() {
        self.setUpDisplayLabel()
        super.onEnter()
    }

    func setUpDisplayLabel() {
        var string: String = ""
        for str in creditsString {
            string += str + "\n"
        }
        let label: CCLabelTTF = CCLabelTTF( string: string, fontName: "Courier", fontSize: 12.0 )

        let scrollView = CCNode()
        scrollView.positionType = CCPositionTypeNormalized
        scrollView.position = CGPointMake( 0, 0.1 )
        scrollView.contentSizeType = CCSizeTypeNormalized
        scrollView.contentSize = CGSizeMake( 0, 0.8 )
        scrollView.userInteractionEnabled = false
        scrollView.addChild( label )

        self.addChild( scrollView )

        label.positionType = CCPositionTypeNormalized
        label.position = CGPointMake( 0, 1 )
        label.anchorPoint = CGPointMake( 0, 1 )
        label.dimensions = CGSizeMake(self.contentSizeInPoints.width, scrollView.contentSizeInPoints.width)
        print( label.dimensions )

    }

    func doneButtonPressed() {
        let fadeOut = CCActionFadeOut.actionWithDuration( menuFadeSpeed ) as! CCActionFadeOut
        let killMyself = CCActionCallBlock.actionWithBlock { () -> Void in
            self.removeFromParent()
        } as! CCActionCallBlock
        let sequence = CCActionSequence.actionWithArray( [fadeOut, killMyself] ) as! CCActionSequence

        self.runAction( sequence )
    }

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        let failEffectSmell = CCBReader.load( "Effects/FailureSmell" ) as! CCParticleSystem
        failEffectSmell.autoRemoveOnFinish = true
        failEffectSmell.position = touch.locationInNode( self )
        self.addChild( failEffectSmell )
    }
}
