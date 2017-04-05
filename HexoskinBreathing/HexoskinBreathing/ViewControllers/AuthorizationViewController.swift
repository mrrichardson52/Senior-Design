//
//  AuthorizationViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class AuthorizationViewController: MRRViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var loginParentView: UIView!
    @IBOutlet weak var clientIdTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var instructionLabel: UILabel!
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sign In";
        self.addBackButton()
        
        clientIdTextField.delegate = self;
        let tapRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(AuthorizationViewController.dismissKeyboard));
        view.addGestureRecognizer(tapRecognizer);
        clientId = "LUXOh5X5mc3B4lT1jQLTZU6lkA08Ha";
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.showNavigationBar();
        prepareSubviews();
    }
    
    func prepareSubviews() {
        loginParentView.backgroundColor = Constants.darkViewBackground;
        loginParentView.layer.cornerRadius = 8;
        nextButton.layer.cornerRadius = 8;
        nextButton.backgroundColor = .clear;
        nextButton.setTitleColor(Constants.basicTextColor, for: .normal);
        clientIdTextField.backgroundColor = Constants.basicTextColor;
        clientIdTextField.textColor = .black;
        clientIdTextField.text = "Default Account";
        instructionLabel.textColor = Constants.basicTextColor;
        instructionLabel.backgroundColor = .clear;
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
