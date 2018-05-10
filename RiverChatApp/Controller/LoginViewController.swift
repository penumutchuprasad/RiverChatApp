//
//  LoginViewController.swift
//  RiverChatApp
//
//  Created by penumutchu.prasad@gmail.com on 04/05/18.
//  Copyright © 2018 abnboys. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth
import FirebaseDatabase


class LoginViewController: UIViewController, GIDSignInUIDelegate, GIDSignInDelegate {
    
    
    
    @IBOutlet var loginFreeBtn: UIButton!
    @IBOutlet var googleBtn: UIButton!
    
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        makeButtonsAppearance()
        
        GIDSignIn.sharedInstance().clientID = "74973411009-qcbjcr7hgs76dhpbuhl9c54d57ktjk85.apps.googleusercontent.com"
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            
            if user != nil {
                
                self.navigateToChatVC()

            } else {
                
                print("Not Authorized.......")
            }
        }
    }
    
    private func makeButtonsAppearance() {
        
        loginFreeBtn.layer.borderColor = UIColor.white.cgColor
        loginFreeBtn.layer.borderWidth = 2.0
        
        googleBtn.layer.cornerRadius = googleBtn.frame.width/2
        googleBtn.layer.masksToBounds = true
        googleBtn.layer.shadowOffset = CGSize(width: 1.5, height: 1.8)
        googleBtn.layer.shadowColor = UIColor.red.cgColor
        
        
    }
    

    @IBAction func onLoginBtn_TouchUPInside(_ sender: UIButton) {
        
        MyAppAuth.shared.loginAnonymously(sender: sender) {
            
            self.navigateToChatVC()
        }
        
    }

    
    @IBAction func onGoogleBtn_TouchUpInside(_ sender: UIButton) {
        
        GIDSignIn.sharedInstance().signIn()
        
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        
        if error != nil {
            return
        }
        
        guard let authentication = user.authentication else { return }
        MyAppAuth.shared.loginWithGoogle(authentication: authentication) {
            //
            self.navigateToChatVC()
        }
    }
    
    
    
    func navigateToChatVC() {
        if let navVC = self.storyboard?.instantiateViewController(withIdentifier: "NavigaionVC") as? UINavigationController {
            
            self.present(navVC, animated: true, completion: nil)
        }
    }

}

