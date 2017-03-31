//
//  DataAnalyzingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/30/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataAnalyzingViewController: MRRViewController {
    
    // timestamps for the exercise
    var startTimestamp: Int = -1;
    var endTimestamp: Int = -1;
    var recordID: Int = -1;
    
    // authorization variables
    var accessToken: String!
    var tokenType: String!
    
    // raw data collected from exercise
    var ringDataRaw: [breathingAction]!
    var inhalationStarts: [(Double, Double)]!
    var exhalationStarts: [(Double, Double)]!
    
    // base data with basic or no filtering
    var ringDataBase: [breathingAction]!
    var hexoskinDataBase: [breathingAction]!
    var exercise: BreathingExercise!
    
    // data to be sent to data viewer and is ready to be graphed
    var ringDataGraph: [breathingAction]!
    var hexoskinDataGraph: [breathingAction]!
    var exerciseDataGraph: [breathingAction]!
    
    // Booleans for remembering which data will be analyzed
    var analyzingRing: Bool!
    var analyzingHexoskin: Bool!

    override func viewDidLoad() {
        super.viewDidLoad()

        // initialize all of the data arrays to empty
        ringDataRaw = [];
        ringDataBase = [];
        hexoskinDataBase = [];
        ringDataGraph = [];
        hexoskinDataGraph = [];
        exerciseDataGraph = [];
        
    }
    
    /* 
     This is a function that is called once an exercise is complete.
     It takes the raw data, filters it if necessary, then analyzes it.
    */
    func prepareDataAndSendToDataViewer() {
        // Here you have the ringDataRaw, hexoskinDataRaw, and exercise
        // Begin by filtering any data
        if self.analyzingHexoskin == true {
            self.hexoskinDataBase = self.getExerciseBreathingData(inhalationStarts: self.inhalationStarts, expirationStarts: self.exhalationStarts);
        }
        if self.analyzingRing == true {
            self.ringDataBase = self.filterRingData();
        }
        
        // Prepare for Data Viewing Graph
        if self.analyzingHexoskin == true {
            self.exerciseDataGraph = self.analyzeExercisePerformance(data: self.hexoskinDataBase);
        } else if analyzingRing == true {
            self.exerciseDataGraph = self.analyzeExercisePerformance(data: self.ringDataBase);
        }
        self.equalizeGraphDataSources();
        
        // Do any other filtering or analysis here and create new containers for the 
        // various kinds of data
        
        
        // create data viewer view controller and assign the data to the controller
        // consolidate the data and prepare to send it to the next controller where
        // the data will be displayed in a table
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "dataViewController") as? DataViewingViewController;
        viewController?.baseDuration = self.exercise.actions[0].duration; 
        viewController?.exerciseData = self.exerciseDataGraph;
        viewController?.hexoskinData = self.hexoskinDataGraph;
        viewController?.ringData = self.ringDataGraph;
        viewController?.displayHexData = self.analyzingHexoskin;
        viewController?.displayRingData = self.analyzingRing;
        viewController?.exerciseDuration = self.exercise.exerciseDuration;
        self.navigationController?.pushViewController(viewController!, animated: true);
        
    }
    
    func filterRingData() -> [breathingAction] {
        
        // save a copy of the raw ring data
        var ringDataRawCopy = ringDataRaw!;
        
        // remove actions with durations smaller than the threshold
        // the filtering is removing small errors that occur with the ring interface
        var index: Int = 0;
        while index < ringDataRawCopy.count {
            
            // if the next action is the same, absorb them together regardless of duration
            if index < ringDataRawCopy.count - 1 && ringDataRawCopy[index].action == ringDataRawCopy[index+1].action {
                ringDataRawCopy[index+1].duration += ringDataRawCopy[index].duration;
                ringDataRawCopy[index+1].start = ringDataRawCopy[index].start;
                
                // remove the current action
                ringDataRawCopy.remove(at: index);
                
                // index should not be incremented because the combined action
                // still needs to be checked.
            }
                
                // check that current action's duration is less than the threshold
            else if ringDataRawCopy[index].duration < 0.5 {
                
                // if it's the first action, absorb into the second action
                if index == 0 {
                    // absorb this action into the next action
                    // verify that there are more than one action
                    if ringDataRawCopy.count > 1 {
                        ringDataRawCopy[1].duration += ringDataRawCopy[index].duration;
                        ringDataRawCopy[1].start = ringDataRawCopy[index].start;
                        
                        // then remove the first action
                        ringDataRawCopy.remove(at: index);
                        
                        // index should not be incremented since the action at index 1 is now
                        // at index 0. So the action at index 0 still needs to be checked.
                    }
                }
                    
                    // if it's the last action, absorb into the second to last action
                else if index == ringDataRawCopy.count - 1 {
                    // absorb this action into the previous action
                    // verify that there are more than one action
                    if ringDataRawCopy.count > 1 {
                        ringDataRawCopy[index-1].duration += ringDataRawCopy[index].duration;
                        ringDataRawCopy[index-1].end = ringDataRawCopy[index].end;
                        
                        // then remove the current action
                        ringDataRawCopy.remove(at: index);
                        
                        // index should not be incremented because the last action was checked
                        // so no more need to be checked. The loop will end now anyway.
                    }
                }
                    
                    // if the action is surrounded by two like actions, then absorb all three actions
                    // together. we can assume this action is not the first or last action.
                else if ringDataRawCopy[index-1].action == ringDataRawCopy[index+1].action {
                    // absorb all the current and the next action into the previous
                    ringDataRawCopy[index-1].duration += ringDataRawCopy[index].duration + ringDataRawCopy[index+1].duration;
                    ringDataRawCopy[index-1].end = ringDataRawCopy[index+1].end;
                    
                    // remove the current and next actions
                    ringDataRawCopy.remove(at: index);
                    ringDataRawCopy.remove(at: index);
                    
                    // index should not be incremented since we assume the previous action's
                    // duration was already larger than the threshold.
                }
                    
                    // if action is a pause, absorb to the previous action.
                else if ringDataRawCopy[index].action == "Pause" {
                    // absorb to the previous action
                    ringDataRawCopy[index-1].duration += ringDataRawCopy[index].duration;
                    ringDataRawCopy[index-1].end = ringDataRawCopy[index].end;
                    
                    // remove the current action
                    ringDataRawCopy.remove(at: index);
                }
                    
                    // if one of the surrounding actions is a pause, then add the current action
                    // to the non-pause action. We can assume that they are not both pauses since
                    // that is taken care of in the above else-if.
                else if ringDataRawCopy[index-1].action == "Pause" {
                    // absorb action with next action
                    ringDataRawCopy[index].action = ringDataRawCopy[index+1].action;
                    ringDataRawCopy[index].duration += ringDataRawCopy[index+1].duration;
                    ringDataRawCopy[index].end = ringDataRawCopy[index+1].end;
                    
                    // now remove the next action
                    ringDataRawCopy.remove(at: index+1);
                    
                    // do not increment the index because the new combined action still needs
                    // to be checked
                    
                } else if ringDataRawCopy[index+1].action == "Pause" {
                    // absorb action with previous action
                    ringDataRawCopy[index-1].duration += ringDataRawCopy[index].duration;
                    ringDataRawCopy[index-1].end = ringDataRawCopy[index].end;
                    
                    // remove this action
                    ringDataRawCopy.remove(at: index);
                    
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
        
        // return the copy since the copy now contains the filtered data
        return ringDataRawCopy;
        
    }
    
    // use the exercise and passed data arrays of breathingActions to analyze the performance
    func analyzeExercisePerformance(data: [breathingAction]) -> [breathingAction] {
        
        // set the start of the first action to 0
        var actionStart: Double = 0.0;
        
        // initialize a container to hold the performance results
        var results: [breathingAction] = [];
        
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
                if index >= data.count {
                    // there are no more breathing actions
                    condition = false;
                    
                    // check to see if the previous loop found a candidate
                    if storedAction != nil {
                        // the storedAction's duration needs to be checked to see if it satisfies the instruction
                        if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError {
                            // the storedAction satisfies the instruction
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
                        } else {
                            // the last candidate's duration was not long enough
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                        }
                    } else {
                        // no action satisfies the instruction
                        results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                    }
                    
                } else {
                    
                    let action = data[index];
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
                            if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError {
                                // the storedAction satisfies the instruction
                                results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
                            } else {
                                // the candidate action was not the proper duration
                                results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                            }
                        } else {
                            // no action satisfies the instruction
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
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
        
        // return the results array which stores the exercise data
        return results;
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
        
        // prune the hexoskinData array by removing actions that end before 1 second past the start
        var frontPruningComplete: Bool = false;
        while !frontPruningComplete {
            let action = hexoskinData[0];
            if Double(action.end) < 1 {
                // remove the action since it ends before the exercise really starts
                hexoskinData.remove(at: 0);
            } else {
                frontPruningComplete = true;
            }
        }
        
        // prune the hexoskinData array by removing actions that start after 1 second before the end of the last instruction
        var backPruningComplete: Bool = false;
        var index = 0;
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
                if Double(action.start) > exercise.exerciseDuration - 1 {
                    // remove the action since it starts basically at the end of the exercise
                    hexoskinData.remove(at: index);
                } else {
                    // if the action is not removed, increment the index
                    index = index + 1;
                }
            }
            
        }
        
        return hexoskinData;
    }
    
    func equalizeGraphDataSources() {
        
        // copy the base data into the graph data arrays and then modify them in this function
        ringDataGraph = ringDataBase;
        hexoskinDataGraph = hexoskinDataBase;
        
        
        // verify that the ringDataGraph array is not empty
        if analyzingRing && ringDataGraph.count == 0 {
            ringDataGraph.append(breathingAction(action: Strings.notAnAction, duration: 0.0, start: 0.0, end: 0.0));
        }
        
        // verify that the hexData array is not empty
        if analyzingHexoskin && hexoskinDataGraph.count == 0 {
            hexoskinDataGraph.append(breathingAction(action: Strings.notAnAction, duration: 0.0, start: 0.0, end: 0.0));
        }
        
        // grab the earliest start time and latest end time
        let earliestStart: Double!
        let latestEnding: Double!
        if analyzingHexoskin && analyzingRing {
            earliestStart = min(exerciseDataGraph[0].start, hexoskinDataGraph[0].start, ringDataGraph[0].start);
            latestEnding = max(exerciseDataGraph[exerciseDataGraph.count-1].end, hexoskinDataGraph[hexoskinDataGraph.count-1].end, ringDataGraph[ringDataGraph.count-1].end);
        } else if analyzingRing == true {
            earliestStart = min(exerciseDataGraph[0].start, ringDataGraph[0].start);
            latestEnding = max(exerciseDataGraph[exerciseDataGraph.count-1].end, ringDataGraph[ringDataGraph.count-1].end);
        } else {
            earliestStart = min(exerciseDataGraph[0].start, hexoskinDataGraph[0].start);
            latestEnding = max(exerciseDataGraph[exerciseDataGraph.count-1].end, hexoskinDataGraph[hexoskinDataGraph.count-1].end);
        }
        
        // check if the data source has a beginning equal to that of the earliest start.
        // if not, add a "not an action" action to the beginning of it.
        if exerciseDataGraph[0].start != earliestStart {
            exerciseDataGraph.insert(breathingAction(action: Strings.notAnAction, duration: exerciseDataGraph[0].start - earliestStart, start: earliestStart, end: exerciseDataGraph[0].start), at: 0);
        }
        if analyzingHexoskin && hexoskinDataGraph[0].start != earliestStart {
            hexoskinDataGraph.insert(breathingAction(action: Strings.notAnAction, duration: hexoskinDataGraph[0].start - earliestStart, start: earliestStart, end: hexoskinDataGraph[0].start), at: 0);
        }
        if analyzingRing && ringDataGraph[0].start != earliestStart {
            ringDataGraph.insert(breathingAction(action: Strings.notAnAction, duration: ringDataGraph[0].start - earliestStart, start: earliestStart, end: ringDataGraph[0].start), at: 0);
        }
        
        // do the similar thing for the endings
        if exerciseDataGraph[exerciseDataGraph.count-1].end != latestEnding {
            exerciseDataGraph.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - exerciseDataGraph[exerciseDataGraph.count-1].end, start: exerciseDataGraph[exerciseDataGraph.count-1].end, end: latestEnding));
        }
        if analyzingHexoskin && hexoskinDataGraph[hexoskinDataGraph.count-1].end != latestEnding {
            hexoskinDataGraph.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - hexoskinDataGraph[hexoskinDataGraph.count-1].end, start: hexoskinDataGraph[hexoskinDataGraph.count-1].end, end: latestEnding));
        }
        if analyzingRing && ringDataGraph[ringDataGraph.count-1].end != latestEnding {
            ringDataGraph.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - ringDataGraph[ringDataGraph.count-1].end, start: ringDataGraph[ringDataGraph.count-1].end, end: latestEnding));
        }
        
    }
    
    // MARK: Hexoskin API Functions
    
    func getRecordID() {
        
        // construct the request
        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/record/", query: ["end__gte":String(startTimestamp) ,"start__lte":String(endTimestamp)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
        
        
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
                    self.recordID = id!;
                    self.fetchResults();
                } else {
                    // present alert on main thread
                    DispatchQueue.main.async {
                        // indicate here that the data has not been uploaded correctly
                        let alert = UIAlertController(title: "Data not found", message: "Ensure that the data has been uploaded to the Hexoskin Services using HxServices.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil));
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            } catch {
                print("CASTING ERROR");
            }
        }
        
        task.resume()
    }
    
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
                
                // assign inhalations and exhalations to member variables
                self.inhalationStarts = dataResponse.returnedData["34"]!;
                self.exhalationStarts = dataResponse.returnedData["35"]!;
                
                // now prepare the data for analysis and push to next view controller
                DispatchQueue.main.async {
                    self.prepareDataAndSendToDataViewer();
                }
                
            } catch JSONParsingError.parsingError {
                // the user was uploading the data, but the upload was not complete
                // create an alert on the main thread
                DispatchQueue.main.async {
                    // indicate here that the data has not been uploaded correctly
                    let alert = UIAlertController(title: "Data sync in progress", message: "Try pressing the button again in a few seconds ", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                
            } catch {
                print("CASTING ERROR");
            }
        }
        task.resume()
    }
    


}
