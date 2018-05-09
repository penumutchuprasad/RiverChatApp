//
//  Helpers.swift
//  RiverChatApp
//
//  Created by penumutchu.prasad@gmail.com on 05/05/18.
//  Copyright © 2018 abnboys. All rights reserved.
//

import UIKit
import FirebaseAuth
import GoogleSignIn

class MyAppAuth {
    
    static let shared = MyAppAuth()
    
    
    func loginAnonymously(sender: UIButton, completion: @escaping ()->()) {
        
        Auth.auth().signInAnonymously { (user, err) in
            if err != nil {
                return
            }
            
            guard let user = user else { return }
            
            let isAnonymous = user.isAnonymous  // true
            let uid = user.uid
            
            print(isAnonymous)
            print(uid)
            completion()
            
        }
        
    }
    
    func loginWithGoogle(authentication: GIDAuthentication, completion: @escaping ()->()) {
        
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                       accessToken: authentication.accessToken)
        
        
        Auth.auth().signIn(with: credential) { (user, err) in
            
            if err != nil {
                
                return
            }else {
                //Success...
                
                print(user?.email)
                print(user?.displayName)
                
                completion()
                
            }
            
        }
    }
    
    
}
