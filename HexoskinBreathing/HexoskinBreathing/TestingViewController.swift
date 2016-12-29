//
//  TestingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//


import UIKit

class TestingViewController: UIViewController {
    
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!
    
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var responseLabel: UITextView!
    
    var tokenType: String!
    var accessToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseLabel.text = "";
    }
    
    @IBAction func sendRequest(_ sender: AnyObject) {
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/data/", query: ["datatype__in" : "37", "record" : "110676"], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
        // make the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {                                                 // check for fundamental networking error
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
                print("statusCode should be 200, but is \(httpStatus.statusCode)")
                print("response = \(response)")
            }
            
            do {
                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any];
                if dataDictionary == nil {
                    let dataArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any];
                    DispatchQueue.main.async {
                        self.responseLabel.text = dataArray?.description;
                        self.responseLabel.textColor = .red;
                        self.responseLabel.backgroundColor = .black;
                    }
                } else {
                    DispatchQueue.main.async {
                        self.responseLabel.text = dataDictionary?.description;
                        self.responseLabel.textColor = .red;
                        self.responseLabel.backgroundColor = .black;
                        
                        // extract the data from the data dictionary
                        
                    }
                }
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }
    
}
