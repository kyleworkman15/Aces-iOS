//
//  AcesConfiguration.swift
//  Aces
//
//  Created by checkout-7 on 6/15/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Foundation

class AcesConfiguration {
    
    private var LAT1: Double = 41.497281
    private var LAT2: Double = 41.507930
    private var LONG1: Double = -90.565683
    private var LONG2: Double = -90.539093
    
    private var ALDILAT: Double = 41.491939699999996
    private var ALDILONG: Double = -90.5482703
    
    func isInACESBoundary(lat: Double, long: Double) -> Bool {
        let bool1: Bool = lat > LAT1 && long > LONG1
        let bool2: Bool = lat < LAT2 && long < LONG2
        let insideBounds: Bool = bool1 && bool2
        let aldiCheck: Bool = lat == ALDILAT && long == ALDILONG
        if (insideBounds || aldiCheck) {
            return true
        } else {
            return false
        }
    }
    
}
