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
    var location: CLLocation = CLLocation(latitude: 0, longitude: 0)
    var locDB: LocationDatabase = LocationDatabase()
    var favStart = UIImageView()
    var favEnd = UIImageView()
    var favorites = [String : Array<Double>]()
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
    var doors = ["Front", "Back", "Side"]
    var ride: RideInfo = RideInfo(email: "",end: "",endTime: "",eta: "",numRiders: "",start: "",time: "",waitTime: "",ts: 0,token: "",vehicle: "")
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var autocompleteController = GMSAutocompleteViewController()
    var isActivated = false
    var estWaitTime: Int = 5
    
    let mapView: GMSMapView = {
        let v = GMSMapView()
        v.isUserInteractionEnabled = false
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    let txtFieldStart: SearchTextField = constructSearchFld(text: "Start Location", color: UIColor.init(red: 218/255, green: 227/255, blue: 242/255, alpha: 1))
    
    let txtFieldEnd: SearchTextField = constructSearchFld(text: "End Location", color: UIColor.init(red: 253/255, green: 248/255, blue: 214/255, alpha: 1))
    
    let requestBtn: UIButton = constructBtn(text: "Request Ride", color: UIColor.init(red: 244/255, green: 220/255, blue: 53/255, alpha: 1))
    //UIColor.init(red: 106/255, green: 144/255, blue: 201/255, alpha: 1)
    let numRidersBtn: UIButton = constructBtn(text: "Number of Riders: 1", color: UIColor.init(red: 218/255, green: 227/255, blue: 242/255, alpha: 1))
    
    let doorBtn: UIButton = constructBtn(text: "Pick-up Door: Front", color: UIColor.init(red: 218/255, green: 227/255, blue: 242/255, alpha: 1))
    
    let ridersSelector: UIPickerView = {
        let picker = UIPickerView()
        picker.backgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        picker.layer.borderColor = UIColor.darkGray.cgColor
        picker.isHidden = true
        picker.layoutIfNeeded()
        picker.translatesAutoresizingMaskIntoConstraints=false
        return picker
    }()
    
    let doorSelector: UIPickerView = {
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
    
    let estWTLbl: UILabel = {
        let lbl = UILabel()
        lbl.backgroundColor = UIColor.init(red: 255, green: 255, blue: 255, alpha: 0.50)
        lbl.textColor = .black
        lbl.textAlignment = .center
        lbl.translatesAutoresizingMaskIntoConstraints=false
        lbl.numberOfLines = 0
        lbl.adjustsFontSizeToFitWidth = true
        return lbl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Aces"
        mapView.delegate = self
        self.ref = Database.database().reference()
        
        ToastManager.shared.style.activityBackgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        ToastManager.shared.style.activityIndicatorColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        mapView.makeToastActivity(.center)
        view.isUserInteractionEnabled = false
        
        initListener()
        hasCurrentRide()
        getFavorites()
        setupAutocomplete()
        
        requestBtn.addTarget(self, action: #selector(requestAction), for: .touchUpInside)
        requestBtn.isEnabled = false
        numRidersBtn.addTarget(self, action: #selector(ridersAction), for: .touchUpInside)
        numRidersBtn.isEnabled = false
        doorBtn.addTarget(self, action: #selector(doorAction), for: .touchUpInside)
        doorBtn.isEnabled = false
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        initViews()
        setupFavStars()
        initGoogleMaps()
        locationListener()
        
        let markerImage = UIImage(named: "blue1")!.withRenderingMode(.alwaysOriginal)
        let markerView = UIImageView(image: markerImage)
        markerStart.iconView = markerView
        let markerImage2 = UIImage(named: "gold1")!.withRenderingMode(.alwaysOriginal)
        let markerView2 = UIImageView(image: markerImage2)
        markerEnd.iconView = markerView2
        //markerStart.icon = GMSMarker.markerImage(with: UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1))
        //markerEnd.icon = GMSMarker.markerImage(with: UIColor.init(red: 244/255, green: 220/255, blue: 53/255, alpha: 1))
        
        txtFieldStart.delegate = self
        txtFieldStart.comparisonOptions = [.forcedOrdering, .caseInsensitive]
        txtFieldEnd.comparisonOptions = [.forcedOrdering, .caseInsensitive]
        txtFieldEnd.delegate = self
        ridersSelector.delegate = self
        ridersSelector.dataSource = self
        doorSelector.delegate = self
        doorSelector.dataSource = self
    }
    
    func setupFavStars() {
        favStart.isHidden = true
        favEnd.isHidden = true
        view.addSubview(favStart)
        view.addSubview(favEnd)
        let tapDelegateStart = UITapGestureRecognizer(target: self, action: #selector(tappedStart(tapDelegate:)))
        let tapDelegateEnd = UITapGestureRecognizer(target: self, action: #selector(tappedEnd(tapDelegate:)))
        favStart.isUserInteractionEnabled = true
        favStart.addGestureRecognizer(tapDelegateStart)
        favEnd.isUserInteractionEnabled = true
        favEnd.addGestureRecognizer(tapDelegateEnd)
        let screenSize = UIScreen.main.bounds
        favStart.translatesAutoresizingMaskIntoConstraints = false
        favStart.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive=true
        favStart.leftAnchor.constraint(equalTo: view.leftAnchor, constant: screenSize.width-10-35).isActive=true
        favStart.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        favStart.heightAnchor.constraint(equalToConstant: 35).isActive=true
        favEnd.translatesAutoresizingMaskIntoConstraints = false
        favEnd.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive=true
        favEnd.leftAnchor.constraint(equalTo: view.leftAnchor, constant: screenSize.width-10-35).isActive=true
        favEnd.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        favEnd.heightAnchor.constraint(equalToConstant: 35).isActive=true
        let path = Bundle.main.path(forResource: "btn_star_big_off", ofType: "png", inDirectory: "Images")
        favStart.image = UIImage(named: path!)
        favEnd.image = UIImage(named: path!)
    }
    
    @objc
    func tappedStart(tapDelegate: UITapGestureRecognizer) {
        if (favorites[chosenPlaceStart.name] != nil) {
            view.makeToast("Removed from favorites", position: .center)
            favorites.removeValue(forKey: chosenPlaceStart.name)
            removeFavoriteFromDropDownAndDatabase(name: chosenPlaceStart.name)
            saveFavorites()
            let path = Bundle.main.path(forResource: "btn_star_big_off", ofType: "png", inDirectory: "Images")
            favStart.image = UIImage(named: path!)
        } else {
            displayPopUpForFavorite(b: true)
        }
        if (chosenPlaceStart.name == chosenPlaceEnd.name) {
            setStar(name: chosenPlaceEnd.name, v: favEnd)
        }
    }
    
    @objc
    func tappedEnd(tapDelegate: UITapGestureRecognizer) {
        if (favorites[chosenPlaceEnd.name] != nil) {
            view.makeToast("Removed from favorites", position: .center)
            favorites.removeValue(forKey: chosenPlaceEnd.name)
            removeFavoriteFromDropDownAndDatabase(name: chosenPlaceEnd.name)
            saveFavorites()
            let path = Bundle.main.path(forResource: "btn_star_big_off", ofType: "png", inDirectory: "Images")
            favEnd.image = UIImage(named: path!)
        } else {
            displayPopUpForFavorite(b: false)
        }
        if (chosenPlaceStart.name == chosenPlaceEnd.name) {
            setStar(name: chosenPlaceStart.name, v: favStart)
        }
    }
    
    func displayPopUpForFavorite(b: Bool) {
        let alertController = UIAlertController(title: "Add to Favorites", message: "Enter a nickname for the location. The location will be saved in the drop down box.", preferredStyle: UIAlertControllerStyle.alert)
        alertController.addTextField(configurationHandler: { (textField: UITextField) -> Void in
            textField.delegate = self
        })
        let addAction = UIAlertAction(title: "Add", style: UIAlertActionStyle.default, handler: { (alert) -> Void in
            let field = alertController.textFields![0] as UITextField
            var favorite = field.text ?? ""
            favorite = "* \(favorite)"
            if (b) {
                let oldNameStr = self.chosenPlaceStart.name
                let oldName = self.chosenPlaceStart.name.split(separator: "-")
                self.chosenPlaceStart.name = "\(String(describing: favorite)) - \(oldName[oldName.count-1].trimmingCharacters(in: .whitespacesAndNewlines))"
                self.favorites[self.chosenPlaceStart.name] = [self.chosenPlaceStart.lat, self.chosenPlaceStart.long]
                self.addFavoriteToDropDownAndDatabase(name: self.chosenPlaceStart.name, lat: self.chosenPlaceStart.lat, long: self.chosenPlaceStart.long)
                self.saveFavorites()
                self.txtFieldStart.text = "Start: \(self.chosenPlaceStart.name)"
                self.markerStart.title = "Start: \(self.chosenPlaceStart.name)"
                let path = Bundle.main.path(forResource: "btn_star_big_on", ofType: "png", inDirectory: "Images")
                self.favStart.image = UIImage(named: path!)
                if (oldNameStr == self.chosenPlaceEnd.name) {
                    self.chosenPlaceEnd.name = self.chosenPlaceStart.name
                    self.setStar(name: self.chosenPlaceEnd.name, v: self.favEnd)
                    self.txtFieldEnd.text = "End: \(self.chosenPlaceEnd.name)"
                    self.markerEnd.title = "End: \(self.chosenPlaceEnd.name)"
                }
            } else {
                let oldNameStr = self.chosenPlaceEnd.name
                let oldName = self.chosenPlaceEnd.name.split(separator: "-")
                self.chosenPlaceEnd.name = "\(String(describing: favorite)) - \(oldName[oldName.count-1].trimmingCharacters(in: .whitespacesAndNewlines))"
                self.favorites[self.chosenPlaceEnd.name] = [self.chosenPlaceEnd.lat, self.chosenPlaceEnd.long]
                self.addFavoriteToDropDownAndDatabase(name: self.chosenPlaceEnd.name, lat: self.chosenPlaceEnd.lat, long: self.chosenPlaceEnd.long)
                self.saveFavorites()
                self.txtFieldEnd.text = "End: \(self.chosenPlaceEnd.name)"
                self.markerEnd.title = "End: \(self.chosenPlaceEnd.name)"
                let path = Bundle.main.path(forResource: "btn_star_big_on", ofType: "png", inDirectory: "Images")
                self.favEnd.image = UIImage(named: path!)
                if (oldNameStr == self.chosenPlaceStart.name) {
                    self.chosenPlaceStart.name = self.chosenPlaceEnd.name
                    self.setStar(name: self.chosenPlaceStart.name, v: self.favStart)
                    self.txtFieldStart.text = "Start: \(self.chosenPlaceStart.name)"
                    self.markerStart.title = "Start: \(self.chosenPlaceStart.name)"
                }
            }
            self.view.makeToast("Added to favorites", position: .center)
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.default) { (action: UIAlertAction!) -> Void in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let obj = textField as? SearchTextField {
            return true
        } else {
            if string.count > 0, !"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ 0123456789".contains(string) {
                return false
            }
            return true
        }
    }
    
    func waitTimeListener() {
        isActivated = true
        let estWTRef = self.ref.child("EST WAIT TIME")
        estWTRef.observe(.value, with: { (snapshot) in
            let postDict = snapshot.value as? NSDictionary
            self.estWaitTime = postDict?["estimatedWT"] as? Int ?? 0
            if (self.flag == "ON") {
                let text = "Estimated Wait Time: \(String(describing: self.estWaitTime)) minutes"
                self.estWTLbl.text = text
            }
        })
    }
    
    func locationListener() {
        let locRef = self.ref.child("LOCATIONS")
        locRef.observe(.value, with: { (snapshot) in
            self.locDB = LocationDatabase.init()
            let enumerator = snapshot.children
            while let loc = enumerator.nextObject() as? DataSnapshot {
                let postDict = loc.value as? NSDictionary
                let name = postDict?["name"] as? String ?? ""
                let lat = postDict?["lat"] as? Double ?? 0
                let lng = postDict?["long"] as? Double ?? 0
                self.locDB.addLocation(name: name, lat: lat, lng: lng)
            }
            for key in self.favorites.keys {
                let arr = self.favorites[key]
                self.locDB.addLocation(name: key, lat: arr![0], lng: arr![1])
            }
            self.updateDropDown()
        })
    }
    
    func updateDropDown() {
        var startNames = [String]()
        var i = 0
        startNames.append("My Location")
        let names = self.locDB.getNames()
        while i < names.count {
            startNames.append(names[i])
            i = i + 1
        }
        self.txtFieldStart.filterStrings(startNames)
        self.txtFieldEnd.filterStrings(names)
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
        updateDropDown()
    }
    
    // INITIALIZE
    func initViews() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive=true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive=true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive=true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 60).isActive=true
        
        addSubviewAnchorTLRH(subView: txtFieldStart, top: 10, left: 10, right: -10, height: 35)
        txtFieldStart.setNeedsLayout()
        txtFieldStart.layoutIfNeeded()
        let markerImage = UIImage(named: "blue1")!.withRenderingMode(.alwaysOriginal)
        let markerImage2 = UIImage(named: "gold1")!.withRenderingMode(.alwaysOriginal)
        setupTextField(textField: txtFieldStart, img: markerImage)
        txtFieldStart.itemSelectionHandler = { (item, position) in
            if (!self.toggleRidersBtn.isHidden) {
                self.toggleDim()
            }
            self.view.bringSubview(toFront: self.favStart)
            let name = item[position].title
            if (name == "Enter an Address") {
                self.present(self.autocompleteController, animated: true, completion: nil)
                self.setupAutocomplete()
            } else if (name == "My Location") {
                ToastManager.shared.style.activityBackgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
                ToastManager.shared.style.activityIndicatorColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
                self.view.makeToastActivity(.center)
                self.view.endEditing(true)
                self.view.isUserInteractionEnabled = false
                var currentLocation: CLLocation!
                if( CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
                    CLLocationManager.authorizationStatus() ==  .authorizedAlways){
                    if (self.location.coordinate.latitude != 0) {
                        currentLocation = self.location
                        let lat = currentLocation.coordinate.latitude
                        let long = currentLocation.coordinate.longitude
                        if (AcesConfiguration().isInACESBoundary(lat: lat, long: long)) {
                            self.getAddress(lat: lat, long: long)
                        } else {
                            let name = self.chosenPlaceStart.name
                            if (name != "") {
                                self.txtFieldStart.text = "Start: \(name)"
                                let camera = GMSCameraPosition.camera(withLatitude: self.chosenPlaceStart.lat, longitude: self.chosenPlaceStart.long, zoom: 15)
                                self.mapView.animate(to: camera)
                            }
                            self.view.hideToastActivity()
                            self.view.isUserInteractionEnabled = true
                            self.mapView.isUserInteractionEnabled = true
                            self.txtFieldEnd.isEnabled = true
                            self.view.endEditing(true)
                            self.view.makeToast("Location Out of Bounds", position: .center)
                        }
                    }
                } else {
                    self.view.hideToastActivity()
                    self.view.isUserInteractionEnabled = true
                    self.mapView.isUserInteractionEnabled = true
                    self.txtFieldEnd.isEnabled = true
                    self.view.endEditing(true)
                    self.showAlert(title: "Location Services Disabled", msg: "Please enable location services to use the 'My Location' feature")
                }
            } else {
                let lat = self.locDB.getPlaces()[name]![0]
                let long = self.locDB.getPlaces()[name]![1]
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
                if (self.favorites[self.chosenPlaceStart.name] != nil) {
                    self.setStar(name: self.chosenPlaceStart.name, v: self.favStart)
                } else {
                    self.favStart.isHidden = true
                }
            }
        }
        
        addSubviewAnchorTLRH(subView: txtFieldEnd, top: 50, left: 10, right: -10, height: 35)
        txtFieldEnd.setNeedsLayout()
        txtFieldEnd.layoutIfNeeded()
        setupTextField(textField: txtFieldEnd, img: markerImage2)
        txtFieldEnd.itemSelectionHandler = { (item, position) in
            if (!self.toggleRidersBtn.isHidden) {
                self.toggleDim()
            }
            self.view.bringSubview(toFront: self.favEnd)
            let name = item[position].title
            if (name == "Enter an Address") {
                self.present(self.autocompleteController, animated: true, completion: nil)
                self.setupAutocomplete()
            } else {
                let lat = self.locDB.getPlaces()[name]![0]
                let long = self.locDB.getPlaces()[name]![1]
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
                if (self.favorites[self.chosenPlaceEnd.name] != nil) {
                    self.setStar(name: self.chosenPlaceEnd.name, v: self.favEnd)
                } else {
                    self.favEnd.isHidden = true
                }
            }
        }
        
        addSubviewAnchorBLRH(subView: requestBtn, btm: -10, left: 10, right: -10, height: 35)
        addSubviewAnchorBLRH(subView: numRidersBtn, btm: -50, left: 10, right: -10, height: 35)
        addSubviewAnchorBLRH(subView: doorBtn, btm: -90, left: 10, right: -10, height: 35)
        self.view.addSubview(toggleRidersBtn)
        addSubviewAnchorBLRH(subView: ridersSelector, btm: -50, left: 10, right: -10, height: 115)
        addSubviewAnchorBLRH(subView: doorSelector, btm: -90, left: 10, right: -10, height: 115)
        addSubviewAnchorBLRH(subView: estWTLbl, btm: -130, left: 10, right: -10, height: 35)
    }
    
    func getAddress(lat: Double, long: Double) -> Void {
        var postalAddress = ""
        GMSGeocoder().reverseGeocodeCoordinate(CLLocationCoordinate2DMake(lat, long), completionHandler: {response,error in
            if let gmsAddress: GMSAddress = response!.firstResult(){
                for line in  gmsAddress.lines! {
                    postalAddress += line + " "
                }
                postalAddress = postalAddress.replacingOccurrences(of: ", Rock Island", with: "")
                postalAddress = postalAddress.replacingOccurrences(of: ", IL", with: "")
                postalAddress = postalAddress.replacingOccurrences(of: " 61201", with: "")
                postalAddress = postalAddress.replacingOccurrences(of: ", USA", with: "")
                postalAddress = postalAddress.replacingOccurrences(of: ".", with: "")
                if (postalAddress.lowercased() == "unnamed road ") {
                    let name = self.chosenPlaceStart.name
                    if (name != "") {
                        self.txtFieldStart.text = "Start: \(name)"
                        let camera = GMSCameraPosition.camera(withLatitude: self.chosenPlaceStart.lat, longitude: self.chosenPlaceStart.long, zoom: 15)
                        self.mapView.animate(to: camera)
                    }
                    self.view.hideToastActivity()
                    self.view.isUserInteractionEnabled = true
                    self.mapView.isUserInteractionEnabled = true
                    self.txtFieldEnd.isEnabled = true
                    self.view.endEditing(true)
                    self.view.makeToast("Unknown Location", position: .center)
                } else {
                    let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
                    self.mapView.animate(to: camera)
                    self.chosenPlaceStart = MyPlace(name: postalAddress, lat: lat, long: long)
                    self.markerStart.map = self.mapView
                    self.markerStart.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                    self.markerStart.title = "Start: \(postalAddress)"
                    self.txtFieldStart.text = "Start: \(postalAddress)"
                    self.mapView.isUserInteractionEnabled = true
                    self.txtFieldEnd.isEnabled = true
                    self.view.isUserInteractionEnabled = true
                    self.setStar(name: self.chosenPlaceStart.name, v: self.favStart)
                }
            }
            self.view.hideToastActivity()
        })
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
    
    func initToasts(endTime: String, message: String) {
        if (endTime == "Cancelled by Dispatcher") {
            if (message == "") {
                showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher.")
            } else {
                showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher:\n\(message)")
            }
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
                self.estWTLbl.text = "ACES Offline"
            } else {
                if (!self.isActivated) {
                    self.waitTimeListener()
                } else {
                    let text = "Estimated Wait Time: \(String(describing: self.estWaitTime)) minutes"
                    self.estWTLbl.text = text
                }
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
            let vehicle = postDict?["vehicle"] as? String ?? ""
            self.ride = RideInfo(email: email, end: end, endTime: endTime, eta: eta, numRiders: numRiders, start: start, time: time, waitTime: waitTime, ts: timestamp, token: appDelegate.getToken(), vehicle: vehicle)
            let nextView: RequestedRideView = RequestedRideView()
            nextView.ride = self.ride
            nextView.delegate = self
            self.present(nextView, animated: true, completion: nil)
        }; if (count == 2) {
            mapView.hideToastActivity()
            self.view.isUserInteractionEnabled = true
            txtFieldStart.isEnabled = true
            txtFieldEnd.isEnabled = true
            mapView.isUserInteractionEnabled = true
            numRidersBtn.isEnabled = true
            doorBtn.isEnabled = true
            requestBtn.isEnabled = true
        }
    }
    
    // LOCATION MANAGER
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error while getting location \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if (locations.count > 0) {
            location = locations.last ?? CLLocation(latitude: 0, longitude: 0)
        }
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
        if (pickerView == ridersSelector) {
            return riders.count
        } else {
            return doors.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView == ridersSelector) {
            return riders[row]
        } else {
            return doors[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if (pickerView == ridersSelector) {
            toggleDim()
            ridersSelector.isHidden = !ridersSelector.isHidden
            numRidersBtn.setTitle("Number of Riders: \(riders[row])", for: UIControlState.normal)
        } else {
            toggleDim()
            doorSelector.isHidden = !doorSelector.isHidden
            doorBtn.setTitle("Pick-up Door: \(doors[row])", for: UIControlState.normal)
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if (pickerView == ridersSelector) {
            let newString = NSMutableAttributedString(string: riders[row])
            newString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange (location: 0, length: newString.length))
            return newString
        } else {
            let newString = NSMutableAttributedString(string: doors[row])
            newString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.black, range: NSRange (location: 0, length: newString.length))
            return newString
        }
    }
    
    // TEXT FIELD
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if let obj = textField as? SearchTextField {
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let obj = textField as? SearchTextField {
            toggleRiders()
            return true
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let obj = textField as? SearchTextField {
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
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let obj = textField as? SearchTextField {
        if (!toggleRidersBtn.isHidden) {
            cancelEditing()
            toggleDim()
        }
        view.bringSubview(toFront: favStart)
        view.bringSubview(toFront: favEnd)
        }
    }
    
    // GMS Autocomplete
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let lat = place.coordinate.latitude
        let long = place.coordinate.longitude
        if (AcesConfiguration().isInACESBoundary(lat: lat, long: long)) {
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: long, zoom: 15)
            mapView.camera = camera
            let name = place.name.replacingOccurrences(of: ".", with: "")
            
            if (activeTextField == txtFieldStart) {
                chosenPlaceStart = MyPlace(name: name, lat: lat, long: long)
                markerStart.map = nil
                markerStart.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerStart.title = "Start: \(name)"
                markerStart.map = mapView
                activeTextField.text = "Start: \(name)"
                txtFieldEnd.isEnabled = true
                setStar(name: chosenPlaceStart.name, v: favStart)
            } else {
                chosenPlaceEnd = MyPlace(name: name, lat: lat, long: long)
                markerEnd.map = nil
                markerEnd.position = CLLocationCoordinate2D(latitude: lat, longitude: long)
                markerEnd.title = "End: \(name)"
                markerEnd.map = mapView
                activeTextField.text = "End: \(name)"
                txtFieldStart.isEnabled = true
                setStar(name: chosenPlaceEnd.name, v: favEnd)
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
        } else if (!ridersSelector.isHidden){
            ridersSelector.isHidden = !ridersSelector.isHidden
        } else {
            doorSelector.isHidden = !doorSelector.isHidden
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
                var end = chosenPlaceEnd.name
                let numRiders = riders[ridersSelector.selectedRow(inComponent: 0)]
                let door = doors[doorSelector.selectedRow(inComponent: 0)]
                var start = chosenPlaceStart.name
                let formatter = DateFormatter()
                formatter.dateFormat = "M/d/yyyy h:mm aaa"
                let time = formatter.string(from: Date())
                let ts = ServerValue.timestamp()
                let token = appDelegate.getToken()
                
                if (favorites[start] != nil) {
                    let arr = start.split(separator: "-")
                    start = arr[arr.count-1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                if (favorites[end] != nil) {
                    let arr = end.split(separator: "-")
                    end = arr[arr.count-1].trimmingCharacters(in: .whitespacesAndNewlines)
                }
                start = start + " (\(door))"

                ride = RideInfo(email: email, end: end, endTime: " ", eta: " ", numRiders: numRiders, start: start, time: time, waitTime: "1000", ts: ts, token: token, vehicle: " ")
                let user = self.ref.child("PENDING RIDES").child(email)
                ref.child(email).setValue(ServerValue.timestamp())
                ref.child(email).observeSingleEvent(of: .value, with: {(snapshot) in
                    let df = DateFormatter()
                    df.dateFormat = "dd-MM-yyyy hh:mm aa"
                    print(snapshot.value as? Double ?? 0)
                    df.timeZone = TimeZone(abbreviation: "CST6CDT")
                    let time = snapshot.value as? Double ?? 0
                    let date = Date(timeIntervalSince1970: time/1000)
                    print(date)
                    let stringDate = df.string(from: date)
                    print(stringDate)
                    self.ride.setTime(time: stringDate)
                    user.setValue(["door": door, "email": email, "end": end, "endTime": " ", "eta": " ", "numRiders": numRiders, "start": start, "time": stringDate, "waitTime": "1000", "timestamp": ts, "token": token, "vehicle": " "])
                    self.ref.child(email).removeValue()
                })
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
        toggleDim()
        ridersSelector.isHidden = !ridersSelector.isHidden
        view.bringSubview(toFront: toggleRidersBtn)
        view.bringSubview(toFront: ridersSelector)
    }
    
    @objc func doorAction() {
        toggleDim()
        doorSelector.isHidden = !doorSelector.isHidden
        view.bringSubview(toFront: toggleRidersBtn)
        view.bringSubview(toFront: doorSelector)
    }
    
    func setRide(ride: RideInfo, message: String) {
        txtFieldStart.text = ""
        txtFieldEnd.text = ""
        favStart.isHidden = true
        favEnd.isHidden = true
        chosenPlaceStart = MyPlace(name: "", lat: 0, long: 0)
        chosenPlaceEnd = MyPlace(name: "", lat: 0, long: 0)
        numRidersBtn.setTitle("Number of Riders: 1", for: UIControlState.normal)
        ridersSelector.selectRow(0, inComponent: 0, animated: false)
        doorBtn.setTitle("Pick-up Door: Front", for: UIControlState.normal)
        doorSelector.selectRow(0, inComponent: 0, animated: false)
        initToasts(endTime: ride.getEndTime(), message: message)
        self.ride = RideInfo(email: "",end: "",endTime: "",eta: "",numRiders: "",start: "",time: "",waitTime: "",ts: 0,token: "",vehicle: "")
        self.mapView.clear()
        let camera = GMSCameraPosition.camera(withLatitude: 41.505199, longitude: -90.550674, zoom: 15)
        self.mapView.camera = camera
    }
    
    func setStar(name: String, v: UIImageView) {
        view.bringSubview(toFront: v)
        v.isHidden = false
        if (favorites[name] == nil) {
            let path = Bundle.main.path(forResource: "btn_star_big_off", ofType: "png", inDirectory: "Images")
            v.image = UIImage(named: path!)
        } else {
            let path = Bundle.main.path(forResource: "btn_star_big_on", ofType: "png", inDirectory: "Images")
            v.image = UIImage(named: path!)
        }
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
                    let reason = postDict?["message"] as? String ?? ""
                    if (reason == "") {
                        self.showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher.")
                    } else {
                        self.showAlert(title: "Ride Cancelled", msg: "Requested ride cancelled by dispatcher:\n\(reason)")
                    }
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
    
    func addFavoriteToDropDownAndDatabase(name: String, lat: Double, long: Double) {
        locDB.addLocation(name: name, lat: lat, lng: long)
        updateDropDown()
    }
    
    func removeFavoriteFromDropDownAndDatabase(name: String) {
        locDB.removeLocation(name: name)
        updateDropDown()
    }
    
    func getFavorites() {
        let preferences = UserDefaults.standard
        let favs = preferences.string(forKey: "favorites") ?? "none"
        let places = favs.split(separator: ",")
        if (favs != "none") {
            for place in places {
                let arr = place.split(separator: ":")
                if (arr.count == 3) {
                    favorites[String(arr[0])] = [Double(arr[1]), Double(arr[2])] as? [Double]
                    print("Loaded: \(arr[0])")
                }
            }
        }
    }
    
    func saveFavorites() {
        let preferences = UserDefaults.standard
        if (favorites.capacity > 0) {
            var builder = ""
            for (key, value) in favorites {
                builder.append("\(key):\(value[0]):\(value[1]),")
            }
            print("saved: \(builder)")
            preferences.set(builder, forKey: "favorites")
        } else {
            preferences.set("none", forKey: "favorites")
        }
        preferences.synchronize()
    }
    
}

extension Date {
    func toMillis() -> CLong {
        return CLong(self.timeIntervalSince1970 * 1000)
    }
}

