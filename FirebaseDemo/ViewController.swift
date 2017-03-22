//
//  ViewController.swift
//  FirebaseDemo
//
//  Created by Moin on 22/03/17.
//  Copyright © 2017 Qaagility. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase
import FirebaseAuth

class ViewController: UIViewController,FBSDKLoginButtonDelegate {

    var facebookLoginButton : FBSDKLoginButton?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton = FBSDKLoginButton();
        facebookLoginButton?.frame = CGRect(x: 16, y: 30, width: self.view.frame.size.width - 32, height: 50);
        facebookLoginButton?.delegate = self;
        facebookLoginButton?.readPermissions = ["public_profile", "email"];
        self.view.addSubview(facebookLoginButton!);
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        print("logged out of facebook");
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            print("Error in loggin in from facebook");
            return;
        }
        
        print("Facebook Login Successful...");
        
        
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"email,name"], httpMethod: "GET").start(completionHandler: {
            (connection, result, error) in
            if(error == nil)
            {
                print("result \(result)")
                let info = result as! Dictionary<String,Any>;
                print("Emial : \(info["email"])");
                self.addUserToFirebase();
            }
            else
            {
                print("error \(error)")
            }
        })
        
        
    }
    
    func addUserToFirebase(){
        let accessToken : String = FBSDKAccessToken.current().tokenString!;
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken);
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error == nil{
                print("Something went wrong in adding user Facebook User to firebase : \(error)")
            }
            print("Successgully added Facebook User to Firebase DataSet");
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

