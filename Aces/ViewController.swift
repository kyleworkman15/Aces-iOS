//
//  ViewController.swift
//  Aces
//
//  Description: Initial View/View Controller with the Google sign-in button, Augustana Aces Logo,
//  and button to access the About Page.
//
//  Created by Kyle Workman on 6/14/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMaps
import Toast_Swift
import SearchTextField
import SpriteKit

// Methods for constructing elements based on application's style
func constructTitleLbl(text: String, txtColor: UIColor, bkdColor: UIColor) -> UILabel{
    let lbl = UILabel()
    lbl.text = text
    lbl.font = UIFont.boldSystemFont(ofSize: 30)
    lbl.textColor = txtColor
    lbl.backgroundColor = bkdColor
    lbl.textAlignment = .center
    lbl.translatesAutoresizingMaskIntoConstraints=false
    lbl.numberOfLines = 0
    return lbl
}

func constructBtn(text: String, color: UIColor) -> UIButton{
    let btn = UIButton()
    btn.backgroundColor = color
    btn.layer.borderColor = UIColor.darkGray.cgColor
    btn.setTitle(text, for: UIControlState.normal)
    btn.setTitleColor(.black, for: UIControlState.normal)
    btn.translatesAutoresizingMaskIntoConstraints=false
    return btn
}

func constructLbl(text: String) -> UILabel {
    let lbl = UILabel()
    lbl.text = text
    lbl.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    lbl.textAlignment = .center
    lbl.translatesAutoresizingMaskIntoConstraints=false
    lbl.numberOfLines = 0
    guard let customFont = UIFont(name: "Animo-Light", size: 22) else {
        fatalError("""
        Failed to load the "animo_light.ttf" font.
        """
        )
    }
    lbl.font = customFont
    lbl.adjustsFontSizeToFitWidth = true
    return lbl
}

func constructSearchFld(text: String) -> SearchTextField {
    let tf = SearchTextField()
    tf.borderStyle = .roundedRect
    tf.backgroundColor = .white
    tf.layer.borderColor = UIColor.darkGray.cgColor
    tf.placeholder = text
    tf.isEnabled = false
    tf.comparisonOptions = [.caseInsensitive, .anchored]
    tf.theme.font = UIFont.systemFont(ofSize: 18)
    tf.theme.cellHeight = 35
    tf.theme.separatorColor = .lightGray
    tf.highlightAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)]
    tf.theme.bgColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
    tf.translatesAutoresizingMaskIntoConstraints=false
    return tf
}

func constructLogo(path: String) -> UIImageView {
    let acesLogo = path
    let acesPath = Bundle.main.path(forResource: acesLogo, ofType: "png", inDirectory: "Images")
    let image = UIImage(named: acesPath!)
    let imageView = UIImageView(image: image)
    return imageView
}

class ViewController: UIViewController, GIDSignInUIDelegate {
    
    // Button for transitioning to the About Page
    let aboutBtn: UIButton = constructBtn(text: "?", color: .lightGray)

    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        aboutBtn.addTarget(self, action: #selector(aboutAction), for: .touchUpInside)
        let screenSize = UIScreen.main.bounds
        
        addGoogleBtn()
        let title = constructLogo(path: "aces_title")
        title.translatesAutoresizingMaskIntoConstraints = false
        addSubviewAnchorTLRH(subView: title, top: screenSize.height/15, left: 20, right: -20, height: 15*screenSize.height/100)
        addSubviewAnchorBRWH(subView: aboutBtn, btm: -110, right: -20, width: 40, height: 40)
        let width = screenSize.width
        let height = screenSize.height
        let logo = constructLogo(path: "aces_image")
        logo.frame = CGRect(x: (width/2)-(5*width/8/2), y: (height/2)-(5*width/8/2), width: 5*width/8, height: 5*width/8)
        view.addSubview(logo)
    }
    
    // Construct and add the Google sign in button to the view
    func addGoogleBtn() {
        let googleButton = GIDSignInButton()
        googleButton.translatesAutoresizingMaskIntoConstraints=false
        googleButton.addTarget(self, action: #selector(loginAction), for: .touchUpInside)
        addSubviewAnchorBRWH(subView: googleButton, btm: -50, right: -10, width: view.frame.width - 20, height: 35)
        view.addSubview(googleButton)
        GIDSignIn.sharedInstance().uiDelegate = self
  
        let privacyLink = UILabel()
        privacyLink.attributedText = NSAttributedString(string: "By signing in, you agree to our Privacy Policy", attributes:[.underlineStyle: NSUnderlineStyle.styleSingle.rawValue])
        privacyLink.textColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        privacyLink.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        privacyLink.textAlignment = .center
        privacyLink.translatesAutoresizingMaskIntoConstraints=false
        privacyLink.numberOfLines = 0
        privacyLink.isUserInteractionEnabled = true
        privacyLink.adjustsFontSizeToFitWidth = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.tapFunction))
        privacyLink.addGestureRecognizer(tap)
        addSubviewAnchorBRWH(subView: privacyLink, btm: -20, right: 0, width: view.frame.width, height: 20)
    }
    
    @objc
    func tapFunction(sender:UITapGestureRecognizer) {
        self.present(PrivacyView(), animated: true, completion: nil)
    }
    
    // Add and anchor (to the top, left, right, height) a subview with the given constraints to the view
    func addSubviewAnchorTLRH(subView: UIView, top: CGFloat, left: CGFloat, right: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }
    
    // Add and anchor (to the bottom, right, width, height) a subview with the given constraints to the view
    func addSubviewAnchorBRWH(subView: UIView, btm: CGFloat, right: CGFloat, width: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.widthAnchor.constraint(equalToConstant: width).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }
    
    // Handles the action for the aboutBtn
    @objc func aboutAction() {
        let nextView: AboutView = AboutView()
        self.present(nextView, animated: true, completion: nil)
    }
    
    // Handles the action for the loginBtn, shows activity spinner
    @objc func loginAction() {
        ToastManager.shared.style.activityBackgroundColor = UIColor.init(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.9)
        ToastManager.shared.style.activityIndicatorColor = UIColor.init(red: 0/255, green: 0/255, blue: 0/255, alpha: 1.0)
        self.view.makeToastActivity(.center)
        self.view.isUserInteractionEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
