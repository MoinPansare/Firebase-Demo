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
import GoogleSignIn

class ViewController: UIViewController,FBSDKLoginButtonDelegate,GIDSignInUIDelegate,GIDSignInDelegate {

    var facebookLoginButton : FBSDKLoginButton?;
    var googleLoginButton : GIDSignInButton?;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addFacebookButton();
        addGoogleLoginButton();
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func addFacebookButton(){
        facebookLoginButton = FBSDKLoginButton();
        facebookLoginButton?.frame = CGRect(x: 16, y: 50, width: self.view.frame.size.width - 32, height: 50);
        facebookLoginButton?.delegate = self;
        facebookLoginButton?.readPermissions = ["public_profile", "email"];
        self.view.addSubview(facebookLoginButton!);
    }
    
    func addGoogleLoginButton(){
        googleLoginButton = GIDSignInButton();
        googleLoginButton?.frame = CGRect(x: 16, y: 116, width: self.view.frame.size.width - 32, height: 50)
        self.view.addSubview(googleLoginButton!);
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self

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
                self.addFaceBookUserToFirebase();
            }
            else
            {
                print("error \(error)")
            }
        })
        
        
    }
    
    func addFaceBookUserToFirebase(){
        let accessToken : String = FBSDKAccessToken.current().tokenString!;
        let credentials = FIRFacebookAuthProvider.credential(withAccessToken: accessToken);
        FIRAuth.auth()?.signIn(with: credentials, completion: { (user, error) in
            if error == nil{
                print("Something went wrong in adding user Facebook User to firebase : \(error)")
                return;
            }
            print("Successgully added Facebook User to Firebase DataSet");
        })
    }
    
    
    //MARK: - Google Login Stuff
    
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    // Present a view that prompts the user to sign in with Google
    
    func sign(_ signIn: GIDSignIn!,
              present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
    
    // Dismiss the "Sign in with Google" view
    func sign(_ signIn: GIDSignIn!,
              dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        // ...
        if let error = error {
            print("Some Error in Google SIgn In \(error)");
            return
        }
        
        guard let authentication = user.authentication else { return }
        let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            // ...
            if let error = error {
                print("Some Error in Adding Google User To Firebase DataSet \(error)");
                return;
            }
            print("Successgully added Google User to Firebase DataSet");
        }
        
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
                withError error: Error!) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

