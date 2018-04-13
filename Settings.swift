//
//  Settings.swift
//  Play That Note
//
//  Created by Paul Crompton on 7/12/17.
//  Copyright © 2017 Paul Crompton. All rights reserved.
//

import Foundation

enum Settings: Int {
    case music
    case pitchDetection
    case license
    case restorePurchases
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Settings(rawValue: max) { max += 1 }
        return max
    }()
}
