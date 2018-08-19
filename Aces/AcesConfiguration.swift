//
//  AcesConfiguration.swift
//  Aces
//
//  Description: Class for handeling the boundaries of Aces.
//
//  Created by Kyle Workman on 6/15/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import Foundation

class AcesConfiguration {
    
    var LAT1: Double = 41.497281
    var LAT2: Double = 41.507930
    var LONG1: Double = -90.565683
    var LONG2: Double = -90.539093
    
    private var ALDILAT: Double = 41.491939699999996
    private var ALDILONG: Double = -90.5482703
    
    // Returns true if the given latitude and longitude reside in the Aces boundary
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
