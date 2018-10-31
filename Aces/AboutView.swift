//
//  AboutView.swift
//  Aces
//
//  Description: View/View Controller for the About Page.
//
//  Created by Kyle Workman on 6/16/18.
//  Copyright © 2018 Kyle Workman. All rights reserved.
//

import Foundation
import UIKit

class AboutView: UIViewController, UITextViewDelegate {
    
    // Text View for displaying the About Page
    let textView: UITextView = {
        let view = UITextView()
        view.textColor = .black
        view.backgroundColor = .white
        view.translatesAutoresizingMaskIntoConstraints=false
        return view
    }()
    
    // Button for returning to the Sign-in Page
    let backBtn: UIButton = constructBtn(text: "Return", color: .white)
    
    // View did load
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(red: 32/255, green: 85/255, blue: 138/255, alpha: 1)
        backBtn.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        
        displayText()
        addSubviewAnchorTLRB(subView: textView, top: 10, left: 10, right: -10, btm: -50)
        addSubviewAnchorBLRH(subView: backBtn, btm: -10, left: 10, right: -10, height: 35)
    }
    
    // Construct the text for the About Page
    func displayText() {
        let linkAttributes: [NSAttributedStringKey: Any] = [
            .link: NSURL(string: "mailto:\("acesdispatcher@augustana.edu")")!,
            .foregroundColor: UIColor.blue
        ]
        let attributedString = NSMutableAttributedString(string: "Augustana College Express Service (ACES)\n\nPlease email any problems, bugs, or suggestions here! Thanks!\n\nPurpose:\nTo provide safe transportation around campus for students. We strive to make ACES a fun and safe option to get across campus, most importantly to prevent students from walking alone at night.\n\nHours:\nFall Term: 7pm - 2am\nWinter Term: 6pm - 2am\nSpring Term: 7pm - 2am\n\nPhone:\n309-794-7550\n\nCredit:\nACES Logo: Courtesy of ACES\n\nDev:\nKyle Workman")
        attributedString.setAttributes(linkAttributes, range: NSMakeRange(90, 4))
        self.textView.delegate = self
        self.textView.attributedText = attributedString
        self.textView.isUserInteractionEnabled = true
        self.textView.isEditable = false
        self.textView.font = .systemFont(ofSize: 18)
    }
    
    // Add and anchor (to the top, left, right, bottom) a subview with the given constraints to the view
    func addSubviewAnchorTLRB(subView: UIView, top: CGFloat, left: CGFloat, right: CGFloat, btm: CGFloat) {
        view.addSubview(subView)
        subView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: top).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
    }
    
    // Add and anchor (to the bottom, left, right, height) a subview with the given constraints to the view
    func addSubviewAnchorBLRH(subView: UIView, btm: CGFloat, left: CGFloat, right: CGFloat, height: CGFloat) {
        view.addSubview(subView)
        subView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: btm).isActive=true
        subView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: left).isActive=true
        subView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right).isActive=true
        subView.heightAnchor.constraint(equalToConstant: height).isActive=true
    }
    
    // Ensures the About Page starts at the top
    override func viewDidLayoutSubviews() {
        self.textView.setContentOffset(.zero, animated: false)
    }
    
    // Handles the action for the backBtn, returns to Login Page
    @objc func backAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}
