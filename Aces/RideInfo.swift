//
//  RideInfo.swift
//  Aces
//
//  Created by checkout-7 on 6/14/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Foundation

class RideInfo {
    private var email: String
    private var end: String
    private var endTime: String
    private var eta: String
    private var numRiders: String
    private var start: String
    private var time: String
    private var waitTime: String
    private var ts: String
    
    init(email: String, end: String, endTime: String, eta: String, numRiders: String, start: String, time: String, waitTime: String, ts: String) {
        self.email = email
        self.end = end
        self.endTime = endTime
        self.eta = eta
        self.numRiders = numRiders
        self.start = start
        self.time = time
        self.waitTime = waitTime
        self.ts = ts
    }
    
    func getEmail() -> String {
        return email
    }
    
    func setEmail(email: String) {
        self.email = email
    }
    
    func getEnd() -> String {
        return end
    }
    
    func setEnd(end: String) {
        self.end = end
    }
    
    func getEndTime() -> String {
        return endTime
    }
    
    func setEndTime(endTime: String) {
        self.endTime = endTime
    }
    
    func getETA() -> String {
        return eta
    }
    
    func setETA(eta: String) {
        self.eta = eta
    }

    func getNumRiders() -> String {
        return numRiders
    }
    
    func setNumRiders(numRiders: String) {
        self.numRiders = numRiders
    }
    
    func getStart() -> String {
        return start
    }
    
    func setStart(start: String) {
        self.start = start
    }
    
    func getTime() -> String {
        return time
    }
    
    func setTime(time: String) {
        self.time = time
    }
    
    func getWaitTime() -> String {
        return waitTime
    }
    
    func setWaitTime(waitTime: String) {
        self.waitTime = waitTime
    }
    
    func getTimestamp() -> String {
        return ts
    }
    
    func setTimestamp(ts: String) {
        self.ts = ts
    }
}
