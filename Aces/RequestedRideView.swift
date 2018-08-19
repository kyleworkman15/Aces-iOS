//
//  RequestedRideView.swift
//  Aces
//
//  Description: View/View Controller for handeling the Requested Ride Page.
//
//  Created by Kyle Workman on 6/15/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

// For returning ride data to the Maps View
protocol MyProtocol {
    func setRide(ride: RideInfo)
}

class RequestedRideView: UIViewController {
    
    var ref: DatabaseReference!
    var ride: RideInfo!
    var delegate: MyProtocol?
    
    // Button for canceling the current ride
    var cancelBtn: UIButton = constructBtn(text: "CANCEL RIDE", color: .red)
    
    // Label for displaying the title
    let titleLbl: UILabel = constructTitleLbl(text: "Your ride has\nbeen requested!", txtColor: UIColor.init(red: 0/255, green: 90/255, blue: 210/255, alpha: 1), bkdColor: UIColor.init(red: 255/255, green: 215/255, blue: 0/255, alpha: 1))
    
    // Label for displaying the starting location, ending location, wait time, ETA
    let dataLbl: UILabel = constructLbl(text: "Start:\nEnd:\nETA: PENDING")
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 0/255, green: 90/255, blue: 210/255, alpha: 1)
        self.ref = Database.database().reference()
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        let screenSize = UIScreen.main.bounds
        
        addSubviewAnchorTLRH(subView: titleLbl, top: screenSize.height/15, left: 0, right: 0, height: 90)
        addSubviewAnchorTLRH(subView: dataLbl, top: 4*screenSize.height/15, left: 0, right: 0, height: 120)
        addSubviewAnchorBLRH(subView: cancelBtn, btm: -10, left: 10, right: -10, height: 35)
        let width = screenSize.width
        let height = screenSize.height
        view.addSubview(constructLogo(x: (width/2)-(width/2/2), y: (17*height/24)-(width/2/2), width: width/2, height: width/2))
        
        setupListeners()
        outputTS()
    }
    
    // Add and anchor (to the top, left, right, height) a subview with the given constraints to the view
    func addSubviewAnchorTLRH(subView: UIView, top: CGFloat, left: CGFloat, right: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }

    // Add and anchor (to the bottom, left, right, height) a subview with the given constraints to the view
    func addSubviewAnchorBLRH(subView: UIView, btm: CGFloat, left: CGFloat, right: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }
    
    // Handles the action for the cancelBtn, return to Maps View
    @objc func cancelAction() {
        let alert = UIAlertController(title: "Cancel Ride", message: "Are you sure you want to cancel your ride?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: { action in
            if (self.dataLbl.text?.contains("PENDING"))! {
                self.deleteRide(type: "PENDING RIDES")
            } else {
                self.deleteRide(type: "ACTIVE RIDES")
            }
            self.deleteTS()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Deletes the current ride from the ACTIVE or PENDING tree from the Firebase database,
    // adds the ride to the CANCELLED tree, and returns to the Maps View
    func deleteRide(type: String) {
        let email = ride.getEmail()
        let emailTS = "\(ride.getEmail())_\(ride.getTimestamp())"
        let cancelled = ref.child("CANCELLED RIDES").child(emailTS)
        let typeRef = ref.child(type).child(email)
        typeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.ride.setEndTime(endTime: "Cancelled by User")
            let postDict = snapshot.value as? NSDictionary
            let end = postDict?["end"] as? String ?? ""
            let eta = postDict?["endTime"] as? String ?? ""
            let numRiders = postDict?["numRiders"] as? String ?? ""
            let start = postDict?["start"] as? String ?? ""
            let time = postDict?["time"] as? String ?? ""
            let timestamp = postDict?["timestamp"] as? CLong ?? 0
            let waitTime = postDict?["waitTime"] as? String ?? ""
            cancelled.setValue(["email": email, "end": end, "endTime": "Cancelled by User", "eta": eta, "numRiders": numRiders, "start": start, "time": time, "timestamp": timestamp, "waitTime": waitTime])
            typeRef.setValue(["email": email, "endTime": "Cancelled by User"])
            typeRef.removeValue()
            self.delegate?.setRide(ride: self.ride)
            self.dismiss(animated: true, completion: nil)
        })
    }
    
    // Set up the Firebase listeners for if a ride is completed, cancelled, or updated by the dipatcher
    func setupListeners() {
        let email = ride.getEmail()
        let emailTS = "\(ride.getEmail())_\(ride.getTimestamp())" // email with timestamp
        let active = ref.child("ACTIVE RIDES").child(email)
        let pending = ref.child("PENDING RIDES").child(email)
        setupPendingOrActive(email: email, ref: pending)
        setupPendingOrActive(email: email, ref: active)
        setupCancelled(email: emailTS)
        setupCompleted(email: emailTS)
    }
    
    // Set up the Firebase listeners for pending or active rides
    func setupPendingOrActive(email: String, ref: DatabaseReference) {
        ref.observe(.value, with: { (snapshot) in
            if (snapshot.hasChildren()) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                if (endTime == " ") {
                    let start = postDict?["start"] as? String ?? ""
                    let end = postDict?["end"] as? String ?? ""
                    let waitTime = postDict?["waitTime"] as? String ?? ""
                    let eta = postDict?["eta"] as? String ?? ""
                    self.dataLbl.text = "Start: \(start)\nEnd: \(end)\nETA: PENDING"
                    if (waitTime != "1000" && eta != " ") {
                        self.dataLbl.text = "Start: \(start)\nEnd: \(end)\nETA: \(eta)"
                        self.ride.setWaitTime(waitTime: waitTime)
                        self.ride.setETA(eta: eta)
                    }
                }
            }
        })
    }
    
    // Set up the Firebase listener for canceled ride
    func setupCancelled(email: String) {
        let cancelled = ref.child("CANCELLED RIDES").child(email)
        cancelled.observe(.value, with: {(snapshot) in
            if (snapshot.hasChildren()) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                if (endTime == "Cancelled by Dispatcher") {
                    self.deleteTS()
                    self.ride.setEndTime(endTime: endTime)
                    self.delegate?.setRide(ride: self.ride)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        })
    }
    
    // Set up the Firebase listener for completed ride
    func setupCompleted(email: String) {
        let completed = ref.child("COMPLETED RIDES").child(email)
        completed.observe(.value, with: {(snapshot) in
            if (snapshot.hasChildren()) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                self.deleteTS()
                self.ride.setEndTime(endTime: endTime)
                self.delegate?.setRide(ride: self.ride)
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    // Outputs the timestamp stored in UserDefaults
    func outputTS() {
        let preferences = UserDefaults.standard
        preferences.set(ride.getTimestamp(), forKey: "timestamp")
        preferences.synchronize()
    }
    
    // Deletes the timestamp stored in UserDefaults
    func deleteTS() {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: "timestamp")
    }
}
