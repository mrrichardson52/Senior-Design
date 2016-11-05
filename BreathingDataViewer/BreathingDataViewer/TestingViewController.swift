//
//  TestingViewController.swift
//  Breathing Data Viewer
//
//  Created by Matthew Richardson on 11/2/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class TestingViewController: UIViewController {
    
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!

    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var getTokenButton: UIButton!
    @IBOutlet weak var responseLabel: UILabel!
    
    var accessTokenTEMPORARY : String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessTokenTEMPORARY = "CRWo74oidkhwYvhZKx6SIYAJfNm6CB";
    }

    @IBAction func sendRequest(_ sender: AnyObject) {
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/datatype/", headers: ["Authorization" : "Bearer \(accessTokenTEMPORARY!)"]);
        
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
                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as! [String:Any];
                self.responseLabel.text = dataDictionary.description;
                
            } catch let error as NSError {
                print(error);
            }
        }
        task.resume()
    }
    
    @IBAction func getToken(_ sender: AnyObject) {
        ApiHelper.authorizeUser(clientId: clientId);
    }
    
}
