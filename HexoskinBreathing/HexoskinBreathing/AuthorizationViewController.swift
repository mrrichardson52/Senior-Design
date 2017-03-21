//
//  AuthorizationViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class AuthorizationViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var clientIdTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Breathing Coach Login";
        
        clientIdTextField.delegate = self;
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard));
        view.addGestureRecognizer(tapRecognizer);
        clientId = "LUXOh5X5mc3B4lT1jQLTZU6lkA08Ha";
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        clientId = textField.text;
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clientIdTextField.resignFirstResponder();
        
        return true;
    }
    
    func dismissKeyboard() {
        view.endEditing(true);
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        _ = navigationController?.popViewController(animated: false);
        ApiHelper.authorizeUser(clientId: clientId);
    }

}
