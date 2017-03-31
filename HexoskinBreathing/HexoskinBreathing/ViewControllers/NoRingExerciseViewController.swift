//
//  NoRingExerciseViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/30/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit
import AVFoundation

class NoRingExerciseViewController: DataAnalyzingViewController {

    // UI Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var startInstructionLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var analyzeLabel: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    
    // exercise
//    var exercise: BreathingExercise!
    
    // colors
    let startButtonColor: UIColor = Constants.avocadoColor;
    let stopButtonColor: UIColor = Constants.phoneBoothRed;
    let analyzeButtonColor: UIColor = Constants.electricBlue;
    
    // the programmatically created label that displays the exercise description
    var exerciseLabel: UILabel!
    
//    // timestamps for the exercise
//    var startTimestamp: Int = -1;
//    var endTimestamp: Int = -1;
//    var recordID: Int = -1;
//    
//    // authorization variables
//    var accessToken: String!
//    var tokenType: String!
    
    // data storage
//    var breathingData: [breathingAction]!
//    var exerciseData: [breathingAction]!
//    var hexoskinData: [breathingAction]!
    
    // metronome members
    var metronome: Bool!
    var beepSound: URL!
    var audioPlayer: AVAudioPlayer!
    var metronomeTimer: Timer!
    
    // count up timer
    var timer: Timer!
    var time: Double = 0.0;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Exercise"; 
        
        // add back button to navigation bar
        addBackButton();
        
        // set the scrollview's color
        scrollView.backgroundColor = .white;
        scrollView.layer.cornerRadius = 8;
        scrollView.layer.borderColor = UIColor.black.cgColor;
        scrollView.layer.borderWidth = 3;
        
        // make the buttons rounded and have white text
        let buttons: [UIButton] = [startButton, stopButton, analyzeLabel];
        for button in buttons {
            button.layer.cornerRadius = 8;
            button.setTitleColor(.white, for: .normal);
        }
        
        // set the button colors
        analyzeLabel.backgroundColor = analyzeButtonColor;
        startButton.backgroundColor = startButtonColor;
        stopButton.backgroundColor = stopButtonColor;
        
        // fade the stop button slightly since it is not ready to be tapped
        stopButton.alpha = 0.5;
        stopButton.isUserInteractionEnabled = false;
        
        // fade the analyze button and label completely since these are not ready to be used
        analyzeLabel.alpha = 0.0;
        analyzeLabel.isUserInteractionEnabled = false;
        uploadLabel.alpha = 0.0;
        
        // initialize the timer label
        timerLabel.text = "0.0 s";
        
        if metronome == true {
            beepSound = URL(fileURLWithPath: Bundle.main.path(forResource: "beep", ofType: "wav")!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: beepSound);
                audioPlayer.prepareToPlay();
            } catch {
                print("Error initializing audio player.");
            }
        }
        
        // We are analyzing the Hexoskin and not the ring
        analyzingHexoskin = true;
        analyzingRing = false;
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        // add the exercise label to the scroll view
        exerciseLabel = UILabel();
        exerciseLabel.translatesAutoresizingMaskIntoConstraints = false;
        exerciseLabel.numberOfLines = 0;
        exerciseLabel.textAlignment = .left;
        exerciseLabel.backgroundColor = .clear;
        exerciseLabel.text = exercise.exerciseDescription();
        
        // calculate label height based on exercise description length
        let labelHeight = heightForView(text: exercise.exerciseDescription(), font: exerciseLabel.font, width: scrollView.frame.width);
        
        // constrain the view
        scrollView.addSubview(exerciseLabel);
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: exerciseLabel, attribute: .top, relatedBy: .equal, toItem: scrollView, attribute: .top, multiplier: 1.0, constant: 10));
        constraints.append(NSLayoutConstraint(item: exerciseLabel, attribute: .leading, relatedBy: .equal, toItem: scrollView, attribute: .leading, multiplier: 1.0, constant: 10));
        constraints.append(NSLayoutConstraint(item: exerciseLabel, attribute: .trailing, relatedBy: .equal, toItem: scrollView, attribute: .trailing, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: exerciseLabel, attribute: .bottom, relatedBy: .equal, toItem: scrollView, attribute: .bottom, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: exerciseLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelHeight));
        scrollView.addConstraints(constraints);
        
        // set the content size to make sure the view is scrollable to the end of the description
        scrollView.contentSize = CGSize(width: scrollView.frame.width, height: labelHeight);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        if metronome == true {
            
            if metronomeTimer != nil {
                metronomeTimer.invalidate();
            }
            
            // stop the audioPlayer
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
    }
    
    @IBAction func startPressed(_ sender: Any) {
        // save the start time
        startTimestamp = Int(Date().timeIntervalSince1970*256);
        
        // fade the start button and unfade the stop button
        startButton.alpha = 0.5;
        startButton.isUserInteractionEnabled = false;
        stopButton.alpha = 1.0;
        stopButton.isUserInteractionEnabled = true;
        startInstructionLabel.text = "Press stop after the exercise has been completed";
        
        // start the metronome
        if metronome == true {
            metronomeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.playBeep), userInfo: nil, repeats: true);
        }
        
        // start the count up timer
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: {
            _ in
            self.time += 1;
            let formattedTime = String.init(format: "%.1f s", self.time);
            self.timerLabel.text = formattedTime;
        })
    }
    
    func playBeep() {
        // play the beep sound
        audioPlayer.play()
    }
    
    @IBAction func stopPressed(_ sender: Any) {
        // save the end time
        endTimestamp = Int(Date().timeIntervalSince1970*256);
        
        // fade the stop button and the other labels that display the exercise
        stopButton.alpha = 0.5;
        stopButton.isUserInteractionEnabled = false;
        startInstructionLabel.alpha = 0.5;
        timerLabel.alpha = 0.5; 
        
        // reveal the analyze button and upload label
        analyzeLabel.isUserInteractionEnabled = true;
        analyzeLabel.alpha = 1.0;
        uploadLabel.alpha = 1.0;
        
        if metronome == true {
            if metronomeTimer != nil {
                metronomeTimer.invalidate();
            }
            if audioPlayer != nil && audioPlayer.isPlaying {
                audioPlayer.stop(); 
            }
        }
        
        if timer != nil {
            timer.invalidate();
        }
        
        // remove the back button and create a cancel button
        hideBackButton();
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(NoRingExerciseViewController.cancelPressed));
    }
    
    func cancelPressed() {
        // pop back to root
        _ = self.navigationController?.popToRootViewController(animated: true);
    }
    
    @IBAction func analyzePressed(_ sender: Any) {
        getRecordID(); 
    }
    
    // used for calculating the height of a label for a given a string
    func heightForView(text: String, font: UIFont, width: CGFloat) -> CGFloat {

        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: width, height: .greatestFiniteMagnitude));
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping;
        label.font = font
        label.text = text
        
        label.sizeToFit()
        return label.frame.height
        
    }
    
//    // function fired after the timer delay expires
//    func fetchResults() {
//        
//        // construct the request
//        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/data/", query: ["datatype__in" : "34,35", "record" : String(recordID), "start" : String(startTimestamp-512), "end" : String(endTimestamp+512)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
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
//                let dataDictionary = try JSONSerialization.jsonObject(with: data);
//                let dataResponse = try DataResponse(json: dataDictionary);
//                self.hexoskinData = self.getExerciseBreathingData(inhalationStarts: dataResponse.returnedData["34"]!, expirationStarts: dataResponse.returnedData["35"]!);
//                
//                // at this point, the exercise and results are both stored as member variables.
//                // the following function uses those members to determine how well the user followed
//                // the prescribed exercise. it saves the r
//                self.analyzeExercisePerformance(data: self.hexoskinData);
//                
//                // push the next view controller on the main queue
//                DispatchQueue.main.async {
//                    // consolidate the data and prepare to send it to the next controller where
//                    // the data will be displayed in a table
//                    let storyboard = UIStoryboard(name: "Main", bundle: nil);
//                    let viewController = storyboard.instantiateViewController(withIdentifier: "dataViewController") as? DataViewingViewController;
//                    viewController?.exerciseData = self.exerciseData;
//                    viewController?.hexoskinData = self.hexoskinData;
//                    viewController?.ringData = nil;
//                    viewController?.displayHexData = true;
//                    viewController?.displayRingData = false;
//                    viewController?.exerciseDuration = self.exercise.exerciseDuration;
//                    self.navigationController?.pushViewController(viewController!, animated: true);
//                }
//                
//                
//            } catch JSONParsingError.parsingError {
//                // the user was uploading the data, but the upload was not complete
//                // create an alert on the main thread
//                DispatchQueue.main.async {
//                    // indicate here that the data has not been uploaded correctly
//                    let alert = UIAlertController(title: "Data sync in progress", message: "Try pressing the button again in a few seconds ", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
//                    self.present(alert, animated: true, completion: nil)
//                }
//                
//            } catch {
//                print("CASTING ERROR");
//            }
//        }
//        task.resume()
//    }
//    
//    func getRecordID() {
//        
//        // construct the request
//        let request = ApiHelper.generateRequest(url: "https://api.hexoskin.com/api/record/", query: ["end__gte":String(startTimestamp) ,"start__lte":String(endTimestamp)], headers: ["Authorization" : "\(tokenType!) \(accessToken!)"]);
//        
//        
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
//                let objectsArray = dataDictionary?["objects"] as? [Any];
//                if objectsArray?.count == 1 {
//                    // there is only 1 record so the filtering worked
//                    let recordDictionary = objectsArray?[0] as? [String:Any];
//                    let id = recordDictionary?["id"] as? Int;
//                    self.recordID = id!;
//                    self.fetchResults();
//                } else {
//                    // present alert on main thread
//                    DispatchQueue.main.async {
//                        // indicate here that the data has not been uploaded correctly
//                        let alert = UIAlertController(title: "Data not found", message: "Ensure that the data has been uploaded to the Hexoskin Services using HxServices.", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil));
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            } catch {
//                print("CASTING ERROR");
//            }
//        }
//        
//        task.resume()
//    }
//    
//    // use the exercise and passed data arrays of breathingActions to analyze the performance
//    func analyzeExercisePerformance(data: [breathingAction]) {
//        
//        // set the start of the first action to 0
//        var actionStart: Double = 0.0;
//        
//        // initialize a container to hold the performance results
//        exerciseData = [];
//        
//        // reset the exercise so that we can easily iterate through it
//        exercise.reset();
//        
//        // save the index of the current breathing action
//        var index: Int = 0;
//        
//        // create a variable that will be used to store actions temporarily
//        var storedAction: breathingAction! = nil;
//        
//        // iterate through the exercise
//        var currentAction = exercise.next();
//        while currentAction.action != Strings.notAnAction {
//            
//            // find the breathing action that has the latest start but still starts within 2 seconds +/-
//            // ...of the current instruction
//            // clear the temporary variable that stores the action
//            storedAction = nil;
//            var condition: Bool = true;
//            while condition {
//                if index >= data.count {
//                    // there are no more breathing actions
//                    condition = false;
//                    
//                    // check to see if the previous loop found a candidate
//                    if storedAction != nil {
//                        // the storedAction's duration needs to be checked to see if it satisfies the instruction
//                        if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError {
//                            // the storedAction satisfies the instruction
//                            exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
//                        } else {
//                            // the last candidate's duration was not long enough
//                            exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
//                        }
//                    } else {
//                        // no action satisfies the instruction
//                        exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
//                    }
//                    
//                } else {
//                    
//                    let action = data[index];
//                    if Double(action.start) < actionStart + Constants.startBreathSearchWindow && Double(action.start) > actionStart - Constants.startBreathSearchWindow {
//                        // this is a candidate to be the action that satisfies the instruction
//                        
//                        // verify that the actions are both inhale or exhale
//                        if action.action == currentAction.action {
//                            // instructions are the same
//                            
//                            // store this action
//                            storedAction = action;
//                        }
//                        
//                        // increment the index since we will be moving to the next action
//                        index = index + 1;
//                        
//                    } else if Double(action.start) > actionStart + Constants.startBreathSearchWindow {
//                        // none of the following actions will satisfy the instruction
//                        condition = false;
//                        
//                        // check to see if the previous loop found a candidate
//                        if storedAction != nil {
//                            // the storedAction's duration needs to be checked to see if it satisfies the instruction
//                            if Double(storedAction.duration) > currentAction.duration - Constants.breathLengthAllowableError {
//                                // the storedAction satisfies the instruction
//                                exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.completed));
//                            } else {
//                                // the candidate action was not the proper duration
//                                exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
//                            }
//                        } else {
//                            // no action satisfies the instruction
//                            exerciseData.append(breathingAction(action: currentAction.action, duration: currentAction.duration, start: currentAction.start, end: currentAction.end, status: Strings.notCompleted));
//                        }
//                    } else {
//                        // the action started too early to be considered for the current instruction
//                        // increment the index since we will be moving to the next action
//                        index = index + 1;
//                    }
//                }
//            }
//            
//            actionStart = actionStart + currentAction.duration;
//            currentAction = exercise.next();
//        }
//        
//    }
//
//    func getExerciseBreathingData(inhalationStarts: [(Double, Double)], expirationStarts: [(Double, Double)]) -> [breathingAction] {
//        
//        // verify that the arrays are not empty
//        if inhalationStarts.count == 0 || expirationStarts.count == 0 {
//            print("Array parameter is empty.");
//            return [];
//        }
//        
//        // initialize the return array
//        var hexoskinData: [breathingAction] = [];
//        var action: breathingAction!
//        
//        // first find out if the first action is an inhale or exhale
//        let difference = inhalationStarts[0].0 - expirationStarts[0].0;
//        if difference < 0 {
//            // first action is inhale
//            for index in 0...inhalationStarts.count {
//                // check if there is an inspiration
//                if index < expirationStarts.count {
//                    action = breathingAction(action: "Inhale", duration: (expirationStarts[index].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256);
//                    hexoskinData.append(action);
//                    
//                    // check if there is another expiration
//                    if index + 1 < inhalationStarts.count {
//                        action = breathingAction(action: "Exhale", duration: (inhalationStarts[index+1].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(inhalationStarts[index+1].0)/256 - Double(startTimestamp)/256);
//                        hexoskinData.append(action);
//                    }
//                }
//            }
//        } else if difference > 0 {
//            // first action is exhale
//            for index in 0...expirationStarts.count {
//                // check if there is an inspiration
//                if index < inhalationStarts.count {
//                    action = breathingAction(action: "Exhale", duration: (inhalationStarts[index].0-expirationStarts[index].0)/256, start: Double(expirationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256);
//                    hexoskinData.append(action);
//                    
//                    // check if there is another expiration
//                    if index + 1 < inhalationStarts.count {
//                        action = breathingAction(action: "Inhale", duration: (expirationStarts[index+1].0-inhalationStarts[index].0)/256, start: Double(inhalationStarts[index].0)/256 - Double(startTimestamp)/256, end: Double(expirationStarts[index+1].0)/256 - Double(startTimestamp)/256);
//                        hexoskinData.append(action);
//                    }
//                }
//            }
//        } else {
//            // exhale and inhale can't begin at same time
//            print("Exhale and inhale can't begin at same time. Error in data.");
//            return [];
//        }
//        
//        // prune the hexoskinData array by removing actions that end before 1 second past the start
//        var frontPruningComplete: Bool = false;
//        while !frontPruningComplete {
//            let action = hexoskinData[0];
//            if Double(action.end) < 1 {
//                // remove the action since it ends before the exercise really starts
//                hexoskinData.remove(at: 0);
//            } else {
//                frontPruningComplete = true;
//            }
//        }
//        
//        // prune the hexoskinData array by removing actions that start after 1 second before the end of the last instruction
//        var backPruningComplete: Bool = false;
//        var index = 0;
//        while !backPruningComplete {
//            
//            // verify the index is valid
//            if index >= hexoskinData.count {
//                // invalid index
//                // exit the loop
//                backPruningComplete = true;
//            } else {
//                // valid index
//                // verify that the action falls inside the exercise timestamps
//                let action = hexoskinData[index];
//                if Double(action.start) > exercise.exerciseDuration - 1 {
//                    // remove the action since it starts basically at the end of the exercise
//                    hexoskinData.remove(at: index);
//                } else {
//                    // if the action is not removed, increment the index
//                    index = index + 1;
//                }
//            }
//            
//        }
//        
//        return hexoskinData;
//    }
    
}
