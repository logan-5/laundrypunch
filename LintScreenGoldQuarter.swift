//
//  LintScreenGoldQuarter.swift
//  LaundryLaunchRE2
//
//  Created by Logan Smith on 9/25/15.
//  Copyright © 2015 Apportable. All rights reserved.
//

import UIKit

class LintScreenGoldQuarter: LintScreenQuarter {

    init(lintScreen: LintScreen) {
        super.init( lintScreen: lintScreen, centValue: 50 )
        self.sprite.color = CCColor.yellowColor()
    }
}
