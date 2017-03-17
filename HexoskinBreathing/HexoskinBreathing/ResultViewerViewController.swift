//
//  ResultViewerViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 2/1/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

struct breathingAction {
    var action: String = "";
    var duration: Double = 0.0;
    var start: Double = 0;
    var end: Double = 0;
}

class ResultViewerViewController: UIViewController {
    
    // variables that store the start and end timestamps for the exercise
    var startTimestamp: Int = -1;
    var endTimestamp: Int = -1;
    var recordID: Int = -1;
    
    // token information used for REST API calls
    var accessToken: String!
    var tokenType: String!
    
    var exercise: BreathingExercise!    // the exercise the user was supposed to complete
    var breathingActions: [breathingAction]! // the actions that were recorded during the exercise
    var performanceResults: [(completed: Bool, instruction: String, duration: Double)]! = nil;
    
    @IBOutlet weak var instructionsLabel: UILabel!
    @IBOutlet weak var analyzeButton: UIButton!
    
    // the reference to the task that gets the record id
    var recordTask: URLSessionDataTask! = nil;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Results"; 
        
        // set background color to white
        self.view.backgroundColor = .white;
        
        let backButton : UIBarButtonItem = UIBarButtonItem(title: "Main Menu", style: .plain, target: self, action: #selector(ResultViewerViewController.backButtonPressed));
        self.navigationItem.leftBarButtonItem = backButton;
        
        // initialize the instruction view
        instructionsLabel.text = "1. Disconnect device from shirt\n\n2. Connect device to computer\n\n3. Sync data using HxServices"; 
    
    }
    
    // Function fired when the user presses the main menu button
    // This should direct them back to the main menu
    func backButtonPressed() {
        print("Back button pressed");
    }
    
    // function fired after the timer delay expires
    func fetchResults() {

        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/data/", query: ["datatype__in" : "34,35", "record" : String(recordID), "start" : String(startTimestamp-512), "end" : String(endTimestamp+512)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
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
                self.breathingActions = self.getExerciseBreathingData(inhalationStarts: dataResponse.returnedData["34"]!, expirationStarts: dataResponse.returnedData["35"]!);
                
                // at this point, the exercise and results are both stored as member variables.
                // the following function uses those members to determine how well the user followed
                // the prescribed exercise. it saves the r
                self.analyzeExercisePerformance();
                
                // push the next view controller on the main queue
                DispatchQueue.main.async {
                    // consolidate the data and prepare to send it to the next controller where
                    // the data will be displayed in a table
                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
                    let viewController = storyboard.instantiateViewController(withIdentifier: "dataViewController") as? DataViewingViewController;
                    viewController?.performanceResults = self.performanceResults;
                    viewController?.results = self.breathingActions;
                    self.navigationController?.pushViewController(viewController!, animated: true);
                }

                
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }
    
    func pushDataViewingController() {
        print("pushing data viewing controller...");
        // consolidate the data and prepare to send it to the next controller where
        // the data will be displayed in a table
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "dataViewController") as? DataViewingViewController;
        viewController?.performanceResults = self.performanceResults;
        viewController?.results = breathingActions;
        self.navigationController?.pushViewController(viewController!, animated: true);
    }
    
    func getRecordID() {
        
        print("get record id");
        
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/record/", query: ["end__gte":String(startTimestamp) ,"start__lte":String(endTimestamp)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
        
        recordTask = URLSession.shared.dataTask(with: request) { data, response, error in
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
//                print(dataDictionary?.description);
                let objectsArray = dataDictionary?["objects"] as? [Any];
                print("Objects Array Count: \(objectsArray?.count)"); 
                if objectsArray?.count == 1 {
                    // there is only 1 record so the filtering worked
                    let recordDictionary = objectsArray?[0] as? [String:Any];
                    let id = recordDictionary?["id"] as? Int;
                    self.recordID = id!;
                    self.fetchResults();
                } else {
                    print("Could not get record. Objects returned: \(objectsArray?.count)");
                    // present alert on main thread
                    DispatchQueue.main.async {
                        // indicate here that the data has not been uploaded correctly
                        let alert = UIAlertController(title: "Data not found", message: "Ensure that the data has been uploaded to the Hexoskin Services using HxServices.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                            print(self.recordTask.description);
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("CASTING ERROR");
            }
        }
        
        // try clearing the cache
//        URLCache.shared.removeAllCachedResponses();
        
        recordTask.resume()
    }
    

    func getExerciseBreathingData(inhalationStarts: [(Double, Double)], expirationStarts: [(Double, Double)]) -> [breathingAction] {
        
        // verify that the arrays are not empty
        if inhalationStarts.count == 0 || expirationStarts.count == 0 {
            print("Array parameter is empty.");
            return [];
        }
        
        // initialize the return array
        var breathingActions: [breathingAction] = [];
        var action: breathingAction = breathingAction();
        
        // first find out if the first action is an inhale or exhale
        let difference = inhalationStarts[0].0 - expirationStarts[0].0;
        if difference < 0 {
            // first action is inhale
            for index in 0...inhalationStarts.count {
                // check if there is an inspiration
                if index < expirationStarts.count {
                    action = breathingAction(action: "Inhale", duration: (expirationStarts[index].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0)/256, end: Double(expirationStarts[index].0)/256);
                    breathingActions.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
                        action = breathingAction(action: "Exhale", duration: (inhalationStarts[index+1].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0/256), end: Double(inhalationStarts[index+1].0/256));
                        breathingActions.append(action);
                    }
                }
            }
        } else if difference > 0 {
            // first action is exhale
            for index in 0...expirationStarts.count {
                // check if there is an inspiration
                if index < inhalationStarts.count {
                    action = breathingAction(action: "Exhale", duration: (inhalationStarts[index].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0/256), end: Double(inhalationStarts[index].0/256));
                    breathingActions.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
                        action = breathingAction(action: "Inhale", duration: (expirationStarts[index+1].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0/256), end: Double(expirationStarts[index+1].0/256));
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
    
    // use the exercise and breathingActions member variables to analyze the performance
    func analyzeExercisePerformance() {
        
        // save the start timestamp of the exercise in seconds
        var instructionStart: Double = Double(self.startTimestamp)/256;
        
        // prune the breathingActions array by removing actions that end before 1 second past the start
        var frontPruningComplete: Bool = false;
        while !frontPruningComplete {
            let action = breathingActions[0];
            if Double(action.end) < instructionStart+1 {
                // remove the action since it ends before the exercise really starts
                breathingActions.remove(at: 0);
            } else {
                frontPruningComplete = true;
            }
        }
        
        // initialize a container to hold the performance results
        performanceResults = [];
        
        // reset the exercise so that we can easily iterate through it
        exercise.reset();
        
        // save the index of the current breathing action
        var index: Int = 0;
        
        // create a variable that will be used to store actions temporarily
        var storedAction: breathingAction! = nil;
        
        // iterate through the exercise
        var currentInstruction = exercise.next();
        while !currentInstruction.complete {
            
            // find the breathing action that has the latest start but still starts within 2 seconds +/- 
            // ...of the current instruction
            // clear the temporary variable that stores the action
            storedAction = nil;
            var condition: Bool = true;
            while condition {
                if index >= breathingActions.count {
                    // there are no more breathing actions
                    condition = false;
                    
                    // check to see if the previous loop found a candidate
                    if storedAction != nil {
                        // the storedAction's duration needs to be checked to see if it satisfies the instruction
                        if Double(storedAction.duration) > currentInstruction.duration - 2 && Double(storedAction.duration) < currentInstruction.duration + 2 {
                            // the storedAction satisfies the instruction
                            performanceResults.append((true, currentInstruction.instruction, currentInstruction.duration));
                        }
                    } else {
                        // no action satisfies the instruction
                        performanceResults.append((false, currentInstruction.instruction, currentInstruction.duration));
                    }
                    
                } else {

                    let action = breathingActions[index];
                    if Double(action.start) < instructionStart + 2 && Double(action.start) > instructionStart - 2 {
                        // this is a candidate to be the action that satisfies the instruction
                        
                        // verify that the actions are both inhale or exhale
                        if action.action == currentInstruction.instruction {
                            // instructions are the same
                            
                            // store this action
                            storedAction = action;
                        }
                        
                        // increment the index since we will be moving to the next action
                        index = index + 1;
                        
                    } else if Double(action.start) > instructionStart + 2 {
                        // none of the following actions will satisfy the instruction
                        condition = false;
                        
                        // check to see if the previous loop found a candidate
                        if storedAction != nil {
                            // the storedAction's duration needs to be checked to see if it satisfies the instruction
                            if Double(storedAction.duration) > currentInstruction.duration - 2 && Double(storedAction.duration) < currentInstruction.duration + 2 {
                                // the storedAction satisfies the instruction
                                performanceResults.append((true, currentInstruction.instruction, currentInstruction.duration));
                            } else {
                                // the candidate action was not the proper duration
                                performanceResults.append((false, currentInstruction.instruction, currentInstruction.duration));
                            }
                        } else {
                            // no action satisfies the instruction
                            performanceResults.append((false, currentInstruction.instruction, currentInstruction.duration));
                        }
                    } else {
                        // the action started too early to be considered for the current instruction
                        // increment the index since we will be moving to the next action
                        index = index + 1;
                    }
                }
            }
            
            instructionStart = instructionStart + currentInstruction.duration;
            currentInstruction = exercise.next();
        }
        
        // prune the breathingActions array by removing actions that start after 1 second before the end of the last instruction
        var backPruningComplete: Bool = false;
        index = 0;
        while !backPruningComplete {
            
            // verify the index is valid
            if index >= breathingActions.count {
                // invalid index
                // exit the loop
                backPruningComplete = true;
            } else {
                // valid index
                // verify that the action falls inside the exercise timestamps
                let action = breathingActions[index];
                if Double(action.start) > instructionStart - 1 {
                    // remove the action since it starts basically at the end of the exercise
                    breathingActions.remove(at: index);
                } else {
                    // if the action is not removed, increment the index
                    index = index + 1;
                }
            }
    
        }
        
        // FOR TESTING PURPOSES - print out the results of the performance analysis
//        for result in performanceResults {
//            print("\(result.instruction) \(result.duration) was completed: \(result.completed)");
//        }
        
    }
    
    @IBAction func getResults(_ sender: Any) {
        
        print("get results");
        self.getRecordID();
    }

    
}
