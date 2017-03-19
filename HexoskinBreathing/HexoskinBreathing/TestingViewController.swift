//
//  TestingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//


import UIKit

//struct breathingAction {
//    var action: String = "";
//    var duration: Double = 0.0;
//}

class TestingViewController: UIViewController {
    
    var clientId: String!
    var clientSecret: String!
    var clientIdNumber: String!
    
    @IBOutlet weak var sendRequestButton: UIButton!
    @IBOutlet weak var pullRecordsButton: UIButton!
    @IBOutlet weak var responseLabel: UITextView!
    @IBOutlet weak var recordTextField: UITextField!
    @IBOutlet weak var datatypeTextField: UITextField!
    @IBOutlet weak var metricTextField: UITextField!
    
    var tokenType: String!
    var accessToken: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        responseLabel.text = "";
    }
    
    @IBAction func sendRequest(_ sender: AnyObject) {
        // grab the inputted values from the text fields
        var recordNumber = recordTextField.text;
        var datatypeNumber = datatypeTextField.text;
        
        if recordNumber == "" || datatypeNumber == "" {
            recordNumber = "115411";
            datatypeNumber = "37";
        }
        
        // Fill in the start and end timestamps right here
        let dateFormatter = DateFormatter();
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss";
        let startDate = dateFormatter.date(from: "2017-01-18-18-31-28");
        let endDate = dateFormatter.date(from: "2017-01-18-18-40-14");
        let start = (startDate?.timeIntervalSince1970)!;
        let end = (endDate?.timeIntervalSince1970)!;
        let startTimestamp = Int(start);
        let endTimestamp = Int(end);
        
        print("Start: \(startTimestamp*256)");
        print("End: \(endTimestamp*256)");
        
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/data/", query: ["datatype__in" : datatypeNumber!, "record" : recordNumber!, "start" : String(startTimestamp*256), "end" : String(endTimestamp*256)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
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
                let dataDictionary = try JSONSerialization.jsonObject(with: data);
                let dataResponse = try DataResponse(json: dataDictionary);
                let breathLengths = self.getExerciseBreathingData(inhalationStarts: dataResponse.returnedData["34"]!, expirationStarts: dataResponse.returnedData["35"]!);
                
                // print out the breath length information
                for action in breathLengths {
                    print("\(action.action) for \(action.duration)");
                }
                
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }
    
    func getExerciseBreathingData(inhalationStarts: [(Double, Double)], expirationStarts: [(Double, Double)]) -> [breathingAction] {
        
        // verify that the arrays are not nil
//        if inhalationStarts == nil || expirationStarts == nil {
//            print("Array parameter is nil");
//            return [];
//        }
        
        // verify that the arrays are not empty
        if inhalationStarts.count == 0 || expirationStarts.count == 0 {
            print("Array parameter is empty.");
            return [];
        }
        
        // initialize the return array
        var breathingActions: [breathingAction] = [];
        var action: breathingAction!;
        
        // first find out if the first action is an inhale or exhale
        let difference = inhalationStarts[0].0 - expirationStarts[0].0;
        if difference < 0 {
            // first action is inhale
            for index in 0...inhalationStarts.count {
                // check if there is an inspiration
                if index < expirationStarts.count {
//                    action = breathingAction(action: "Inhale", duration: (expirationStarts[index].0-inhalationStarts[index].0)/256);
                    breathingActions.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
//                        action = breathingAction(action: "Exhale", duration: (inhalationStarts[index+1].0-expirationStarts[index].0)/256);
                        breathingActions.append(action);
                    }
                }
            }
        } else if difference > 0 {
            // first action is exhale 
            for index in 0...expirationStarts.count {
                // check if there is an inspiration
                if index < inhalationStarts.count {
//                    action = breathingAction(action: "Exhale", duration: (inhalationStarts[index].0-expirationStarts[index].0)/256);
                    breathingActions.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
//                        action = breathingAction(action: "Inhale", duration: (expirationStarts[index+1].0-inhalationStarts[index].0)/256);
                        breathingActions.append(action);
                    }
                }
            }
        } else {
            // exhale and inhale can't begin at same time
            print("Exhale and inhale can't begin at same time. Error in data.");
            return [];
        }
        
        return breathingActions;
    }
    
//    @IBAction func sendRequest(_ sender: AnyObject) {
//        // construct the request
//        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/data/", query: ["datatype__in" : "37", "record" : "110676"], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
//        
//        // make the request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(error)")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
//            
//            do {
//                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any];
//                DispatchQueue.main.async {
//                    self.responseLabel.text = dataDictionary?.description;
//                    self.responseLabel.textColor = .red;
//                    self.responseLabel.backgroundColor = .black; 
//                }
////                        self.responseLabel.backgroundColor = .black;
////                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any];
////                if dataDictionary == nil {
////                    let dataArray = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any];
////                    DispatchQueue.main.async {
////                        self.responseLabel.text = dataArray?.description;
////                        self.responseLabel.textColor = .red;
////                        self.responseLabel.backgroundColor = .black;
////                        let firstElement = dataArray?.first as! [String : Any];
////                        //self.responseLabel.text = firstElement.description;
////                        
////                    }
////                } else {
////                    DispatchQueue.main.async {
////                        self.responseLabel.text = dataDictionary?.description;
////                        self.responseLabel.textColor = .red;
////                        self.responseLabel.backgroundColor = .black;
////                        
////                        // extract the data from the data dictionary
////
////                    }
////                }
//            } catch {
//                print("CASTING ERROR");
//            }
//        }
//        task.resume()
//    }
    
    @IBAction func getMetric(_ sender: Any) {
        // grab the inputted values from the text fields
        var recordNumber = recordTextField.text;
        var metricNumber = metricTextField.text;
        
        if recordNumber == "" || metricNumber == "" {
            recordNumber = "115411";
            metricNumber = "17"; 
        }
        
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/report/", query: ["include_metrics" : metricNumber!, "record" : recordNumber!], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
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
                    print("Metric json is nil");
                }
                DispatchQueue.main.async {
                    self.responseLabel.text = dataDictionary?.description;
                    self.responseLabel.textColor = .red;
                    self.responseLabel.backgroundColor = .black;
                }
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }

    
    
    @IBAction func pullRecords(_ sender: Any) {
        
        // Fill in the start and end timestamps right here
        let dateFormatter = DateFormatter();
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC");
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss";
        let startDate = dateFormatter.date(from: "2017-01-18-18-31-28");
        let endDate = dateFormatter.date(from: "2017-01-18-18-40-14");
        let start = (startDate?.timeIntervalSince1970)!;
        let end = (endDate?.timeIntervalSince1970)!;
        let startTimestamp = Int(start*256);
        let endTimestamp = Int(end*256);
        
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/record/", query: ["end__gte":String(endTimestamp) ,"start__lte":String(startTimestamp)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
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
                let objectsArray = dataDictionary?["objects"] as? [Any];
                if objectsArray?.count == 1 {
                    // there is only 1 record so the filtering worked
                    let recordDictionary = objectsArray?[0] as? [String:Any];
                    let id = recordDictionary?["id"] as? Int;
                    print("Record ID: \(id)");
                } else {
                    print("More than one record. Figure out way to choose between multiple records.");
                }
                
                
                
                
//                DispatchQueue.main.async {
//                    self.responseLabel.text = dataDictionary?.description;
//                    self.responseLabel.textColor = .red;
//                    self.responseLabel.backgroundColor = .black;
//                }
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
        
//        // construct the request
//        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/record/", query: [:], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
//        
//        // make the request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            guard let data = data, error == nil else {                                                 // check for fundamental networking error
//                print("error=\(error)")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(response)")
//            }
//            
//            do {
//                let dataDictionary = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any];
//                DispatchQueue.main.async {
//                    self.responseLabel.text = dataDictionary?.description;
//                    self.responseLabel.textColor = .red;
//                    self.responseLabel.backgroundColor = .black;
//                }
//            } catch {
//                print("CASTING ERROR");
//            }
//        }
//        task.resume()
        
    }
    
}
