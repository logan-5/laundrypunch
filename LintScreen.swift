//
//  LintScreen.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/24/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

extension CCClippingNode {
    public override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        super.touchBegan( touch, withEvent: event )
    }
}

class LintScreen: CCNode {

    var stencilNode: CCRenderTexture!
    var lintContainer: CCClippingNode!
    var drawingFinger: CCSprite?
    var nextButton: CCButton!
    var frame: CCSprite9Slice!

    var halfScreenSize: CGPoint!
    let frameZ = 5
    let lintZ = 4
    let itemLayerZ = 2
    let meshZ = -3

    override func onEnter() {
        self.userInteractionEnabled = false
        frame.zOrder = frameZ

        let size = self.contentSizeInPoints
        halfScreenSize = ccpMult( ccp(size.width, size.height), 0.5 )
        stencilNode = CCRenderTexture( width: Int32(size.width), height: Int32(size.height) )
        stencilNode.position = halfScreenSize
        stencilNode.anchorPoint = CGPointZero
        stencilNode.sprite.anchorPoint = CGPointZero
        //self.addChild( stencilNode )
        //stencilNode.visible = false
        //stencilNode.zOrder = -10//-100
        //stencilNode.begin(); stencilNode.end()

        lintContainer = CCClippingNode( stencil: stencilNode.sprite )
        lintContainer.contentSize = size
        lintContainer.position = CGPointZero
        lintContainer.anchorPoint = CGPointZero
        lintContainer.alphaThreshold = 0.01
        lintContainer.inverted = true
        lintContainer.zOrder = lintZ
        lintContainer.userInteractionEnabled = false
        self.addChild( lintContainer )

        nextButton.zOrder = itemLayerZ
        let halfNextButtonWidth = UInt32(nextButton.contentSizeInPoints.width / 2)
        let intWidth = UInt32(self.contentSizeInPoints.width)
        let halfNextButtonHeight = UInt32(nextButton.contentSizeInPoints.height / 2)
        let intHeight = UInt32(self.contentSizeInPoints.height)
        let nextButtonX = CGFloat(arc4random_uniform( intWidth - 2 * halfNextButtonWidth ) + halfNextButtonWidth)
        let nextButtonY = CGFloat(arc4random_uniform( intHeight - 2 * halfNextButtonHeight ) + halfNextButtonHeight)
        nextButton.position = ccp( nextButtonX, nextButtonY )

        self.userInteractionEnabled = true

        addCoins()
        addGrid()
        addLint()

        super.onEnter()
    }

    func addCoins() {
        let numberOfCoins = arc4random_uniform( 4 ) // between 0 and 3 coins
        for _ in 0...numberOfCoins {
            let coin: LintScreenQuarter = probabilityOf( 0.25 ) ? LintScreenGoldQuarter.init(lintScreen: self) : LintScreenQuarter.init(lintScreen: self )
            coin.zOrder = itemLayerZ
            let halfCoinWidth = UInt32(coin.contentSizeInPoints.width / 2)
            let intWidth = UInt32(self.contentSizeInPoints.width)
            let halfCoinHeight = UInt32(coin.contentSizeInPoints.height / 2)
            let intHeight = UInt32(self.contentSizeInPoints.height)
            let coinX = CGFloat(arc4random_uniform( intWidth - 2 * halfCoinWidth ) + halfCoinWidth )
            let coinY = CGFloat(arc4random_uniform( intHeight - 2 * halfCoinHeight ) + halfCoinHeight )
            coin.position = ccp( coinX, coinY )
            self.addChild( coin )
        }
    }

    func addGrid() {
        let size = 32
        let xN = Int( self.contentSizeInPoints.width ) / size
        let yN = Int( self.contentSizeInPoints.height) / size

        for i in 0...xN {
            for j in 0...yN {
                let g = CCSprite(imageNamed: "DryerMode/assets/mesh.png")
                g.position = ccp( CGFloat(i * size), CGFloat(j * size) )
                g.zOrder = meshZ
                self.addChild( g )
            }
        }
    }

    func addLint() {
        let size = 32
        let xN = Int( self.contentSizeInPoints.width ) / size + 1
        let yN = Int( self.contentSizeInPoints.height) / size + 1

        for i in 0...xN {
            for j in 0...yN {
                let g = CCSprite(imageNamed: "DryerMode/assets/lint.png")
                g.position = ccp( CGFloat(i * size), CGFloat(j * size) )
                lintContainer.addChild( g )
            }
        }
    }

    override func touchBegan(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        if drawingFinger == nil {
            drawingFinger = CCSprite(imageNamed: "ccbResources/ccbParticleFire.png")
            drawingFinger!.scale = 2
            stencilNode.addChild( drawingFinger )
        }

        drawingFinger!.position = touch.locationInNode(self)

        stencilNode.begin()
        drawingFinger!.visit()
        stencilNode.end()

        //super.touchBegan( touch, withEvent: event )
    }

    override func touchMoved(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchBegan(touch, withEvent: event)
    }

    override func touchCancelled(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        drawingFinger?.removeFromParent()
        drawingFinger = nil
    }

    override func touchEnded(touch: CCTouch!, withEvent event: CCTouchEvent!) {
        touchCancelled(touch, withEvent: event)
    }

    func nextButtonPressed() {
        let scene = self.parent! as! DryerScene
        scene.nextLintScreen()
    }

    func pickUpQuarter( quarter: LintScreenQuarter ) {
        let scene = self.parent! as! DryerScene
        scene.pickUpQuarter( quarter )
    }
}
