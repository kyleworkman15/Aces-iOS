//
//  RCValues.swift
//  Aces
//
//  Created by Kyle Workman on 9/25/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Firebase
import FirebaseRemoteConfig

class RCValues {
    
    static let sharedInstance = RCValues()
    
    private init() {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            "force_update_required" : false,
            "force_update_version_ios" : "1.0.0"
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func fetchCloudValues() {
        let fetchDuration: TimeInterval = 3600
        RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in
            
            if let error = error {
                print("Error fetching remote config: \(error)")
                return
            }
            
            RemoteConfig.remoteConfig().activateFetched()
            print("Fetched remote config.")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.triggerFetched()
        }
    }
}
