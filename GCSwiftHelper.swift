//
//  GCSwiftHelper.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/22/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class GCSwiftHelper: NSObject {

    let helper: GCHelper

    init( WithHelper gchelper: GCHelper ) {
        helper = gchelper
        super.init()
    }

    func authenticateLocalUserOnViewController( viewController: UIViewController, setCallbackObject obj: AnyObject?, withPauseSelector selector: Selector ) -> Void {
        if !helper.gameCenterAvailable { return }
        let localPlayer = GKLocalPlayer.localPlayer()

        // print("Authenticating local user...")
        if !localPlayer.authenticated {
            localPlayer.authenticateHandler = { ( authViewController: UIViewController?, error: NSError? ) -> Void in
                guard authViewController != nil else { return }
                guard error == nil else {
                    // process error
                    return
                }
                obj?.performSelector( selector, withObject: nil, afterDelay: 0 )

                viewController.presentViewController( authViewController!, animated: true, completion: { () -> Void in
                    // print( "view controller finished" )
                    CCDirector.sharedDirector().startAnimation()
                    GameState.sharedState.scene!.pause()
                })
            }
        } else {
            // print( "Already authenticated!" )
        }
    }
}
