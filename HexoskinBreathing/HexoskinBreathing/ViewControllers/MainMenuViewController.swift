//
//  MainMenuViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class MainMenuViewController: MRRViewController {
    
    var accessToken: String!
    var tokenType: String!
    var signedIn: Bool = false;

    @IBOutlet weak var accountConnectedLabel: UILabel!
    @IBOutlet weak var signedInButton: UIButton!
    @IBOutlet weak var performExerciseButton: UIButton!
    @IBOutlet weak var signInDividerView: UIView!
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var breathingBuddyTitleLabel: UILabel!
    @IBOutlet weak var topBorderView: UIView!
    @IBOutlet weak var bottomBorderView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up the perform exercise button
        performExerciseButton.setTitleColor(Constants.electricBlue, for: .normal);
        performExerciseButton.backgroundColor = UIColor.clear;
        performExerciseButton.layer.cornerRadius = 8;
        
        // set up the divider view
//        signInDividerView.backgroundColor = Constants.brownish;
        signInDividerView.backgroundColor = .clear;
        
        // set up the welcome label
        welcomeLabel.textColor = Constants.basicTextColor;
        signedInButton.setTitleColor(Constants.electricBlue, for: .normal);
        signedInButton.backgroundColor = .clear;
        signedInButton.layer.cornerRadius = 5;

        // add an observer to receive the message when the app is opened via deep linking
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MainMenuViewController.notificationReceived(notification:)),
            name: NSNotification.Name(rawValue: "token received"),
            object: nil)
        
        // attempt to authorize user automatically
        authorizeUser();
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // hide the navigation bar
        self.hideNavigationBar();
        
        // configure the title view
        breathingBuddyTitleLabel.text = "Breathing\nBuddy"; 
        breathingBuddyTitleLabel.textColor = Constants.basicTextColor;
        breathingBuddyTitleLabel.backgroundColor = .clear;
        topBorderView.backgroundColor = Constants.electricBlue;
        bottomBorderView.backgroundColor = Constants.electricBlue; 
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
    
    @IBAction func performExerciseButtonPressed(_ sender: Any) {
        // check if signed
        if !signedIn {
            
            // indicate unauthorized
            let alert = UIAlertController(title: "Not signed in", message: "Hexoskin data is only accessible when signed in.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Sign in", style: .default, handler: {
                _ in
                DispatchQueue.main.async {
                    // push the authorization view controller to begin sign in process
                    self.pushAuthorizationViewController();
                }
            }));
            alert.addAction(UIAlertAction(title: "Continue without signing in", style: .default, handler: {
                _ in
                DispatchQueue.main.async {
                    // continue without signing in
                    self.pushExerciseDesignerViewController(signedIn: false);
                }
            }));
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil));
            self.present(alert, animated: true, completion: nil);
            
        } else {
            
            //push the exercise design controller
            pushExerciseDesignerViewController(signedIn: true);
        }
    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        if signedIn {
            // sign out
            self.indicateNotSignedIn();
        } else {
            self.pushAuthorizationViewController();
        }
    }
    
    func pushExerciseDesignerViewController(signedIn: Bool) {
        // instantiate the view controller from interface builder
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "exerciseDesignerViewController") as? ExerciseDesignerViewController;
        
        // set the authorization details and exercise members for the exercise view controller
        viewController?.accessToken = accessToken;
        viewController?.tokenType = tokenType;
        // also indicate whether signed in or not
        viewController?.signedIn = signedIn;
        self.navigationController?.pushViewController(viewController!, animated: true);
    }

    func pushAuthorizationViewController() {
        // instantiate the view controller from interface builder
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "authorizationViewController") as? AuthorizationViewController;
        self.navigationController?.pushViewController(viewController!, animated: true);
    }

}
