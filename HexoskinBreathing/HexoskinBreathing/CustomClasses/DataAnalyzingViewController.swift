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
    
    // base data with an offset added to line up views
    var ringDataWithOffset: [breathingAction]!
    var hexoskinDataWithOffset: [breathingAction]!
    
    // data to be sent to data viewer and is ready to be graphed
    var ringDataGraph: [breathingAction]!
    var hexoskinDataGraph: [breathingAction]!
    var exerciseDataGraph: [breathingAction]!
    
    // variables for the printed report
    var ringDataReport: [breathingAction]!
    var hexoskinDataReport: [breathingAction]!
    var exerciseResultsBasedOnRing: [breathingAction]!
    var exerciseResultsBasedOnHexoskin: [breathingAction]!
    var ringPercentageScore: Double!
    var hexoskinPercentageScore: Double!
    var percentCompletedInstructionsHexoskin: Double!
    var percentCompletedInstructionsRing: Double!
    var ringAverageError: Double!
    var ringErrors: [(Int, Double)]!
    var hexoskinAverageError: Double!
    var hexoskinErrors: [(Int, Double)]!
    var hexRingComparison: Double!
    var offsetHexoskinPercentageScore: Double!
    var offsetHexoskinErrors: [(Int, Double)]!
    var offsetHexoskinAverageError: Double!;
    var offsetHexRingComparison: Double!
    var longestInhaleHexoskin: Double!
    var longestExhaleHexoskin: Double!
    
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
        exerciseResultsBasedOnRing = [];
        exerciseResultsBasedOnHexoskin = [];
        ringDataReport = [];
        hexoskinDataReport = [];
        
    }
    
    /* 
     This is a function that is called once an exercise is complete.
     It takes the raw data, filters it if necessary, then analyzes it.
    */
    func prepareDataAndSendToDataViewer() {

        // set up and store the 3 main data containers
        if self.analyzingHexoskin == true {
            self.hexoskinDataBase = self.getExerciseBreathingData(inhalationStarts: self.inhalationStarts, expirationStarts: self.exhalationStarts);
        }
        if self.analyzingRing == true {
            self.ringDataBase = self.ringDataRaw;
        }
        self.exerciseDataGraph = exercise.actions;
        
        // At this point, we have:
        // 1: exerciseDataGraph - stores target exercise information
        // 2: hexoskinDataBase - hexoskin data that has not been adjusted
        // 3: ringDataBase - the ring data that should be accurate
        
        // Now, we should try to line up all of the data
        if self.analyzingHexoskin == true {
            adjustHexoskinDataStartTimes();
        }
        
        // make sure all of the data sources have the same start and end times to make graphing simpler
        // stores changes to the Graph data member variables so that the base members are not changed
        self.equalizeGraphDataSources();
        
        // compare the hexoskin and ring data
        if analyzingRing && analyzingHexoskin {
            hexRingComparison = compareRingAndHexoskin(ringData: ringDataBase, hexoskinData: hexoskinDataBase);
        }
        
        // Longest action analysis
        longestInhaleHexoskin = 0.0;
        longestExhaleHexoskin = 0.0;
        if analyzingHexoskin == true {
            for action in hexoskinDataBase {
                if action.action == Strings.inhale && longestInhaleHexoskin < action.duration {
                    longestInhaleHexoskin = action.duration;
                } else if action.action == Strings.exhale && longestExhaleHexoskin < action.duration {
                    longestExhaleHexoskin = action.duration;
                }
            }
        }
        
        // group Hexoskin data by grouping really short actions with it's surrounding actions
        if analyzingHexoskin == true {
            let groupedHexoskinData = groupHexoskinData();
            
            print("Hexoskin Data: ");
            for action in hexoskinDataBase {
                print("\(action.action) for \(action.duration) start: \(action.start) end: \(action.end)");
            }
            
            print("\nGroup Data:");
            for group in groupedHexoskinData {
                var groupString = "Action \(group.0):";
                for instruction in group.1 {
                    groupString += " \(instruction)"
                }
                print(groupString);
            }
            
            // Percent of instructions completed analysis
            percentCompletedInstructionsHexoskin = calculatePercentageOfInstructionsCompleted(exerciseActions: exercise.actions, userActions: hexoskinDataBase, groupings: groupedHexoskinData);
            
            // Find the average error on all attempted instructions
            let hexoskinResult = self.calculatePercentErrorPerAttemptedInstruction(userActions: hexoskinDataBase, exerciseActions: exercise.actions, groupings: groupedHexoskinData);
            hexoskinAverageError = hexoskinResult.0;
            hexoskinErrors = hexoskinResult.1;
            
            print("Percent of instructions completed: \(percentCompletedInstructionsHexoskin)");
            print("Average error per attempted instruction: \(hexoskinAverageError)");
            print("Errors on instructions:");
            for error in hexoskinErrors {
                print("Instruction \(error.0): \(error.1)");
            }
            
        }
        

        
        
        // print the report here
//        printReport();
        
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
    
    // This data grouping involves looking for really short instructions and grouping them with 
    // the surrounding actions. The goal is to line up Hexoskin actions to make it easier to pair 
    // Hexoskin actions with target exercise actions. We should not permanently filter out these 
    // small instructions because we need the original unfiltered data to determine if the action 
    // met the target action.
    func groupHexoskinData() -> [(Int, [Int])] {
        
        // choose a threshold for valid actions
        let threshold: Double = 1.0;
        
        // create the variable that will store the groups
        var groupings: [(Int, [Int])] = [];
        
        // store the index of the start of the last valid action
        var lastValidActionIndex = -1;
        
        // store the current action group number
        var groupNumber = 0;
        
        // iterate through the hexoskin data using a while loop to make it easy to know the index while 
        // allowing the index to be modifiable
        var tempGroup: [Int] = [];
        var index: Int = 0;
        while index < hexoskinDataBase.count {
            
            // check if the current action's duration is longer than the threshold
            if hexoskinDataBase[index].duration > threshold {
                
                // check to see if this is the first valid action
                if lastValidActionIndex == -1 {
                    // this is the first valid action -- do not store anything in groupings
                    // but add this index to the tempGroup
                    tempGroup.append(index);
                    lastValidActionIndex = 0;
                    
                    if (isEven(number: groupNumber) && hexoskinDataBase[index].action == Strings.exhale) || (!isEven(number: groupNumber) && hexoskinDataBase[index].action == Strings.inhale) {
                        // The current group is empty and the group number needs to be incremented
                        groupings.append((groupNumber, []));
                        groupNumber += 1;
                    }
                    
                } else {
                    // this is the not the first valid action -- add the previous grouping to the container
                    groupings.append((groupNumber, tempGroup))
                    
                    // increment the group number
                    groupNumber += 1;
                    
                    // clear the temp group so that it can be stored with the next round
                    tempGroup = [index];
                }
                
            } else {
                // not a valid action - add the next two (if there are two) to the temp group
                // we add the next one too because
                tempGroup.append(index);
                if index + 1 < hexoskinDataBase.count {
                    tempGroup.append(index+1);
                    index += 1;
                }
            }
            
            // move to the next index
            index += 1;
        }
        
        // see if there are any actions to add to the last valid action
        if tempGroup.count != 0 {
            groupings.append((groupNumber, tempGroup));
        }
        
        return groupings;
    }
    
    func printReport() {
        print("------------------------------------------------------\n")
        // indicate what type of trial the user did
        if analyzingRing == true && analyzingHexoskin == true {
            print("Exercise Report: Using ring interface with Hexoskin");
        } else if analyzingRing == true {
            print("Exercise Report: Using ring interface only");
        } else if analyzingHexoskin == true {
            print("Exercise Report: Using hexoskin only");
        } else {
            print("Exercise Report: Analyzing no data")
        }
        
        // print out the time stamps for this exercise and record ID
        if analyzingHexoskin == true {
            print("\nRecord ID: \(recordID)");
        }
        print("Start time: \(startTimestamp) (In Hexoskin Timestamp Format)");
        print("End time: \(endTimestamp) (In Hexoskin Timestamp Format)");
        
        
        // print the target exercise
        print("\nTarget exercise data: ")
        var counter: Int = 1;
        for action in exercise.actions {
            print("\(counter). \(action.action) for \(action.duration) s start: \(action.start) end: \(action.end)");
            counter += 1;
        }
        
        // print the hexoskin data
        counter = 1;
        if analyzingHexoskin == true {
            print("\nHexoskin breathing data: ");
            if hexoskinDataReport.count == 0 {
                print("ERROR: Hexoskin data is empty.");
            } else {
                for action in hexoskinDataReport {
                    print("\(counter). \(action.action) for \(action.duration) s start: \(action.start) end: \(action.end)");
                    counter += 1;
                }
            }
        }
        
        // print the exercise results based on hexoskin
        counter = 1;
        if analyzingHexoskin == true {
            print("\nExercise results based on hexoskin:");
            if exerciseResultsBasedOnHexoskin.count == 0 {
                print("ERROR: Exercise results based on hexoskin are empty.");
            } else {
                for action in exerciseResultsBasedOnHexoskin {
                    if action.metByInstruction != -1 {
                        print("Exercise instruction #\(counter) was completed by hexoskin action #\(action.metByInstruction+1)");
                    } else {
                        print("Exercise instruction #\(counter) was not completed based on hexoskin data");
                    }
                    counter += 1;
                }
            }
        }
        
        // print the ring data
        counter = 1;
        if analyzingRing == true {
            print("\nRing breathing data: ");
            if ringDataReport.count == 0 {
                print("ERROR: Ring data is empty.");
            } else {
                for action in ringDataReport {
                    print("\(counter). \(action.action) for \(action.duration) s start: \(action.start) end: \(action.end)");
                    counter += 1;
                }
            }
        }
        
        // print the exercise results based on ring
        counter = 1;
        if analyzingRing == true {
            print("\nExercise results based on ring:");
            if exerciseResultsBasedOnRing.count == 0 {
                print("ERROR: Exercise results based on ring are empty.");
            } else {
                for action in exerciseResultsBasedOnRing {
                    if action.metByInstruction != -1 {
                        print("Exercise instruction #\(counter) was completed by ring action #\(action.metByInstruction+1)");
                    } else {
                        print("Exercise instruction #\(counter) was not completed based on ring data");
                    }
                    counter += 1;
                }
            }
        }
        
        // Print the percentage scores
        print("\nPercentage Scores: ");
        print("* The percent of time that the user was performing the correct instruction during the exercise.");
        print("* This score assumes the target exercise start and end times as the basis for calculation.");
        if hexoskinPercentageScore != nil {
            print("Hexoskin - \(hexoskinPercentageScore!)%");
        }
        if ringPercentageScore != nil {
            print("Ring - \(ringPercentageScore!)%");
        }
        
        // print the percent of instructions completed
        print("\nPercent of target instructions completed according to data source: ");
        if percentCompletedInstructionsHexoskin != nil {
            print("Hexoskin - \(percentCompletedInstructionsHexoskin!)%");
        }
        if percentCompletedInstructionsRing != nil {
            print("Ring - \(percentCompletedInstructionsRing!)%");
        }
        
        // print out error information 
        print("\nError results:");
        print("* The error for each instruction is found by calculating the percent difference between each");
        print("* completed instruction and the user action that completed it.");
        if analyzingHexoskin == true {
            print("Hexoskin Errors: ");
            for error in hexoskinErrors {
                print("\(error.1)% in exercise instruction #\(error.0)");
            }
            print("Average error per completed instruction: \(hexoskinAverageError!)");
        }
        if analyzingRing == true {
            print("Ring Errors:");
            for error in ringErrors {
                print("\(error.1)% in exercise instruction #\(error.0)");
            }
            print("Average error per completed instruction: \(ringAverageError!)");
        }
        
        // print out the comparison information between ring and hexoskin
        if hexRingComparison != nil {
            print("\nHexoskin/Ring Comparison:");
            print("Percent of time that ring and hexoskin indicate the user is doing the same action: \(hexRingComparison!)");
        }
        
        // print out longest breaths recorded by hexoskin
        if analyzingHexoskin == true {
            print("\nLongest breaths recorded by Hexoskin:");
            print("Inhale: \(longestInhaleHexoskin!)");
            print("Exhale: \(longestExhaleHexoskin!)");
        }
        
        print("\nEnd of Exercise Report");
    }
    
    func adjustHexoskinDataStartTimes() {
        // look for the first instruction that is an exhale that also lasts longer than 3 seconds
        for action in hexoskinDataBase {
            if action.start > 1.5 * exercise.actions[0].duration {
                // the offset is too big, so just stop and ignore the offset
                break;
            }
            if action.action == Strings.exhale && action.duration >= 3.0 {
                // calculate offset between this action and the 2nd action of the exercise
                let offset = action.start - exercise.actions[1].start;
                
                // create a temp array to store the adjusted actions
                var tempActions: [breathingAction] = [];
                
                // now add the offset to all of the actions in the array
                for action1 in hexoskinDataBase {
                    tempActions.append(breathingAction(action: action1.action, duration: action1.duration, start: action1.start - offset, end: action1.end - offset))
                }
                
                // store the adjusted actions in the member variable
                hexoskinDataBase = tempActions;
                
                break;
            }
        }
    }
    
    func compareRingAndHexoskin(ringData: [breathingAction], hexoskinData: [breathingAction]) -> Double {
        // since the ring data duration will almost always be shorter than the hexoskin, we will iterate through the ring
        
        var timeCorrect: Double = 0.0; // total time when the instructions are the same
        var index: Int = 0; // index for userActions
        var exerciseDuration: Double = 0.0;
        
        // iterate through the ringActions
        for ringAction in ringData {
            
            // skip action if it's not inhale or exhale
            if ringAction.action == Strings.inhale || ringAction.action == Strings.exhale {
                
                exerciseDuration += ringAction.duration;
                var finishedCheckingInstruction: Bool = false;
                
                while finishedCheckingInstruction == false {
                    
                    if index >= hexoskinData.count {
                        // there are no more hexoskinData that can satisfy the instruction
                        finishedCheckingInstruction = true;
                        
                    } else {
                        // check if current userAction overlaps with the action
                        let userAction = hexoskinData[index];
                        if userAction.start <= ringAction.start && userAction.end > ringAction.start && userAction.end <= ringAction.end {
                            // this means the user action starts before the instructon and ends in the middle of the instruction
                            
                            if userAction.action == ringAction.action {
                                // they are the same instruction so it satisfies it
                                timeCorrect += userAction.end - ringAction.start;
                            }
                            index += 1;
                            
                        } else if userAction.start >= ringAction.start && userAction.end <= ringAction.end {
                            // this means the entire action is encompassed by the instruction
                            
                            if userAction.action == ringAction.action {
                                // they are same instruction
                                timeCorrect += userAction.duration;
                            }
                            index += 1;
                            
                        } else if userAction.start >= ringAction.start && userAction.end > ringAction.end {
                            // this means the action starts in the instruction and continues past it
                            
                            if userAction.action == ringAction.action {
                                // they are the same instruction
                                timeCorrect += ringAction.end - userAction.start;
                            }
                            finishedCheckingInstruction = true;
                            
                        } else if userAction.start < ringAction.start && userAction.end > ringAction.end {
                            // the instruction is totally encompassed by the user action
                            
                            if userAction.action == ringAction.action {
                                // they are the same instruction
                                timeCorrect += ringAction.duration;
                            }
                            finishedCheckingInstruction = true;
                            
                        } else if userAction.end <= ringAction.start {
                            // the action ends before the exercise instruction
                            index += 1;
                            
                        } else if userAction.start >= ringAction.end {
                            // the user action begins after the instruction ends
                            // move to the next instruction in this case (shouldn't happen though)
                            finishedCheckingInstruction = true;
                            
                        } else {
                            print("ERROR: Case not handled when scoring performance");
                            print("Exercise Instruction: start - \(ringAction.start) end - \(ringAction.end)");
                            print("User Action: start - \(userAction.start) end - \(userAction.end)");
                            index += 1;
                        }
                    }
                }
                
            }
        }
        
        return 100*timeCorrect/exerciseDuration;

    }
    
    func calculatePercentErrorPerAttemptedInstruction(userActions: [breathingAction], exerciseActions: [breathingAction], groupings: [(Int, [Int])]) -> (Double, [(Int, Double)]) {
        
        // variables that will store error information as we iterate through and compare
        var errors: [(Int, Double)] = [];
        var cumulativeError: Double = 0.0;
        
        // store the count of the smaller array (groupings and exercise actions)
        let count = min(exerciseActions.count, groupings.count);
        
        for index in 0...count-1 {
            // for each group, find the longest correct instruction and find the error on that one
            var longestDuration: Double = 0.0;
            for instruction in groupings[index].1 {
                if userActions[instruction].action == exerciseActions[index].action && userActions[instruction].duration > longestDuration {
                    longestDuration = userActions[instruction].duration;
                }
            }
            
            // using the longest duration for a correct instruction, find the error
            let percentError = 100*(longestDuration - exerciseActions[index].duration) / exerciseActions[index].duration;
            errors.append((index, percentError));
            cumulativeError += percentError;
            
        }
        
        if count == 0 {
            return (0, []);
        }
        
        return (cumulativeError/Double(count), errors);
        
    }
    
    func calculatePercentageOfInstructionsCompleted(exerciseActions: [breathingAction], userActions: [breathingAction], groupings: [(Int, [Int])]) -> Double {
        
        // variable that stores the number of completed actions
        var completed: Int = 0;
        
        // store the smaller count (exercise actions and groupings)
        let count = min(exerciseActions.count, groupings.count);
        
        for index in 0...count-1 {
            
            // for each group, find the longest correct instruction and find the error on that one
            var longestDuration: Double = 0.0;
            for instruction in groupings[index].1 {
                if userActions[instruction].action == exerciseActions[index].action && userActions[instruction].duration > longestDuration {
                    longestDuration = userActions[instruction].duration;
                }
            }
            
            // check to see if the longest duration satisfies the target action
            if longestDuration > exerciseActions[index].duration - 2 {
                // the action is satisfied - increment the completed counter
                completed += 1;
            }
            
        }
        
        return 100 * Double(completed) / Double(exerciseActions.count);
        
    }
    
    func calculatePercentageOfTimeOnCorrectInstruction(userActions: [breathingAction], exerciseActions: [breathingAction]) -> Double {
        // at this point, the exercises have already been lined up, so there is no need to calculate
        // average offset and line them up
        
        var timeCorrect: Double = 0.0; // total time spent doing the correct instruction
        var index: Int = 0; // index for userActions
        var exerciseDuration: Double = 0.0;
        
        // iterate through the exerciseActions
        for exerciseAction in exerciseActions {
            
            // skip action if it's not inhale or exhale
            if exerciseAction.action == Strings.inhale || exerciseAction.action == Strings.exhale {
                
                exerciseDuration += exerciseAction.duration;
                var finishedCheckingInstruction: Bool = false;
                
                while finishedCheckingInstruction == false {
                    
                    if index >= userActions.count {
                        // there are no more userActions that can satisfy the instruction
                        finishedCheckingInstruction = true;
                        
                    } else {
                        // check if current userAction overlaps with the action
                        let userAction = userActions[index];
                        if userAction.start <= exerciseAction.start && userAction.end > exerciseAction.start && userAction.end <= exerciseAction.end {
                            // this means the user action starts before the instructon and ends in the middle of the instruction
                            
                            if userAction.action == exerciseAction.action {
                                // they are the same instruction so it satisfies it
                                timeCorrect += userAction.end - exerciseAction.start;
                            }
                            index += 1;
                            
                        } else if userAction.start >= exerciseAction.start && userAction.end <= exerciseAction.end {
                            // this means the entire action is encompassed by the instruction
                            
                            if userAction.action == exerciseAction.action {
                                // they are same instruction
                                timeCorrect += userAction.duration;
                            }
                            index += 1;
                            
                        } else if userAction.start >= exerciseAction.start && userAction.end > exerciseAction.end {
                            // this means the action starts in the instruction and continues past it
                            
                            if userAction.action == exerciseAction.action {
                                // they are the same instruction
                                timeCorrect += exerciseAction.end - userAction.start;
                            }
                            finishedCheckingInstruction = true;
                            
                        } else if userAction.start < exerciseAction.start && userAction.end > exerciseAction.end {
                            // the instruction is totally encompassed by the user action
                            
                            if userAction.action == exerciseAction.action {
                                // they are the same instruction
                                timeCorrect += exerciseAction.duration;
                            }
                            finishedCheckingInstruction = true;
                            
                        } else if userAction.end <= exerciseAction.start {
                            // the action ends before the exercise instruction
                            index += 1;
                            
                        } else if userAction.start >= exerciseAction.end {
                            // the user action begins after the instruction ends
                            // move to the next instruction in this case (shouldn't happen though)
                            finishedCheckingInstruction = true;
                            
                        } else {
                            print("ERROR: Case not handled when scoring performance");
                            print("Exercise Instruction: start - \(exerciseAction.start) end - \(exerciseAction.end)");
                            print("User Action: start - \(userAction.start) end - \(userAction.end)");
                            index += 1; 
                        }
                    }
                }
                
            }
        }
        
        return 100*timeCorrect/exerciseDuration;
    }
    
    func calculateAverageOffset(userActions: [breathingAction], exerciseActions: [breathingAction]) -> Double {
        var counter: Int = 0;
        var totalOffset: Double = 0.0;
        let totalActions = exerciseActions.count;
        for action in exerciseActions {
            // check if the action was met by a particular instruction in the user actions
            if action.metByInstruction != -1 {
                // the action was met by a particular instruction
                // calculate the offset of the two instructions and store it in the running total
                // WEIGHT EARLIER INSTRUCTIONS HIGHER
                let weighting = totalActions - counter;
                totalOffset += Double(weighting) * (action.start - userActions[action.metByInstruction].start);
                // the counter stores how many offsets we calculated (used for average)
                counter += weighting;
            }
        }
        
        // if no instructions were met, then no offset is required
        if counter == 0 {
            return 0;
        }
        
        // return the average offset
        return totalOffset/Double(counter);
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
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed, metByInstruction: index-1));
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
                                results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed, metByInstruction: index-1));
                                actionStart = storedAction.end;
                            } else {
                                // the candidate action was not the proper duration
                                results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                                actionStart = currentAction.end;
                            }
                        } else {
                            // no action satisfies the instruction
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
                            actionStart = currentAction.end;
                        }
                    } else {
                        // the action started too early to be considered for the current instruction
                        // increment the index since we will be moving to the next action
                        index = index + 1;
                    }
                }
            }
            
            currentAction = exercise.next();
        }
        
        // return the results array which stores the exercise data
        return results;
    }
    
    // analyze exercise performance where search window is after previous satisfying instruction rather than the 
    // previous exercise instruction that was met. This is a more dynamic approach to determining if instructions were met. 
    // It handles the situation where users breathe too long
    func analyzePerformanceModified(data: [breathingAction]) -> [breathingAction] {
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
                            results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed, metByInstruction: index-1));
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
                                results.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed, metByInstruction: index-1));
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
            
            // set the next action start to the
            actionStart = currentAction.end;
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
        
        // if the first instruction starts after the beginning of the exercise, fill in the beginning with the
        // alternate instruction
        if hexoskinData.count != 0 {
            let firstAction = hexoskinData[0];
            if firstAction.start > 0 {
                // prepend the alternate instruction before it
                if firstAction.action == Strings.inhale {
                    hexoskinData.insert(breathingAction(action: Strings.exhale, duration: firstAction.start, start: 0, end: firstAction.start), at: 0)
                } else if firstAction.action == Strings.exhale {
                    hexoskinData.insert(breathingAction(action: Strings.inhale, duration: firstAction.start, start: 0, end: firstAction.start), at: 0)
                }
            }
        }
        
        // if the last instruction ends before the end of the exercise, fill in the end with the alternate instruction
        if hexoskinData.count != 0 {
            let lastAction = hexoskinData[hexoskinData.count-1];
            if lastAction.end < Double(endTimestamp - startTimestamp)/256 {
                // append the alternate instruction
                if lastAction.action == Strings.inhale {
                    hexoskinData.append(breathingAction(action: Strings.exhale, duration: Double(endTimestamp - startTimestamp)/256 - lastAction.end, start: lastAction.end, end: Double(endTimestamp - startTimestamp)/256));
                } else if lastAction.action == Strings.exhale {
                    hexoskinData.append(breathingAction(action: Strings.inhale, duration: Double(endTimestamp - startTimestamp)/256 - lastAction.end, start: lastAction.end, end: Double(endTimestamp - startTimestamp)/256));
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
    
    
    func printData(data: [breathingAction], heading: String) {
        print("\n\(heading)");
        for action in data {
            print("\(action.action) \(action.duration)s start: \(action.start) end: \(action.end)");
        }
    }
    
    func isEven(number: Int) -> Bool {
        let remainder = number%2;
        if remainder == 0 {
            // number was even
            return true;
        } else {
            // number was odd 
            return false;
        }
    }


}
