//
//  MapsView.swift
//  Aces
//
//  Description: View/View Controller for the map to request rides.
//
//  Created by Kyle Workman on 6/14/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import Toast_Swift
import FirebaseDatabase
import FirebaseInstanceID
import FirebaseMessaging
import SearchTextField

struct MyPlace {
    var name: String
    var lat: Double
    var long: Double
}

class MapsView: UIViewController, GIDSignInUIDelegate, UITextFieldDelegate, CLLocationManagerDelegate, GMSMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MyProtocol, GMSAutocompleteViewControllerDelegate {
   
    var ref: DatabaseReference!
    var flag: String = ""
    var message: String = ""
    var locationManager = CLLocationManager()
    let currentLocationMarker = GMSMarker()
    var chosenPlaceStart = MyPlace(name: "", lat: 0, long: 0)
    var chosenPlaceEnd = MyPlace(name: "", lat: 0, long: 0)
    var activeTextField = SearchTextField()
    var markerStart = GMSMarker()
    var markerEnd = GMSMarker()
    var riders = ["1", "2", "3", "4", "5", "6", "7"]
    var ride: RideInfo = RideInfo(email: "",end: "",endTime: "",eta: "",numRiders: "",start: "",time: "",waitTime: "",ts: 0,token: "")
    var places = LocationDatabase.init().getPlaces()
    var names = LocationDatabase.init().getNames()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var autocompleteController = GMSAutocompleteViewController()
    
    let mapView: GMSMapView = {
        let v = GMSMapView()
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let txtFieldStart: SearchTextField = constructSearchFld(text: "Start Location")
    
    let txtFieldEnd: SearchTextField = constructSearchFld(text: "End Location")
    
    let requestBtn: UIButton = constructBtn(text: "Request Ride", color: UIColor.init(red: 170/255, green: 231/255, blue: 156/255, alpha: 1))
    
    let numRidersBtn: UIButton = constructBtn(text: "Number of Riders: 1", color: .white)
    
    let ridersSelector: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        picker.layer.borderColor = UIColor.darkGray.cgColor
        picker.isHidden = true
        picker.layoutIfNeeded()
        picker.translatesAutoresizingMaskIntoConstraints=false
        return picker
    }()
    
    let toggleRidersBtn: UIButton = {
        let btn = UIButton()
        btn.backgroundColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.25)
        let screenSize = UIScreen.main.bounds
        btn.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        btn.addTarget(self, action: #selector(toggleRiders), for: .touchUpInside)
        btn.isEnabled = false
        btn.isHidden = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Aces"
        mapView.delegate = self
        self.ref = Database.database().reference()
        
        initListener()
        hasCurrentRide()
        
        setupAutocomplete()
        
        requestBtn.addTarget(self, action: #selector(requestAction), for: .touchUpInside)
        requestBtn.isEnabled = false
        numRidersBtn.addTarget(self, action: #selector(ridersAction), for: .touchUpInside)
        numRidersBtn.isEnabled = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        
        initViews()
        initGoogleMaps()
        
        markerStart.icon = GMSMarker.markerImage(with: UIColor.green)
        markerEnd.icon = GMSMarker.markerImage(with: UIColor.red)
        
        txtFieldStart.delegate = self
        txtFieldEnd.delegate = self
        ridersSelector.delegate = self
        ridersSelector.dataSource = self
    }
    
    func setupAutocomplete() {
        let config = AcesConfiguration()
        let coord1 = CLLocationCoordinate2D(latitude: config.LAT2, longitude: config.LONG1)
        let coord2 = CLLocationCoordinate2D(latitude: config.LAT1, longitude: config.LONG2)
        let bounds = GMSCoordinateBounds(coordinate: coord1, coordinate: coord2)
        autocompleteController = GMSAutocompleteViewController()
        autocompleteController.autocompleteBounds = bounds
        autocompleteController.autocompleteBoundsMode = GMSAutocompleteBoundsMode.restrict
        let filter = GMSAutocompleteFilter()
        filter.country = "USA"
        filter.type = .address
        autocompleteController.autocompleteFilter = filter
        autocompleteController.delegate = self
    }
    
    // INITIALIZE
    func initViews() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        addSubviewAnchorTLRH(subView: txtFieldStart, top: 10, left: 10, right: -10, height: 35)
        setupTextField(textField: txtFieldStart, img: GMSMarker.markerImage(with: UIColor.green))
        txtFieldStart.filterStrings(names)
        txtFieldStart.itemSelectionHandler = { (item, position) in
            self.toggleDim()
            let name = item[position].title
            if (name == "Enter an Address") {
                self.present(self.autocompleteController, animated: true, completion: nil)
                self.setupAutocomplete()
            } else {
                let lat = self.places[name]![0]
                let long = self.places[name]![1]
                let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
                self.mapView.animate(to: camera)
                self.chosenPlaceStart = MyPlace(name: name, lat: lat, long: long)
                self.markerStart.map = self.mapView
                self.markerStart.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.markerStart.title = "Start: \(name)"
                self.txtFieldStart.text = "Start: \(name)"
                self.mapView.isUserInteractionEnabled = true
                self.txtFieldEnd.isEnabled = true
                self.view.endEditing(true)
            }
        }
        
        addSubviewAnchorTLRH(subView: txtFieldEnd, top: 50, left: 10, right: -10, height: 35)
        setupTextField(textField: txtFieldEnd, img: GMSMarker.markerImage(with: UIColor.red))
        txtFieldEnd.filterStrings(names)
        txtFieldEnd.itemSelectionHandler = { (item, position) in
            self.toggleDim()
            let name = item[position].title
            if (name == "Enter an Address") {
                self.present(self.autocompleteController, animated: true, completion: nil)
                self.setupAutocomplete()
            } else {
                let lat = self.places[name]![0]
                let long = self.places[name]![1]
                let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
                self.mapView.animate(to: camera)
                self.chosenPlaceEnd = MyPlace(name: name, lat: lat, long: long)
                self.markerEnd.map = self.mapView
                self.markerEnd.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.markerEnd.title = "End: \(name)"
                self.txtFieldEnd.text = "End: \(name)"
                self.mapView.isUserInteractionEnabled = true
                self.txtFieldStart.isEnabled = true
                self.view.endEditing(true)
            }
        }
        
        addSubviewAnchorBLRH(subView: requestBtn, btm: -10, left: 10, right: -10, height: 35)
        addSubviewAnchorBLRH(subView: numRidersBtn, btm: -50, left: 10, right: -10, height: 35)
        self.view.addSubview(toggleRidersBtn)
        addSubviewAnchorBLRH(subView: ridersSelector, btm: -50, left: 10, right: -10, height: 100)
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
    
    func setupTextField(textField: SearchTextField, img: UIImage){
        textField.leftViewMode = UITextFieldViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 11, y: 5, width: 13, height: 20))
        imageView.image = img
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: 25, height: 30))
        paddingView.addSubview(imageView)
        textField.leftView = paddingView
    }
    
    func initGoogleMaps() {
        let camera = GMSCameraPosition.camera(withLatitude: 41.505199, longitude: -90.550674, zoom: 15)
        self.mapView.camera = camera
        self.mapView.delegate = self
        self.mapView.isMyLocationEnabled = true
    }
    
    func initToasts(endTime: String) {
        if (endTime == "Cancelled by Dispatcher") {
            showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher.")
        } else if (endTime != "Cancelled by User" && ride.getETA() != " ") {
            self.view.makeToast("Thanks for using ACES!", position: .center)
        }
    }
    
    func initListener() {
        let flagRef = self.ref.child("STATUS")
        flagRef.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary
            self.flag = postDict?["FLAG"] as? String ?? ""
            let customMsg = postDict?["MESSAGE"] as? String ?? ""
            if (self.flag == "OFF") {
                if (customMsg == "") {
                    self.message = "---------Hours---------\nFall Term: 7pm - 2am\nWinter Term: 6pm - 2am\nSpring Term: 7pm-2am"
                } else {
                    self.message = "\(customMsg)\n\n---------Hours---------\nFall Term: 7pm - 2am\nWinter Term: 6pm - 2am\nSpring Term: 7pm-2am"
                }
                self.showAlert(title: "ACES Offline", msg: self.message)
            }
        })
        let email = appDelegate.getEmail().replacingOccurrences(of: ".", with: ",")
        let activeRef = self.ref.child("ACTIVE RIDES").child(email)
        let pendingRef = self.ref.child("PENDING RIDES").child(email)
        var count: Int = 0
        activeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            count = count + 1
            self.createRideGoRequested(email: email, snapshot: snapshot, count: count)
        })
        pendingRef.observeSingleEvent(of: .value, with: { (snapshot) in
            count = count + 1
            self.createRideGoRequested(email: email, snapshot: snapshot, count: count)
        })
    }
    
    func createRideGoRequested(email: String, snapshot: DataSnapshot, count: Int) {
        if (snapshot.childrenCount != 0) {
            let postDict = snapshot.value as? NSDictionary
            let end = postDict?["end"] as? String ?? ""
            let endTime = postDict?["endTime"] as? String ?? ""
            let eta = postDict?["endTime"] as? String ?? ""
            let numRiders = postDict?["numRiders"] as? String ?? ""
            let start = postDict?["start"] as? String ?? ""
            let time = postDict?["time"] as? String ?? ""
            let timestamp = postDict?["timestamp"] as? CLong ?? 0
            let waitTime = postDict?["waitTime"] as? String ?? ""
            self.ride = RideInfo(email: email, end: end, endTime: endTime, eta: eta, numRiders: numRiders, start: start, time: time, waitTime: waitTime, ts: timestamp, token: appDelegate.getToken())
            let nextView: RequestedRideView = RequestedRideView()
            nextView.ride = self.ride
            nextView.delegate = self
            self.present(nextView, animated: true, completion: nil)
        }; if (count == 2) {
            txtFieldStart.isEnabled = true
            txtFieldEnd.isEnabled = true
            mapView.isUserInteractionEnabled = true
            numRidersBtn.isEnabled = true
            requestBtn.isEnabled = true
        }
    }
    
    // LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //TODO what to do with this?
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
        toggleRiders()
        numRidersBtn.setTitle("Number of Riders: \(riders[row])", for: UIControlState.normal)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let newString = NSMutableAttributedString(string: riders[row])
        newString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange (location: 0, length: newString.length))
        return newString
    }
    
    // TEXT FIELD
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        toggleRiders()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = nil
        mapView.isUserInteractionEnabled = false
        view.bringSubview(toFront: toggleRidersBtn)
        toggleDim()
        if (textField == txtFieldStart) {
            activeTextField = txtFieldStart
            txtFieldStart.startVisibleWithoutInteraction = true
            txtFieldEnd.isEnabled = false
        } else {
            activeTextField = txtFieldEnd
            txtFieldEnd.startVisibleWithoutInteraction = true
            txtFieldStart.isEnabled = false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if (!toggleRidersBtn.isHidden) {
            cancelEditing()
            toggleDim()
        }
    }
    
    // GMS Autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        if (AcesConfiguration().isInACESBoundary(lat: lat, long: long)) {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
            mapView.camera = camera
            let name = place.name
            
            if (activeTextField == txtFieldStart) {
                chosenPlaceStart = MyPlace(name: name, lat: lat, long: long)
                markerStart.map = nil
                markerStart.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerStart.title = "Start: \(name)"
                markerStart.map = mapView
                activeTextField.text = "Start: \(name)"
                txtFieldEnd.isEnabled = true
            } else {
                chosenPlaceEnd = MyPlace(name: name, lat: lat, long: long)
                markerEnd.map = nil
                markerEnd.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerEnd.title = "End: \(name)"
                markerEnd.map = mapView
                activeTextField.text = "End: \(name)"
                txtFieldStart.isEnabled = true
            }
            mapView.isUserInteractionEnabled = true
        } else {
            cancelEditing()
            self.view.makeToast("Location out of Bounds", position: .center)
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func cancelEditing() {
        mapView.isUserInteractionEnabled = true
        txtFieldStart.isEnabled = true
        txtFieldEnd.isEnabled = true
        var name = chosenPlaceStart.name
        if (name != "") {
            txtFieldStart.text = "Start: \(chosenPlaceStart.name)"
        } else {
            txtFieldStart.text = ""
        }
        name = chosenPlaceEnd.name
        if (name != "") {
            txtFieldEnd.text = "End: \(chosenPlaceEnd.name)"
        } else {
            txtFieldEnd.text = ""
        }
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        cancelEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        cancelEditing()
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func toggleRiders() {
        toggleDim()
        if (txtFieldStart.isEditing) {
            view.endEditing(true)
            let name = chosenPlaceStart.name
            if (name != "") {
                txtFieldStart.text = "Start: \(chosenPlaceStart.name)"
            } else {
                txtFieldStart.text = ""
            }
            mapView.isUserInteractionEnabled = true
            txtFieldEnd.isEnabled = true
        } else if (txtFieldEnd.isEditing) {
            view.endEditing(true)
            let name = chosenPlaceEnd.name
            if (name != "") {
                txtFieldEnd.text = "End: \(chosenPlaceEnd.name)"
            } else {
                txtFieldEnd.text = ""
            }
            mapView.isUserInteractionEnabled = true
            txtFieldStart.isEnabled = true
        } else {
            ridersSelector.isHidden = !ridersSelector.isHidden
        }
    }
    
    func toggleDim() {
        toggleRidersBtn.isEnabled = !toggleRidersBtn.isEnabled
        toggleRidersBtn.isHidden = !toggleRidersBtn.isHidden
    }
    
    @objc func requestAction() {
        if (flag == "ON") {
            if (chosenPlaceEnd.lat == chosenPlaceStart.lat && chosenPlaceEnd.long == chosenPlaceStart.long ||
                chosenPlaceEnd.name == chosenPlaceStart.name) {
                self.view.makeToast("Please Select 2 Unique Locations", position: .center)
            } else if (txtFieldStart.text == "") {
                self.view.makeToast("Please Select a Start Location", position: .center)
            } else if (txtFieldEnd.text == "") {
                self.view.makeToast("Please Select an End Location", position: .center)
            } else {
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let email = appDelegate.getEmail().replacingOccurrences(of: ".", with: ",")
                let end = chosenPlaceEnd.name
                let numRiders = riders[ridersSelector.selectedRow(inComponent: 0)]
                let start = chosenPlaceStart.name
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yyyy h:mm aaa"
                let time = formatter.string(from: Date())
                let ts = Date().toMillis()
                let token = appDelegate.getToken()
                
                ride = RideInfo(email: email, end: end, endTime: " ", eta: " ", numRiders: numRiders, start: start, time: time, waitTime: "1000", ts: ts, token: token)
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
                user.child("token").setValue(token)
                
                let nextView: RequestedRideView = RequestedRideView()
                nextView.ride = ride
                nextView.delegate = self
                self.present(nextView, animated: true, completion: nil)
            }
        } else {
            self.showAlert(title: "ACES Offline", msg: self.message)
        }
    }
    
    @objc func ridersAction() {
        toggleRiders()
        view.bringSubview(toFront: toggleRidersBtn)
        view.bringSubview(toFront: ridersSelector)
    }
    
    func setRide(ride: RideInfo) {
        txtFieldStart.text = ""
        txtFieldEnd.text = ""
        chosenPlaceStart = MyPlace(name: "", lat: 0, long: 0)
        chosenPlaceEnd = MyPlace(name: "", lat: 0, long: 0)
        numRidersBtn.setTitle("Number of Riders: 1", for: UIControlState.normal)
        ridersSelector.selectRow(0, inComponent: 0, animated: false)
        initToasts(endTime: ride.getEndTime())
        self.ride = RideInfo(email: "",end: "",endTime: "",eta: "",numRiders: "",start: "",time: "",waitTime: "",ts: 0,token: "")
        self.mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: 41.505199, longitude: -90.550674, zoom: 15)
        self.mapView.camera = camera
    }
    
    // Returns whether or not file timestamp.txt exists
    func hasCurrentRide() {
        let preferences = UserDefaults.standard
        if preferences.object(forKey: "timestamp") != nil {
            let email = appDelegate.getEmail().replacingOccurrences(of: ".", with: ",")
            let timestamp = preferences.string(forKey: "timestamp")
            checkCancelled(email: email, ts: timestamp!)
        }
    }
    
    func checkCancelled(email: String, ts: String) {
        let cancelled = ref.child("CANCELLED RIDES").child("\(email)_\(ts)")
        cancelled.observeSingleEvent(of: .value, with: {(snapshot) in
            if (snapshot.hasChildren()) {
                let postDict = snapshot.value as? NSDictionary
                let endTime = postDict?["endTime"] as? String ?? ""
                if (endTime == "Cancelled by Dispatcher") {
                    self.showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher.")
                }
            }
        })
        deleteTS()
    }
    
    // Deletes the timestamp stored in UserDefaults
    func deleteTS() {
        let preferences = UserDefaults.standard
        preferences.removeObject(forKey: "timestamp")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func showAlert(title: String, msg: String) {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async(execute: {
            self.present(alert, animated: true, completion: nil)
        })
    }
    
}

extension Date {
    func toMillis() -> CLong {
        return CLong(self.timeIntervalSince1970 * 1000)
    }
}

