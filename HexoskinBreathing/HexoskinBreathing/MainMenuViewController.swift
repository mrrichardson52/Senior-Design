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

    override func viewDidLoad() {
        super.viewDidLoad()

        // add an observer to receive the message when the app is opened via deep linking
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(MainMenuViewController.notificationReceived(notification:)),
            name: NSNotification.Name(rawValue: "token received"),
            object: nil)
        
    }
    
    func notificationReceived(notification: Notification) {
        let info = notification.userInfo as! [String : String];
        accessToken = info["access_token"]!;
        tokenType = info["token_type"]!;
        
        // update the interface to indicate that the user is signed in
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "testingSegue" {
            if accessToken == nil || tokenType == nil {
                print("unauthorized. please sign in."); 
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
        }
    }


}
