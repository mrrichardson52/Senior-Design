//
//  HomeViewController.swift
//  Breathing Data Viewer
//
//  Created by Matthew Richardson on 11/2/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var clientIdTextField: UITextField!
    @IBOutlet weak var clientSecretTextField: UITextField!
    @IBOutlet weak var clientIdNumberTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Breathing Coach Login"; 

        clientIdTextField.delegate = self;
        clientSecretTextField.delegate = self;
        clientIdNumberTextField.delegate = self;
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.dismissKeyboard));
        view.addGestureRecognizer(tapRecognizer);
        clientId = "LUXOh5X5mc3B4lT1jQLTZU6lkA08Ha";
        clientSecret = "tjmKcDGUXxOFHVkaizvdpKkyFkN5tD";
        clientIdNumber = "281"; 
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == clientIdTextField {
            clientId = textField.text;
        } else if textField == clientSecretTextField {
            clientSecret = textField.text;
        } else if textField == clientIdNumberTextField {
            clientIdNumber = textField.text;
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        clientIdTextField.resignFirstResponder();
        
        return true;
    }
    
    func dismissKeyboard() {
        view.endEditing(true);
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "testingSegue" {
            let destination = segue.destination as! TestingViewController;
            destination.clientId = clientId;
            destination.clientSecret = clientSecret;
            destination.clientIdNumber = clientIdNumber;
        }
    }
}
