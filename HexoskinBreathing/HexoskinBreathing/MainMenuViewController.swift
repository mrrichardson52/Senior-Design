//
//  MainMenuViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class MainMenuViewController: UIViewController {
    
    var accessToken: String!
    var tokenType: String!
    var signedIn: Bool = false;

    @IBOutlet weak var accountConnectedLabel: UILabel!
    @IBOutlet weak var signedInButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // add an observer to receive the message when the app is opened via deep linking
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MainMenuViewController.notificationReceived(notification:)),
            name: NSNotification.Name(rawValue: "token received"),
            object: nil)
        
        // attempt to authorize user automatically
        authorizeUser();
    }
    
    func authorizeUser() {

        // check user defaults for the access token and type
        let defaults = UserDefaults.standard;
        
        accessToken = defaults.string(forKey: "access_token");
        tokenType = defaults.string(forKey: "token_type");
        
        if accessToken != nil && tokenType != nil {
            // they exist, so check if valid
            
            // construct the request
            let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/account/", query: [:], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
            
            // make the request
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print("error=\(error)")
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode == 401 {           // check for http errors
                    print("Token is invalid.");
                    
                    DispatchQueue.main.async {
                        self.indicateNotSignedIn();
                    }
                    
                } else {
                    print("Token is valid.");
                    
                    // grab the first name of the user's account
                    do {
                        let dataDictionary = try JSONSerialization.jsonObject(with: data) as? [String:Any];
//                        print("printing keys...");
//                        for key in (dataDictionary?.keys)! {
//                            print("\(key)");
//                        }
                        let objectsArray = dataDictionary?["objects"] as? [Any];
                        let objectsDictionary = objectsArray?[0] as? [String:Any];
                        let firstName = objectsDictionary?["first_name"] as? String;
                        
                        DispatchQueue.main.async {
                            self.indicateSignedIn(name: firstName!);
                        }
                        
                    } catch {
                        print("CASTING ERROR"); 
                    }
                }
            }
            task.resume()

        } else {
            // access tokens have not been stored, so the user needs to sign in
            // indicate not signed in
            self.indicateNotSignedIn();
        }
    }
    
    func indicateSignedIn(name: String) {
        print("Indicate signed in.");
        
        accountConnectedLabel.text = "Welcome \(name)";
        signedInButton.setTitle("Sign out", for: .normal);
        
        self.view.setNeedsLayout();
        
        signedIn = true;
        
        print("End of function.");
    }
    
    func indicateNotSignedIn() {
        print("Indicate not signed in.")
        
        // clear the defaults
        let defaults = UserDefaults.standard;
        defaults.setValue(nil, forKey: "access_token");
        defaults.setValue(nil, forKey: "token_type");
        defaults.synchronize();
        
        accountConnectedLabel.text = "Hexoskin account not connected";
        signedInButton.setTitle("Sign in", for: .normal);
        
        self.view.setNeedsLayout();
        
        signedIn = false;
        
        print("End of function."); 
    }
    
    func notificationReceived(notification: Notification) {
        let info = notification.userInfo as! [String : String];
        accessToken = info["access_token"]!;
        tokenType = info["token_type"]!;
        
        // store the access token and token type in user defaults
        let defaults = UserDefaults.standard;
        defaults.setValue(accessToken, forKey: "access_token")
        defaults.setValue(tokenType, forKey: "token_type")
        defaults.synchronize()
        
        // update the interface to indicate that the user is signed in
        authorizeUser();
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "testingSegue" || identifier == "performExerciseSegue" {
            if !signedIn {
                print("unauthorized. please sign in."); 
                return false;
            }
        }
        if identifier == "loginSegue" {
            if signedIn {
                // sign out
                indicateNotSignedIn();
                return false;
            }
        }
        return true;

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "testingSegue" {
            let destination = segue.destination as! TestingViewController;
            destination.accessToken = accessToken;
            destination.tokenType = tokenType;
        } else if segue.identifier == "performExerciseSegue" {
            let destination = segue.destination as! ExerciseViewController;
            destination.accessToken = accessToken;
            destination.tokenType = tokenType;
        }
    }


}
