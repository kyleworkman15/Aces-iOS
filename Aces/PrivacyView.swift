//
//  PrivacyView.swift
//  Aces
//
//  Created by Bryan Haage on 8/31/18.
//  Copyright © 2018 checkout-7. All rights reserved.
//

import Foundation
import UIKit
import WebKit

class PrivacyView: UIViewController, UIWebViewDelegate {
    
    var webView: UIWebView!
    
    override func loadView() {
        let screenSize = UIScreen.main.bounds
        webView = UIWebView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        webView.delegate = self
        view = webView
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let closeBtn = UIButton()
        closeBtn.frame = CGRect(x: self.view.frame.width - 55, y: 40, width: 30, height: 30)
        closeBtn.setTitle("X", for: .normal)
        closeBtn.backgroundColor = .gray
        closeBtn.addTarget(self, action: #selector(PrivacyView.backAction(_:)), for: UIControlEvents.touchUpInside)
        webView.addSubview(closeBtn)
        webView.bringSubview(toFront: closeBtn)
        
        webView.loadRequest(URLRequest(url: URL(string: "https://augustana-aces.firebaseapp.com/privacy_policy.html")!))
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(screenEdgeSwiped))
        edgePan.edges = .left
        view.addGestureRecognizer(edgePan)
    }
    
    @objc
    func backAction(_ sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func screenEdgeSwiped(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        if recognizer.state == .recognized {
            self.dismiss(animated: true, completion: nil)
        }
    }
}
