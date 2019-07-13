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
    func setRide(ride: RideInfo, message: String)
}

class RequestedRideView: UIViewController {
    
    var ref: DatabaseReference!
    var ride: RideInfo!
    var delegate: MyProtocol?
    var estWT: Int = 0
    
    // Button for canceling the current ride
    var cancelBtn: UIButton = constructBtn(text: "CANCEL RIDE", color: .red)
    
    let etaLbl: UILabel = constructLbl(text: "Estimated Wait Time:\n- minutes")
    
    // Label for displaying the starting location, ending location, wait time, ETA
    let dataLbl: UILabel = constructLbl(text: "Start:\nEnd:\nVehicle: TBD")
    
    let doNotCancelLbl: UILabel = constructLbl(text: "Do not cancel your ride once picked up.")
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        self.ref = Database.database().reference()
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        let screenSize = UIScreen.main.bounds
        let line = constructLogo(path: "line")
        line.translatesAutoresizingMaskIntoConstraints = false
        let title = constructLogo(path: "request_title")
        title.translatesAutoresizingMaskIntoConstraints = false
        
        waitTimeListener()
        addSubviewAnchorTLRH(subView: title, top: screenSize.height/15, left: 20, right: -20, height: 10*screenSize.height/100)
        addSubviewAnchorTLRH(subView: etaLbl, top: 3.0*screenSize.height/15, left: 0, right: 0, height: 60)
        addSubviewAnchorTLRH(subView: line, top: 4.5*screenSize.height/15, left: screenSize.width/4, right: -screenSize.width/4, height: 1)
        addSubviewAnchorTLRH(subView: dataLbl, top: 4.6*screenSize.height/15, left: 0, right: 0, height: 120)
        addSubviewAnchorBLRH(subView: doNotCancelLbl, btm: -50, left: 0, right: 0, height: 35)
        addSubviewAnchorBLRH(subView: cancelBtn, btm: -10, left: 10, right: -10, height: 35)
        let width = screenSize.width
        let height = screenSize.height
        let logo = constructLogo(path: "aces_image")
        logo.frame = CGRect(x: (width/2)-(width/2/2), y: (16*height/24)-(width/2/2), width: width/2, height: width/2)
        view.addSubview(logo)
        
        setupListeners()
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
            self.deleteRide()
            self.deleteTS()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // Deletes the current ride from the ACTIVE or PENDING tree from the Firebase database,
    // adds the ride to the CANCELLED tree, and returns to the Maps View
    func deleteRide() {
        let email = ride.getEmail()
        let emailTS = "\(ride.getEmail())_\(ride.getTimestamp())"
        let cancelled = ref.child("CANCELLED RIDES").child(emailTS)
        let pendingRef = ref.child("PENDING RIDES").child(email)
        let activeRef = ref.child("ACTIVE RIDES").child(email)
        pendingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.hasChildren()) {
                self.ride.setEndTime(endTime: "Cancelled by User")
                let postDict = snapshot.value as? NSDictionary
                let end = postDict?["end"] as? String ?? ""
                let eta = postDict?["endTime"] as? String ?? ""
                let numRiders = postDict?["numRiders"] as? String ?? ""
                let start = postDict?["start"] as? String ?? ""
                let time = postDict?["time"] as? String ?? ""
                let timestamp = postDict?["timestamp"] as? CLong ?? 0
                let waitTime = postDict?["waitTime"] as? String ?? ""
                let vehicle = postDict?["vehicle"] as? String ?? ""
                cancelled.setValue(["email": email, "end": end, "endTime": "Cancelled by User", "eta": eta, "numRiders": numRiders, "start": start, "time": time, "timestamp": timestamp, "waitTime": waitTime, "vehicle": vehicle])
                pendingRef.setValue(["email": email, "endTime": "Cancelled by User", "timestamp": timestamp])
                pendingRef.removeValue()
                self.delegate?.setRide(ride: self.ride, message: "")
                self.dismiss(animated: true, completion: nil)
            }
        })
        activeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if (snapshot.hasChildren()) {
                self.ride.setEndTime(endTime: "Cancelled by User")
                let postDict = snapshot.value as? NSDictionary
                let end = postDict?["end"] as? String ?? ""
                let eta = postDict?["endTime"] as? String ?? ""
                let numRiders = postDict?["numRiders"] as? String ?? ""
                let start = postDict?["start"] as? String ?? ""
                let time = postDict?["time"] as? String ?? ""
                let timestamp = postDict?["timestamp"] as? CLong ?? 0
                let waitTime = postDict?["waitTime"] as? String ?? ""
                let vehicle = postDict?["vehicle"] as? String ?? ""
                cancelled.setValue(["email": email, "end": end, "endTime": "Cancelled by User", "eta": eta, "numRiders": numRiders, "start": start, "time": time, "timestamp": timestamp, "waitTime": waitTime, "vehicle": vehicle])
                activeRef.setValue(["email": email, "endTime": "Cancelled by User", "timestamp": timestamp])
                activeRef.removeValue()
                self.delegate?.setRide(ride: self.ride, message: "")
                self.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func waitTimeListener() {
        let estWTRef = self.ref.child("EST WAIT TIME")
        estWTRef.observeSingleEvent(of: .value, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary
            self.estWT = postDict?["estimatedWT"] as? Int ?? 0
            let text = "Estimated Wait Time: \(self.estWT) minutes"
            self.etaLbl.text = text
        })
    }
    
    // Set up the Firebase listeners for if a ride is completed, cancelled, or updated by the dipatcher
    func setupListeners() {
        let email = ride.getEmail()
        let active = ref.child("ACTIVE RIDES").child(email)
        let pending = ref.child("PENDING RIDES").child(email)
        setupPendingOrActive(email: email, ref: pending)
        setupPendingOrActive(email: email, ref: active)
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
                    var vehicle = postDict?["vehicle"] as? String ?? ""
                    let ts = postDict?["timestamp"] as? Int64 ?? 0
                    if (vehicle == " ") {
                        self.dataLbl.text = "Start: \(start)\nEnd: \(end)\nVehicle: TBD"
                    } else {
                        vehicle = vehicle.replacingOccurrences(of: "\\s?\\([\\w\\s]*\\)", with: "", options: .regularExpression)
                        self.dataLbl.text = "Start: \(start)\nEnd: \(end)\nVehicle: \(vehicle)"
                    }
                    if (waitTime == "1000" && eta == " ") {
                        self.etaLbl.text = "Estimated Wait Time:\n\(self.estWT) minutes"
                    } else {
                        self.etaLbl.text = "ETA:\n\(eta)"
                    }
                    self.ride.setVehicle(vehicle: vehicle)
                    self.ride.setWaitTime(waitTime: waitTime)
                    self.ride.setTimestamp(ts: ts)
                    self.ride.setETA(eta: eta)
                }
                let emailTS = "\(self.ride.getEmail())_\(self.ride.getTimestamp())" // email with timestamp
                self.setupCancelled(email: emailTS)
                self.setupCompleted(email: emailTS)
                self.outputTS()
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
                    let message = postDict?["message"] as? String ?? ""
                    self.delegate?.setRide(ride: self.ride, message: message)
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
                self.delegate?.setRide(ride: self.ride, message: "")
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
