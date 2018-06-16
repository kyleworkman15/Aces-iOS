//
//  MapsView.swift
//  Aces
//
//  Created by checkout-7 on 6/14/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import Toast_Swift
import FirebaseDatabase

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

class MapsView: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, GMSAutocompleteViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var ref: DatabaseReference!
    var flag: String = ""
    var locationManager = CLLocationManager()
    let currentLocationMarker = GMSMarker()
    var chosenPlaceFrom: MyPlace?
    var chosenPlaceTo: MyPlace?
    var activeTextField = UITextField()
    var markerFrom = GMSMarker()
    var markerTo = GMSMarker()
    var riders = ["1", "2", "3", "4", "5", "6", "7"]
    var ride: RideInfo = RideInfo(email: "",end: "",endTime: "",eta: "",numRiders: "",start: "",time: "",waitTime: "",ts: "")
    
    let mapView: GMSMapView = {
        let v = GMSMapView()
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let txtFieldFrom: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.darkGray.cgColor
        tf.placeholder="Start Location"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
    }()
    
    let txtFieldTo: UITextField = {
        let tf = UITextField()
        tf.borderStyle = .roundedRect
        tf.backgroundColor = .white
        tf.layer.borderColor = UIColor.darkGray.cgColor
        tf.placeholder="End Location"
        tf.translatesAutoresizingMaskIntoConstraints=false
        return tf
    }()
    
    let requestBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .green
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.setTitle("Request Ride", for: UIControlState.normal)
        btn.setTitleColor(.black, for: UIControlState.normal)
        btn.addTarget(self, action: #selector(requestAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let numRidersBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = .white
        btn.layer.borderColor = UIColor.darkGray.cgColor
        btn.setTitle("Number of Riders: 1", for: UIControlState.normal)
        btn.setTitleColor(.black, for: UIControlState.normal)
        btn.addTarget(self, action: #selector(ridersAction), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints=false
        return btn
    }()
    
    let ridersSelector: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = .gray
        picker.layer.borderColor = UIColor.darkGray.cgColor
        picker.translatesAutoresizingMaskIntoConstraints=false
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Aces"
        mapView.delegate=self
        self.ref = Database.database().reference()
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initViews()
        initGoogleMaps()
        initToasts()
        initListener()
        
        markerFrom.icon = GMSMarker.markerImage(with: UIColor.blue)
        markerTo.icon = GMSMarker.markerImage(with: UIColor.green)
        
        txtFieldFrom.delegate = self
        txtFieldTo.delegate = self
        ridersSelector.delegate = self
        ridersSelector.dataSource = self
    }
    
    // INITIALIZE
    func initViews() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        self.view.addSubview(txtFieldFrom)
        txtFieldFrom.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        txtFieldFrom.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtFieldFrom.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtFieldFrom.heightAnchor.constraint(equalToConstant: 35).isActive=true
        setupTextField(textField: txtFieldFrom, img: #imageLiteral(resourceName: "map_Pin"))
        
        self.view.addSubview(txtFieldTo)
        txtFieldTo.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive=true
        txtFieldTo.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtFieldTo.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtFieldTo.heightAnchor.constraint(equalToConstant: 35).isActive=true
        setupTextField(textField: txtFieldTo, img: #imageLiteral(resourceName: "map_Pin"))
        
        self.view.addSubview(requestBtn)
        requestBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10).isActive=true
        requestBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        requestBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        requestBtn.heightAnchor.constraint(equalToConstant: 35).isActive=true
        
        self.view.addSubview(numRidersBtn)
        numRidersBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive=true
        numRidersBtn.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        numRidersBtn.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        numRidersBtn.heightAnchor.constraint(equalToConstant: 35).isActive=true
        
        self.view.addSubview(ridersSelector)
        ridersSelector.isHidden = true
        ridersSelector.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -150).isActive=true
        ridersSelector.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        ridersSelector.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        ridersSelector.heightAnchor.constraint(equalToConstant: 100).isActive=true
        ridersSelector.layoutIfNeeded()
        
    }
    
    func setupTextField(textField: UITextField, img: UIImage){
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 30, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 41.505199, longitude: -90.550674, zoom: 15)
        
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }
    
    func initToasts() {
        let endTime = ride.getEndTime()
        if (endTime == "Cancelled by Dispatcher") {
            self.view.makeToast("Requested ride cancelled by dispatcher", position: .center)
        } else if (endTime != " " && ride.getETA() != "") {
            self.view.makeToast("Thanks for using ACES!", position: .center)
        } 
    }
    
    func initListener() {
        let flagRef = self.ref.child("STATUS")
        flagRef.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary
            self.flag = postDict?["FLAG"] as? String ?? ""
        })
    }
    
    // LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO what to do with this?
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
        //let location = locations.last
        //let lat = (location?.coordinate.latitude)!
        //let long = (location?.coordinate.longitude)!
        //let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
        
        //self.mapView.animate(to: camera)
    }
    
    // MAP VIEW
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        self.mapView.isMyLocationEnabled = true
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        self.mapView.isMyLocationEnabled = true
        if (gesture) {
            mapView.selectedMarker = nil
        }
    }
    
    // VIEW CONTROLLER
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        
        if (AcesConfiguration().isInACESBoundary(lat: lat, long: long)) {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
            mapView.camera = camera
            let name = place.name.replacingOccurrences(of: ", Augustana College", with: "")
            activeTextField.text=name
            
            if (activeTextField == txtFieldFrom) {
                chosenPlaceFrom = MyPlace(name: name, lat: lat, long: long)
                markerFrom.map = nil
                markerFrom.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerFrom.title = "Start: \(name)"
                markerFrom.snippet = "\(place.formattedAddress!)"
                markerFrom.map = mapView
            } else {
                chosenPlaceTo = MyPlace(name: name, lat: lat, long: long)
                markerTo.map = nil
                markerTo.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerTo.title = "End: \(name)"
                markerTo.snippet = "\(place.formattedAddress!)"
                markerTo.map = mapView
            }
        } else {
            self.view.makeToast("Location out of Bounds", position: .center)
        }

        self.dismiss(animated: true, completion: nil) // dismiss after place selected
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Error doing auto complete \(error)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    // PICKER VIEW
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return riders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return riders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        ridersSelector.isHidden = true
        numRidersBtn.setTitle("Number of Riders: \(riders[row])", for: UIControlState.normal)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let newString = NSMutableAttributedString(string: riders[row])
        newString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.white, range: NSRange (location: 0, length: newString.length))
        return newString
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let autoCompleteController = GMSAutocompleteViewController()
        autoCompleteController.delegate = self
        
        let filter = GMSAutocompleteFilter()
        autoCompleteController.autocompleteFilter = filter
        
        self.locationManager.startUpdatingLocation()
        self.present(autoCompleteController, animated: true, completion: nil)
        
        activeTextField = textField
        
        return false
    }
    
    @objc func requestAction() {
        if (flag == "ON") {
            if (chosenPlaceFrom?.lat == chosenPlaceTo?.lat && chosenPlaceFrom?.long == chosenPlaceTo?.long) {
                self.view.makeToast("Please Select 2 Unique Locations", position: .center)
            } else if (txtFieldFrom.text == "") {
                self.view.makeToast("Please Select a From Location", position: .center)
            } else if (txtFieldTo.text == "") {
                self.view.makeToast("Please Select a To Location", position: .center)
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let email = appDelegate.getEmail().replacingOccurrences(of: ".", with: ",")
                let end = (chosenPlaceTo?.name)!
                let numRiders = riders[ridersSelector.selectedRow(inComponent: 0)]
                let start = (chosenPlaceFrom?.name)!
                let time = "Date" //TODO
                let ts = String(Date().toMillis())
                
                ride = RideInfo(email: email, end: end, endTime: " ", eta: " ", numRiders: numRiders, start: start, time: time, waitTime: "1000", ts: ts)
                let user = self.ref.child("PENDING RIDES").child(email)
                user.child("email").setValue(email)
                user.child("end").setValue(end)
                user.child("endTime").setValue(" ")
                user.child("eta").setValue(" ")
                user.child("numRiders").setValue(numRiders)
                user.child("start").setValue(start)
                user.child("time").setValue(time)
                user.child("waitTime").setValue("1000")
                user.child("timestamp").setValue(ts)
                
                let nextView: RequestedRideView = RequestedRideView()
                nextView.ride = ride
                self.present(nextView, animated: true, completion: nil)
            }
        } else {
            self.view.makeToast("---------Hours---------\nFall Term: 7pm - 2am\nWinter Term: 6pm - 2am\nSpring Term: 7pm-2am", duration: 5,  position: .center, title: "ACES is currently offline")
        }
    }
    
    @objc func ridersAction() {
        ridersSelector.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

extension Date {
    func toMillis() -> CLong {
        return CLong(self.timeIntervalSince1970 * 1000)
    }
}

