//
//  RequestedRideView.swift
//  Aces
//
//  Created by checkout-7 on 6/15/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase

class RequestedRideView: UIViewController {
    
    var ref: DatabaseReference!
    var ride: RideInfo!
    
    let cancelBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .red
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.setTitle("CANCEL RIDE", for: UIControlState.normal)
        btn.setTitleColor(.black, for: UIControlState.normal)
        btn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let titleLbl1: UILabel = {
        let lbl = UILabel()
        lbl.text = "Your ride has"
        lbl.font = UIFont.boldSystemFont(ofSize: 30)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let titleLbl2: UILabel = {
        let lbl = UILabel()
        lbl.text = "been requested!"
        lbl.font = UIFont.boldSystemFont(ofSize: 30)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let minutesLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "Estimated Wait Time: PENDING"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)

        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let etaLbl: UILabel = {
        let lbl = UILabel()
        lbl.text = "ETA: PENDING"
        lbl.font = UIFont.boldSystemFont(ofSize: 20)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Aces"
        self.ref = Database.database().reference()
        
        initViews()
    }
    
    func initViews() {
        view.backgroundColor = UIColor.green
        
        view.addSubview(titleLbl1)
        titleLbl1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive=true
        titleLbl1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        titleLbl1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        titleLbl1.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        view.addSubview(titleLbl2)
        titleLbl2.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 95).isActive=true
        titleLbl2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        titleLbl2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        titleLbl2.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        view.addSubview(minutesLbl)
        minutesLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 185).isActive=true
        minutesLbl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        minutesLbl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        minutesLbl.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        view.addSubview(etaLbl)
        etaLbl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 230).isActive=true
        etaLbl.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        etaLbl.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        etaLbl.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        view.addSubview(cancelBtn)
        cancelBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive=true
        cancelBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        cancelBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        cancelBtn.heightAnchor.constraint(equalToConstant: 35).isActive=true
        
        setupListener()
    }
    
    @objc func cancelAction() {
        if (minutesLbl.text?.contains("PENDING"))! {
            deleteRide(type: "PENDING RIDES")
        } else {
            deleteRide(type: "ACTIVE RIDES")
        }
    }
    
    func deleteRide(type: String) {
        let email = ride.getEmail()
        let cancelled = ref.child("CANCELLED RIDES").child(email)
        let typeRef = ref.child(type).child(email)
        typeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            self.ride.setEndTime(endTime: "Cancelled by User")
            let postDict = snapshot.value as? NSDictionary
            let end = postDict?["end"] as? String ?? ""
            let eta = postDict?["endTime"] as? String ?? ""
            let numRiders = postDict?["numRiders"] as? String ?? ""
            let start = postDict?["start"] as? String ?? ""
            let time = postDict?["time"] as? String ?? ""
            let timestamp = postDict?["timestamp"] as? String ?? ""
            let waitTime = postDict?["waitTime"] as? String ?? ""
            cancelled.setValue(["email": email, "end": end, "endTime": "Cancelled by User", "eta": eta, "numRiders": numRiders, "start": start, "time": time, "timestamp": timestamp, "waitTime": waitTime])
            typeRef.removeValue()
            let nextView: MapsView = MapsView()
            self.present(nextView, animated: true, completion: nil)
        })
    }
    
    func setupListener() {
        let email = ride.getEmail()
        let active = ref.child("ACTIVE RIDES").child(email)
        let pending = ref.child("PENDING RIDES").child(email)
        active.observe(.value, with: { (snapshot) in
            if (snapshot.childrenCount != 0) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                if (endTime == "Cancelled by Dispatcher") {
                    self.ride.setEndTime(endTime: endTime)
                    let nextView: MapsView = MapsView()
                    nextView.ride = self.ride
                    self.present(nextView, animated: true, completion: nil)
                } else if (endTime == " ") {
                    let waitTime = postDict?["waitTime"] as? String ?? ""
                    if (waitTime != "1000") {
                        self.minutesLbl.text = "Estimated Wait Time: \(waitTime) minutes"
                        self.ride.setWaitTime(waitTime: waitTime)
                    }
                    let eta = postDict?["eta"] as? String ?? ""
                    if (eta != " ") {
                        self.etaLbl.text = "ETA: \(eta)"
                        self.ride.setETA(eta: eta)
                    }
                } else {
                    self.ride.setEndTime(endTime: endTime)
                    let nextView: MapsView = MapsView()
                    nextView.ride = self.ride
                    self.present(nextView, animated: true, completion: nil)
                }
            }
        })
        pending.observe(.value, with: { (snapshot) in
            if (snapshot.childrenCount != 0) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                if (endTime == "Cancelled by Dispatcher") {
                    self.ride.setEndTime(endTime: endTime)
                    let nextView: MapsView = MapsView()
                    nextView.ride = self.ride
                    self.present(nextView, animated: true, completion: nil)
                } else if (endTime == " ") {
                    let waitTime = postDict?["waitTime"] as? String ?? ""
                    if (waitTime != "1000") {
                        self.minutesLbl.text = "Estimated Wait Time: \(waitTime) minutes"
                        self.ride.setWaitTime(waitTime: waitTime)
                    }
                    let eta = postDict?["eta"] as? String ?? ""
                    if (eta != " ") {
                        self.etaLbl.text = "ETA: \(eta)"
                        self.ride.setETA(eta: eta)
                    }
                } else {
                    self.ride.setEndTime(endTime: endTime)
                    let nextView: MapsView = MapsView()
                    nextView.ride = self.ride
                    self.present(nextView, animated: true, completion: nil)
                }
            }
        })
    }
    
}
