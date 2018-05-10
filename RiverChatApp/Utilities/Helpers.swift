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
import FirebaseDatabase

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
//            print(uid)
            
            let newUser = Database.database().reference().child("users")
            
            let newDict = ["displayName" : "Anonymous User", "id" : "\(String(describing: uid))", "profileURL" : "aaa"]
            
            newUser.setValue(newDict)
            
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
                
//                print(user?.email)
//                print(user?.displayName)
//                print(user?.photoURL)
                guard let user = user else {return}

                let newUser = Database.database().reference().child("Users").child((user.uid))

                let newDict = ["displayName" : "\(String(describing: user.displayName!))", "id": "\(String(describing: user.uid))", "profileURL": "\(String(describing:  user.photoURL!))"]
                
                newUser.setValue(newDict)
                completion()
                
            }
            
        }
    }
    
    
}
