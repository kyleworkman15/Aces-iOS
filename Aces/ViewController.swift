//
//  ViewController.swift
//  Aces
//
//  Created by checkout-7 on 6/14/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    let txtLabel1: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.center
        lbl.font = UIFont.boldSystemFont(ofSize: 30)
        lbl.textColor = .blue
        lbl.text = "Augustana College"
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()
    
    let txtLabel2: UILabel = {
        let lbl = UILabel()
        lbl.textAlignment = NSTextAlignment.center
        lbl.font = UIFont.boldSystemFont(ofSize: 30)
        lbl.textColor = .blue
        lbl.text = "Express Service"
        lbl.translatesAutoresizingMaskIntoConstraints=false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Add google button
        let googleButton = GIDSignInButton()
        googleButton.frame = CGRect(x: 16, y: view.frame.maxY - 100, width: view.frame.width - 32, height: 50)
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
        view.backgroundColor = UIColor.yellow
        
        view.addSubview(txtLabel1)
        txtLabel1.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50).isActive=true
        txtLabel1.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtLabel1.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtLabel1.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        view.addSubview(txtLabel2)
        txtLabel2.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 95).isActive=true
        txtLabel2.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive=true
        txtLabel2.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -10).isActive=true
        txtLabel2.heightAnchor.constraint(equalToConstant: 40).isActive=true
        
        let acesLogo = "aces_image.png"
        let image = UIImage(named: acesLogo)
        let imageView = UIImageView(image: image)
        view.addSubview(imageView)
        let width: CGFloat = 250
        let height: CGFloat = 250
        let screenSize = UIScreen.main.bounds
        imageView.frame = CGRect(x:(screenSize.width/2)-(width/2), y:(screenSize.height/2)-(height/2), width:width, height:height)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
