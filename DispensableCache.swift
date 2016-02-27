//
//  DispensableCache.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/17/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class DispensableCache: NSObject {

    class var sharedCache: DispensableCache {
        get { return sharedInstance.sharedCache }
    }
    private struct sharedInstance { static let sharedCache = DispensableCache() }

    var shirtCache: [Shirt] = Array()
    var quarterCache: [Quarter] = Array()
    var zOrder = 0

    func killObject( object: Dispensable ) {
        object.visible = false
        object.physicsBody.sensor = true
        //object.physicsBody.affectedByGravity = false
        object.ready = false
        object.stopAllActions()
        if !object.decremented {
            --GameState.sharedState.liveObjects
        }
        switch object {
        case is Quarter:
            quarterCache.append( object as! Quarter )
        case is Shirt:
            shirtCache.append( object as! Shirt )
        default:
            // print( "non-quarter, non-shirt Dispensable object died. removing" )
            object.removeFromParent()
        }

        //print( "killed " + String(object) )
    }

    func nextQuarter() -> Quarter {
        var quarter: Quarter
        if quarterCache.count > 0 {
            quarter = quarterCache.removeLast()
            quarter.initialize()
            //print( "quarter reused!" )
        } else {
            quarter = CCBReader.load( "Quarter" ) as! Quarter
            GameState.sharedState.scene!.myPhysicsNode.addChild( quarter )
            //print( "quarter created" )
        }
        quarter.visible = true
        quarter.physicsBody.sensor = false
        quarter.physicsBody.affectedByGravity = true
        quarter.zOrder = ++zOrder
        return quarter
    }

    func nextShirt() -> Shirt {
        var shirt: Shirt
        if shirtCache.count > 0 {
            shirt = shirtCache.removeLast()
            shirt.initialize()
            // print( "SHIRT REUSED" )
        } else {
            shirt = CCBReader.load( "Shirt" ) as! Shirt
            GameState.sharedState.scene!.myPhysicsNode.addChild( shirt )
            //print( "shirt created" )
        }
        shirt.visible = true
        shirt.physicsBody.sensor = false
        shirt.physicsBody.affectedByGravity = true
        shirt.zOrder = ++zOrder
        return shirt
    }

    func emptyCache() {
        shirtCache.removeAll()
        quarterCache.removeAll()
        zOrder = 0
    }
}
