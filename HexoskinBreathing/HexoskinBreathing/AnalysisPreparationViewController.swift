//
//  AnalysisPreparationViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 2/1/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class AnalysisPreparationViewController: UIViewController {
    
    // interface members
    @IBOutlet weak var hexoskinButton: UIButton!
    @IBOutlet weak var ringButton: UIButton!
    @IBOutlet weak var analyzeButton: UIButton!
    @IBOutlet weak var hexoskinImageView: UIImageView!
    @IBOutlet weak var ringImageView: UIImageView!
    @IBOutlet weak var syncWarningLabel: UILabel!
    
    
    // variables that store the start and end timestamps for the exercise
    var startTimestamp: Int = -1;
    var endTimestamp: Int = -1;
    var recordID: Int = -1;
    
    // token information used for REST API calls
    var accessToken: String!
    var tokenType: String!
    
    var exercise: BreathingExercise! = nil;    // the exercise the user was supposed to complete
    var hexoskinData: [breathingAction]! = nil; // the actions that were recorded during the exercise
    var exerciseData: [breathingAction]! = nil;
    var ringActions: [breathingAction]! = nil;
    
    // variables that store which buttons are selected
    var hexoskinSelected: Bool = false;
    var ringSelected: Bool = false;
    
    // the reference to the task that gets the record id
    var recordTask: URLSessionDataTask! = nil;
    
    // this variable stores whether this is the first time viewdidappear is executing
    var firstExecution: Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Data Picker";
        
        // set background color to white
        self.view.backgroundColor = .white;
        
        let cancelButton : UIBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(AnalysisPreparationViewController.cancelButtonPressed));
        self.navigationItem.leftBarButtonItem = cancelButton;
        self.navigationItem.setHidesBackButton(true, animated: false); 
        
        // initialize the instruction view
        hideSyncLabel();
        
        // filter the ring actions
        filterRingActions();
        
        // add gesture recognizers to the imageviews
        hexoskinImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AnalysisPreparationViewController.hexoskinImagePressed(sender:))));
        ringImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(AnalysisPreparationViewController.ringImagePressed(sender:))));
        hexoskinImageView.isUserInteractionEnabled = true;
        ringImageView.isUserInteractionEnabled = true;
        
        hexoskinButton.alpha = 0;
        ringButton.alpha = 0;
        hexoskinImageView.alpha = 0;
        ringImageView.alpha = 0;
        analyzeButton.alpha = 0;
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        if firstExecution {
            
            // set up the two radio buttons
            hexoskinButton.layer.cornerRadius = 5
            hexoskinButton.layer.borderWidth = 2.0
            hexoskinButton.layer.masksToBounds = true
            ringButton.layer.cornerRadius = 5
            ringButton.layer.borderWidth = 2.0
            ringButton.layer.masksToBounds = true
            
            // set the defaults as unselected
            UIView.animate(withDuration: 0.2, animations: {
                self.setRingSelection(selected: false);
                self.setHexoskinSelection(selected: false);
                self.analyzeButton.alpha = 1.0;
            })
            
            firstExecution = false; 
        }
    }
    
    // Function fired when the user presses the main menu button
    // This should direct them back to the main menu
    func cancelButtonPressed() {
        print("Cancel button pressed");
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
                self.hexoskinData = self.getExerciseBreathingData(inhalationStarts: dataResponse.returnedData["34"]!, expirationStarts: dataResponse.returnedData["35"]!);
                
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
                    viewController?.exerciseData = self.exerciseData;
                    viewController?.hexoskinData = self.hexoskinData;
                    viewController?.ringData = self.ringActions;
                    viewController?.displayHexData = true;
                    viewController?.displayRingData = self.ringSelected;
                    self.navigationController?.pushViewController(viewController!, animated: true);
                }

                
            } catch JSONParsingError.parsingError {
                // the user was uploading the data, but the upload was not complete
                // create an alert on the main thread
                DispatchQueue.main.async {
                    // indicate here that the data has not been uploaded correctly
                    let alert = UIAlertController(title: "Data sync in progress", message: "Try pressing the button again in a few seconds ", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: {action in
                        print(self.recordTask.description);
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
                
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }
    
    func getRecordID() {
        
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
                let objectsArray = dataDictionary?["objects"] as? [Any];
                if objectsArray?.count == 1 {
                    // there is only 1 record so the filtering worked
                    let recordDictionary = objectsArray?[0] as? [String:Any];
                    let id = recordDictionary?["id"] as? Int;
                    self.recordID = id!;
                    self.fetchResults();
                } else {
                    // present alert on main thread
                    DispatchQueue.main.async {
                        // indicate here that the data has not been uploaded correctly
                        let alert = UIAlertController(title: "Data not found", message: "Ensure that the data has been uploaded to the Hexoskin Services using HxServices.", preferredStyle: .alert)
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("CASTING ERROR");
            }
        }
        
        recordTask.resume()
    }
    

    func getExerciseBreathingData(inhalationStarts: [(Double, Double)], expirationStarts: [(Double, Double)]) -> [breathingAction] {
        
        // verify that the arrays are not empty
        if inhalationStarts.count == 0 || expirationStarts.count == 0 {
            print("Array parameter is empty.");
            return [];
        }
        
        // initialize the return array
        var hexoskinData: [breathingAction] = [];
        var action: breathingAction!
        
        // first find out if the first action is an inhale or exhale
        let difference = inhalationStarts[0].0 - expirationStarts[0].0;
        if difference < 0 {
            // first action is inhale
            for index in 0...inhalationStarts.count {
                // check if there is an inspiration
                if index < expirationStarts.count {
                    action = breathingAction(action: "Inhale", duration: (expirationStarts[index].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256);
                    hexoskinData.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
                        action = breathingAction(action: "Exhale", duration: (inhalationStarts[index+1].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(inhalationStarts[index+1].0)/256 - Double(startTimestamp)/256);
                        hexoskinData.append(action);
                    }
                }
            }
        } else if difference > 0 {
            // first action is exhale
            for index in 0...expirationStarts.count {
                // check if there is an inspiration
                if index < inhalationStarts.count {
                    action = breathingAction(action: "Exhale", duration: (inhalationStarts[index].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256);
                    hexoskinData.append(action);
                    
                    // check if there is another expiration
                    if index + 1 < inhalationStarts.count {
                        action = breathingAction(action: "Inhale", duration: (expirationStarts[index+1].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(expirationStarts[index+1].0)/256 - Double(startTimestamp)/256);
                        hexoskinData.append(action);
                    }
                }
            }
        } else {
            // exhale and inhale can't begin at same time
            print("Exhale and inhale can't begin at same time. Error in data.");
            return [];
        }
        
        return hexoskinData;
    }
    
    // use the exercise and hexoskinData member variables to analyze the performance
    func analyzeExercisePerformance() {
        
        // save the start timestamp of the exercise in seconds
        var actionStart: Double = 0.0;
        
        // prune the hexoskinData array by removing actions that end before 1 second past the start
        var frontPruningComplete: Bool = false;
        while !frontPruningComplete {
            let action = hexoskinData[0];
            if Double(action.end) < actionStart+1 {
                // remove the action since it ends before the exercise really starts
                hexoskinData.remove(at: 0);
            } else {
                frontPruningComplete = true;
            }
        }
        
        // initialize a container to hold the performance results
        exerciseData = [];
        
        // reset the exercise so that we can easily iterate through it
        exercise.reset();
        
        // save the index of the current breathing action
        var index: Int = 0;
        
        // create a variable that will be used to store actions temporarily
        var storedAction: breathingAction! = nil;
        
        // iterate through the exercise
        var currentAction = exercise.next();
        while currentAction.action != Strings.notAnAction {
            
            // find the breathing action that has the latest start but still starts within 2 seconds +/- 
            // ...of the current instruction
            // clear the temporary variable that stores the action
            storedAction = nil;
            var condition: Bool = true;
            while condition {
                if index >= hexoskinData.count {
                    // there are no more breathing actions
                    condition = false;
                    
                    // check to see if the previous loop found a candidate
                    if storedAction != nil {
                        // the storedAction's duration needs to be checked to see if it satisfies the instruction
                        if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError && Double(storedAction.duration) < currentAction.duration + Constants.breathLengthAllowableError {
                            // the storedAction satisfies the instruction
                            exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
                        }
                    } else {
                        // no action satisfies the instruction
                        exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                    }
                    
                } else {

                    let action = hexoskinData[index];
                    if Double(action.start) < actionStart + Constants.startBreathSearchWindow && Double(action.start) > actionStart - Constants.startBreathSearchWindow {
                        // this is a candidate to be the action that satisfies the instruction
                        
                        // verify that the actions are both inhale or exhale
                        if action.action == currentAction.action {
                            // instructions are the same
                            
                            // store this action
                            storedAction = action;
                        }
                        
                        // increment the index since we will be moving to the next action
                        index = index + 1;
                        
                    } else if Double(action.start) > actionStart + Constants.startBreathSearchWindow {
                        // none of the following actions will satisfy the instruction
                        condition = false;
                        
                        // check to see if the previous loop found a candidate
                        if storedAction != nil {
                            // the storedAction's duration needs to be checked to see if it satisfies the instruction
                            if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError && Double(storedAction.duration) < currentAction.duration + Constants.breathLengthAllowableError {
                                // the storedAction satisfies the instruction
                                exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
                            } else {
                                // the candidate action was not the proper duration
                                exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                            }
                        } else {
                            // no action satisfies the instruction
                            exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                        }
                    } else {
                        // the action started too early to be considered for the current instruction
                        // increment the index since we will be moving to the next action
                        index = index + 1;
                    }
                }
            }
            
            actionStart = actionStart + currentAction.duration;
            currentAction = exercise.next();
        }
        
        // prune the hexoskinData array by removing actions that start after 1 second before the end of the last instruction
        var backPruningComplete: Bool = false;
        index = 0;
        while !backPruningComplete {
            
            // verify the index is valid
            if index >= hexoskinData.count {
                // invalid index
                // exit the loop
                backPruningComplete = true;
            } else {
                // valid index
                // verify that the action falls inside the exercise timestamps
                let action = hexoskinData[index];
                if Double(action.start) > actionStart - 1 {
                    // remove the action since it starts basically at the end of the exercise
                    hexoskinData.remove(at: index);
                } else {
                    // if the action is not removed, increment the index
                    index = index + 1;
                }
            }
            
        }
        
    }
    
    @IBAction func getResults(_ sender: Any) {
        if hexoskinSelected {
            self.getRecordID();
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil);
            let viewController = storyboard.instantiateViewController(withIdentifier: "dataViewController") as? DataViewingViewController;
            viewController?.exerciseData = self.exercise.actions;
            viewController?.hexoskinData = nil;
            viewController?.ringData = self.ringActions;
            viewController?.displayHexData = false;
            viewController?.displayRingData = ringSelected; 
            self.navigationController?.pushViewController(viewController!, animated: true);
        }
    }
    
    func filterRingActions() {
        
        // remove actions with durations smaller than the threshold
        // the filtering is removing small errors that occur with the ring interface
        var index: Int = 0;
        while index < ringActions.count {
            
            // if the next action is the same, absorb them together regardless of duration
            if index < ringActions.count - 1 && ringActions[index].action == ringActions[index+1].action {
                ringActions[index+1].duration += ringActions[index].duration;
                ringActions[index+1].start = ringActions[index].start;
                
                // remove the current action
                ringActions.remove(at: index);
                
                // index should not be incremented because the combined action
                // still needs to be checked.
            }
            
            // check that current action's duration is less than the threshold
            else if ringActions[index].duration < 0.5 {
                
                // if it's the first action, absorb into the second action
                if index == 0 {
                    // absorb this action into the next action
                    // verify that there are more than one action
                    if ringActions.count > 1 {
                        ringActions[1].duration += ringActions[index].duration;
                        ringActions[1].start = ringActions[index].start;
                        
                        // then remove the first action
                        ringActions.remove(at: index);
                        
                        // index should not be incremented since the action at index 1 is now
                        // at index 0. So the action at index 0 still needs to be checked.
                    }
                }
                
                // if it's the last action, absorb into the second to last action
                else if index == ringActions.count - 1 {
                    // absorb this action into the previous action
                    // verify that there are more than one action
                    if ringActions.count > 1 {
                        ringActions[index-1].duration += ringActions[index].duration;
                        ringActions[index-1].end = ringActions[index].end;
                        
                        // then remove the current action
                        ringActions.remove(at: index);
                        
                        // index should not be incremented because the last action was checked
                        // so no more need to be checked. The loop will end now anyway.
                    }
                }
                
                // if the action is surrounded by two like actions, then absorb all three actions
                // together. we can assume this action is not the first or last action.
                else if ringActions[index-1].action == ringActions[index+1].action {
                    // absorb all the current and the next action into the previous
                    ringActions[index-1].duration += ringActions[index].duration + ringActions[index+1].duration;
                    ringActions[index-1].end = ringActions[index+1].end;
                    
                    // remove the current and next actions
                    ringActions.remove(at: index);
                    ringActions.remove(at: index);
                    
                    // index should not be incremented since we assume the previous action's
                    // duration was already larger than the threshold.
                }
                
                // if action is a pause, absorb to the previous action.
                else if ringActions[index].action == "Pause" {
                    // absorb to the previous action
                    ringActions[index-1].duration += ringActions[index].duration;
                    ringActions[index-1].end = ringActions[index].end;
                    
                    // remove the current action
                    ringActions.remove(at: index);
                }
                
                // if one of the surrounding actions is a pause, then add the current action
                // to the non-pause action. We can assume that they are not both pauses since
                // that is taken care of in the above else-if.
                else if ringActions[index-1].action == "Pause" {
                    // absorb action with next action
                    ringActions[index].action = ringActions[index+1].action;
                    ringActions[index].duration += ringActions[index+1].duration;
                    ringActions[index].end = ringActions[index+1].end;
                    
                    // now remove the next action
                    ringActions.remove(at: index+1);
                    
                    // do not increment the index because the new combined action still needs 
                    // to be checked
                    
                } else if ringActions[index+1].action == "Pause" {
                    // absorb action with previous action
                    ringActions[index-1].duration += ringActions[index].duration;
                    ringActions[index-1].end = ringActions[index].end;
                    
                    // remove this action
                    ringActions.remove(at: index);
                    
                    // do not increment the index
                }
                
                // if it reaches else, there is a problem. Print out error.
                else {
                    print("ERROR: ring action filtering.");
                }
            }
            
            // The current action is accepted
            else {
                index += 1;
            }
            
        }
        
    }

    @IBAction func hexoskinButtonPressed(_ sender: Any) {
        setHexoskinSelection(selected: !hexoskinSelected);
    }
    
    @IBAction func ringButtonPressed(_ sender: Any) {
        setRingSelection(selected: !ringSelected);
    }

    func hexoskinImagePressed(sender: UITapGestureRecognizer) {
        setHexoskinSelection(selected: !hexoskinSelected);
    }
    
    func ringImagePressed(sender: UITapGestureRecognizer) {
        setRingSelection(selected: !ringSelected);
    }
    
    func setHexoskinSelection(selected: Bool) {
        // start by setting the selected variable for hexoskin
        hexoskinSelected = selected;
        
        if selected {
            // mark the hexoskin as selected
            hexoskinImageView.alpha = 1.0;
            hexoskinButton.layer.borderColor = Constants.radioButtonSelectedColor.cgColor;
            hexoskinButton.setTitleColor(Constants.radioButtonSelectedColor, for: .normal);
            hexoskinButton.alpha = 1.0;
            
            // show the syncing label
            showSyncLabel();
        } else {
            // mark the hexoskin as not selected
            hexoskinImageView.alpha = 0.4;
            hexoskinButton.layer.borderColor = Constants.radioButtonUnselectedColor.cgColor;
            hexoskinButton.setTitleColor(Constants.radioButtonUnselectedColor, for: .normal);
            hexoskinButton.alpha = 0.4;
            
            // hide the syncing label
            hideSyncLabel();
        }
    }
    
    func setRingSelection(selected: Bool) {
        // start by setting the selected variable for ring
        ringSelected = selected;
        
        if selected {
            // mark the hexoskin as selected
            ringImageView.alpha = 1.0;
            ringButton.layer.borderColor = Constants.radioButtonSelectedColor.cgColor;
            ringButton.setTitleColor(Constants.radioButtonSelectedColor, for: .normal);
            ringButton.alpha = 1.0;
            
        } else {
            // mark the hexoskin as not selected
            ringImageView.alpha = 0.4;
            ringButton.layer.borderColor = Constants.radioButtonUnselectedColor.cgColor;
            ringButton.setTitleColor(Constants.radioButtonUnselectedColor, for: .normal);
            ringButton.alpha = 0.4;
            
        }
    }
    
    func showSyncLabel() {
        syncWarningLabel.text = "* Sync data with your Hexoskin account using HxServices before continuing";
    }
    
    func hideSyncLabel() {
        syncWarningLabel.text = "";
    }
}
