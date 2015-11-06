//
//  DryerScene.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/24/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class DryerScene: CCScene {

    var currentLintScreen: LintScreen?
    var background: CCSprite!
    var backButton: CCButton!

    var lintScreensLabel: CCLabelTTF!
    var spoilsLabel: CCLabelTTF!
    var lintScreenScore: Int64 = 0
    var spoilsInCents: Int64 = 0
    let formatter = NSNumberFormatter()

    func didLoadFromCCB() {
        background.scale = Float(CCDirector.sharedDirector().viewSizeInPixels().width / background.contentSizeInPoints.width)
        backButton.zOrder = 10

        formatter.numberStyle = NSNumberFormatterStyle.CurrencyStyle
        lintScreensLabel.runAction( CCActionAnimateRainbow.instantiate( 1 ) )
        spoilsLabel.runAction( CCActionAnimateRainbow.instantiate( 1 ) )
        updateLabels()
    }

    func updateLabels() {
        let lintScreenString = "lint screens: " + String( lintScreenScore )
        lintScreensLabel.string = lintScreenString

        let spoilsInDollars = NSDecimalNumber( longLong: spoilsInCents ).decimalNumberByDividingBy( 100 )
        let spoilsString = formatter.stringFromNumber( spoilsInDollars )!
        spoilsLabel.string = "spoils: " + spoilsString
    }

    func backButtonPressed() {
        GameState.sharedState.refresh()
        let mainScene = CCBReader.loadAsScene( "MainScene" )
        let transition: CCTransition = CCTransition.init(fadeWithColor: CCColor.whiteColor(), duration: 0.5 )
        CCDirector.sharedDirector().replaceScene( mainScene, withTransition: transition )
    }

    func nextLintScreen() {
        ++lintScreenScore
        updateLabels()
        moveCurrentOffscreenAndLoadNext()
    }

    func moveCurrentOffscreenAndLoadNext() {
        guard currentLintScreen != nil else { return }
        let moveOffScreen = CCActionMoveBy.actionWithDuration( 0.4, position: ccp( currentLintScreen!.contentSizeInPoints.width * 2, 0 ) ) as! CCAction
        let loadNext = CCActionCallFunc.actionWithTarget( self, selector: "loadNextLintScreen" ) as! CCAction
        let sequence = CCActionSequence.actionWithArray([moveOffScreen, loadNext] ) as! CCAction
        currentLintScreen!.runAction( sequence )
    }

    func loadNextLintScreen() {
        currentLintScreen!.removeFromParent()
        currentLintScreen = CCBReader.load( "DryerMode/lintScreen" ) as? LintScreen
        currentLintScreen!.position = ccp( -currentLintScreen!.contentSizeInPoints.width * 2, 0 )
        self.addChild( currentLintScreen! )

        let moveOnScreen = CCActionMoveTo.actionWithDuration( 0.4, position: CGPointZero ) as! CCAction
        currentLintScreen!.runAction( moveOnScreen )
    }

    func pickUpQuarter( quarter: LintScreenQuarter ) {
        spoilsInCents += quarter.centValue
        updateLabels()
        let fireworks = CCBReader.load( "Effects/GoldExplosion" ) as! CCParticleSystem
        fireworks.position = quarter.positionInPoints
        fireworks.autoRemoveOnFinish = true
        self.addChild( fireworks )
    }
}
