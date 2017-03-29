//
//  ExerciseViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit
import AVFoundation

struct InstructionDisplay {
    var label: UILabel!
    var timerLabel: UILabel!
    var labelVerticalConstraint: NSLayoutConstraint!
    var labelHorizontalConstraint: NSLayoutConstraint!
    var timerLabelHorizontalConstraint: NSLayoutConstraint!
    var duration: Double = 0.0;
}

class ExerciseViewController: MRRViewController {
    
    // colors for ui elements
    let beginButtonColor: UIColor = Constants.avocadoColor;
    let queuedInstructionTextColor: UIColor = Constants.electricBlue;
    let currentInstructionTextColor: UIColor = Constants.avocadoColor
    let borderColor: UIColor = Constants.phoneBoothRed;
    let continueButtonColor: UIColor = Constants.electricBlue;
    let exerciseCompletedTextColor: UIColor = Constants.electricBlue;
    
    
    
    // view that house all of the instructions
    @IBOutlet weak var instructionParentView: UIView!
    
    // label outlets for the instructions
    @IBOutlet weak var fifthInstructionLabel: UILabel!
    @IBOutlet weak var fourthInstructionLabel: UILabel!
    @IBOutlet weak var thirdInstructionLabel: UILabel!
    @IBOutlet weak var secondInstructionLabel: UILabel!
    @IBOutlet weak var firstInstructionLabel: UILabel!
    
    // label vertical constraints from the top
    @IBOutlet weak var fifthVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstVerticalConstraint: NSLayoutConstraint!
    
    // label horizontal constraints from left
    @IBOutlet weak var fifthHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstHorizontalConstraint: NSLayoutConstraint!
    
    // label outlets for the instruction timer labels
    @IBOutlet weak var fifthTimerLabel: UILabel!
    @IBOutlet weak var fourthTimerLabel: UILabel!
    @IBOutlet weak var thirdTimerLabel: UILabel!
    @IBOutlet weak var secondTimerLabel: UILabel!
    @IBOutlet weak var firstTimerLabel: UILabel!
    
    
    // instruction timer labels horizontal contstraints from right
    @IBOutlet weak var fifthInstructionTimerHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var fourthInstructionTimerHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var thirdInstructionTimerHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var secondInstructionTimerHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet weak var firstInstructionTimerHorizontalConstraint: NSLayoutConstraint!
    
    // Timer label that sits in the middle of the wheel
//    @IBOutlet weak var timerLabel: UILabel!
 
    // imageview that stores the wheel
    @IBOutlet weak var imageView: UIImageView!
    
    // array that stores the instructionDisplays with all of the information needed for instructions
    var instructionDisplays: [InstructionDisplay]!
    
    // constants
    let queuedInstructionTextSize: CGFloat = 20.0;
    let currentInstructionTextSize: CGFloat = 30.0;
    let exerciseCompleteIndicator: String = "Complete";
    
    
    var circleCenter : CGPoint!
    
    var state: Int!
    
    var panRecognizer = ImmediatePanGestureRecognizer() // recognizer for sliding the button up the bar
    
    var beginButton: UIButton!
    var blurEffectView: UIVisualEffectView!
    
    var currentLabel: Int!
    
    var exercise: BreathingExercise!
    
    var alreadyFinished: Bool!
    
    var currentTimerCounter: Double!
    var counterTimer: Timer!
    var instructionTimer: Timer!
    let countDownInterval: Double = 1.0;
    var metronomeTimer: Timer!
    
    // variables that store the start and end timestamps for the exercise
    var startTimestamp: Int = 0;
    var endTimestamp: Int = 0;
    
    // token information used for REST API calls
    var accessToken: String!
    var tokenType: String!
    
    // used for playing beep sound
    var beepSound: URL!
    var audioPlayer: AVAudioPlayer!
    
    // boolean used for checking when the exercise begins
    var exerciseBegan: Bool = false;
    
    var previousAngle: Float = 0.0;
    var rotatingClockwise: Bool!
    var startOfCurrentAction: Double!
    var timeOfRingRelease: Double!
    var exerciseEnded: Bool = false;
    var lastActionCaptured: Bool = false;
    var ringActions: [breathingAction] = []; 

    // boolean used for determining whether to play the metronome or not
    var playMetronome: Bool = false;
    
    // values stored for repositioning the instruction views
    let distanceBetweenQueuedInstructionViews = 50;
    let addedDistanceToCurrentInstructionView = 20;
    let topInstructionViewStartingPosition = -25; // this is the invisible view that will be shifted down next
    let instructionLabelHeight = 38; // make sure this is the same as in IB (Not best design, should be fixed)
    let currentInstructionBorderLineWidth = 3;
    let distanceBetweenBorderLineAndCurrentInstruction = 5;
    
    // border line views
    var topBorderLine: UIView!
    var bottomBorderLine: UIView!
    
    // indicate signed in
    var signedIn: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title for the nav bar
        title = "Exercise";
        self.addBackButton()
        
        // initialize wheel image and add gesture recognizer
        imageView.image = UIImage(named: "pause_wheel.png");
        state = 1;
        panRecognizer = ImmediatePanGestureRecognizer(target: self, action: #selector(ExerciseViewController.imageViewPanned(sender:)));
        imageView.addGestureRecognizer(panRecognizer);
        imageView.isUserInteractionEnabled = true;
        
        alreadyFinished = false;
        
        if playMetronome {
            beepSound = URL(fileURLWithPath: Bundle.main.path(forResource: "beep", ofType: "wav")!)
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: beepSound);
                audioPlayer.prepareToPlay();
            } catch {
                print("Error initializing audio player.");
            }
        }
    }
    
    override func loadView() {
        super.loadView();
        
        // apply a blur before the exercise begins
        addBlurView();
        
        // add begin button
        addBeginButton();
    
        // init constraints and text for instruction labels
        initInstructionDisplays();
        
    }
    
    override func viewDidLayoutSubviews() {
        // store the center of the imageview to be used for detecting distances of taps on the ring
        circleCenter = CGPoint(x: imageView.frame.origin.x + imageView.frame.size.width/2, y: imageView.frame.origin.y + imageView.frame.size.height/2);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.showNavigationBar();
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        // invalidate the timers and stop the exercise
        if instructionTimer != nil {
            instructionTimer.invalidate();
        }
        if counterTimer != nil {
            counterTimer.invalidate();
        }
        if playMetronome {
            
            if metronomeTimer != nil {
                metronomeTimer.invalidate();
            }
            
            // stop the audioPlayer
            if audioPlayer.isPlaying {
                audioPlayer.stop()
            }
        }
    }
    
    func imageViewPanned(sender:UIPanGestureRecognizer) {
        switch(sender.state) {
        case UIGestureRecognizerState.began:
            // Store the starting vertical position for the pan so we can find the vertical change
            //            let point: CGPoint = sender.translation(in: self.view);
            let point: CGPoint = sender.location(in: view);
            let dist = distance(firstPoint: point, secondPoint: self.circleCenter);
            var angle = getAngle(centralPoint: self.circleCenter, secondPoint: point);
            
            angle = angle - 90;
            if angle < 0 {
                angle = angle + 360;
            }
            
            previousAngle = angle;
            
            if dist < 70 || dist > 105 {
                sender.state = UIGestureRecognizerState.cancelled;
            } else {
                UIView.animate(withDuration: 0.1, animations: {
                    self.imageView.transform = CGAffineTransform(rotationAngle: -(CGFloat(angle) * CGFloat(M_PI) / 180.0))
                })
            }
            
            // save the time when the action began
            if !exerciseEnded {
                let date = Date();
                startOfCurrentAction = date.timeIntervalSince1970;
                if timeOfRingRelease != nil {
                    // this last action was a pause with no indication
                    // save the times and calculate the duration of the pause
                    let action = breathingAction(action: "Pause", duration: startOfCurrentAction - timeOfRingRelease, start: timeOfRingRelease - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                    ringActions.append(action);
                }
            }
            
            break;
        case UIGestureRecognizerState.changed:
            let point: CGPoint = sender.location(in: view);
            var angle = getAngle(centralPoint: self.circleCenter, secondPoint: point);
            
            angle = angle - 90;
            if angle < 0 {
                angle = angle + 360;
            }
            
            // check if moving cw or ccw
            if !lastActionCaptured {
                if exerciseEnded {
                    // exercise is over. record the last action and then prevent other actions from
                    // being captured
                    if rotatingClockwise != nil {
                        lastActionCaptured = true;
                        if rotatingClockwise == true {
                            let actionEndTime = Date().timeIntervalSince1970;
                            let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                            ringActions.append(action);
                        } else {
                            let actionEndTime = Date().timeIntervalSince1970;
                            let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                            ringActions.append(action);
                        }
                    }
                } else if previousAngle - angle > 0 || previousAngle - angle < -300 {
                    // clockwise
                    if rotatingClockwise == nil {
                        // check to see if the exercise has started yet
                        if exerciseBegan {
                            // this is the first action
                            rotatingClockwise = true;
                            
                            // save the start time here
                            startOfCurrentAction = Date().timeIntervalSince1970;
                        }
                        
                    } else if rotatingClockwise == false {
                        // the previous counter clockwise action just ended
                        // save the times and calculate the duration
                        rotatingClockwise = true;
                        let date = Date();
                        let actionEndTime = date.timeIntervalSince1970;
                        let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                        ringActions.append(action);
                        startOfCurrentAction = actionEndTime;
                    }
                    
                } else {
                    // counter clockwise
                    if rotatingClockwise == nil {
                        if exerciseBegan {
                            // this is the first action
                            rotatingClockwise = false;
                            
                            // save the start time here
                            startOfCurrentAction = Date().timeIntervalSince1970;
                        }
                        
                    } else if rotatingClockwise == true {
                        // the previous clockwise action just ended
                        // save the times and calculate the duration
                        rotatingClockwise = false;
                        let date = Date();
                        let actionEndTime = date.timeIntervalSince1970;
                        let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                        ringActions.append(action);
                        startOfCurrentAction = actionEndTime;
                    }
                    
                }
            }
            previousAngle = angle;
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform(rotationAngle: -(CGFloat(angle) * CGFloat(M_PI) / 180.0))
            })
            break;
        default:
            // this default should catch state ended and cancelled
            
            // determine which action just terminated and save the info
            if !lastActionCaptured {
                if rotatingClockwise == nil {
                    // enters here if the action is ending before the exercise even started
                } else if rotatingClockwise == true {
                    // the last action was clockwise
                    // save the info for clockwise
                    let date = Date();
                    let actionEndTime = date.timeIntervalSince1970;
                    let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                    ringActions.append(action);
                    startOfCurrentAction = actionEndTime;
                    timeOfRingRelease = actionEndTime;
                    
                } else if rotatingClockwise == false {
                    // the last action was counterclockwise
                    // save the info for counterclockwise
                    let date = Date();
                    let actionEndTime = date.timeIntervalSince1970;
                    let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment, end: actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustment);
                    ringActions.append(action);
                    startOfCurrentAction = actionEndTime;
                    timeOfRingRelease = actionEndTime;
                    
                }
            }
            
            break;
        }
        
    }
    
    func beginExercise() {
        // remove blurring view and begin button
        blurEffectView.removeFromSuperview();
        beginButton.removeFromSuperview();
        
        // add border lines for current instruction
        addCurrentInstructionBorderLines();
        
        // initialize the instruction labels with the instructions and their durations
        // initialize the first/current instruction label with starting exercise indicator
        instructionDisplays[0].label.text = "Starting in: ";
        instructionDisplays[0].timerLabel.text = "3.0 s";
        instructionDisplays[0].duration = 3.0;
        instructionDisplays[0].label.font = instructionDisplays[0].label.font.withSize(currentInstructionTextSize);
        instructionDisplays[0].timerLabel.font = instructionDisplays[0].timerLabel.font.withSize(currentInstructionTextSize);
        instructionDisplays[0].label.textColor = currentInstructionTextColor;
        instructionDisplays[0].timerLabel.textColor = currentInstructionTextColor;

        
        var action: breathingAction!
        for index in 1...4 {
            // get the next instruction from the exercise
            action = exercise.next();
            
            instructionDisplays[index].label.font = instructionDisplays[index].label.font.withSize(queuedInstructionTextSize);
            instructionDisplays[index].timerLabel.font = instructionDisplays[index].timerLabel.font.withSize(queuedInstructionTextSize);
            instructionDisplays[index].label.textColor = queuedInstructionTextColor;
            instructionDisplays[index].timerLabel.textColor = queuedInstructionTextColor;
            if action.action != Strings.notAnAction {
                instructionDisplays[index].label.text = action.action;
                instructionDisplays[index].timerLabel.text = String(format: "%.1f s", action.duration);
                instructionDisplays[index].duration = action.duration;
            } else {
                instructionDisplays[index].label.text = exerciseCompleteIndicator;
                instructionDisplays[index].timerLabel.text = "--";
                self.alreadyFinished = true; 
                break; 
            }
        }
        
        // the fifth instruction display should be invisible to begin with
        instructionDisplays[4].label.alpha = 0;
        instructionDisplays[4].timerLabel.alpha = 0;
        
        // set the current label to be the one in position 0 in the instructionDisplays array
        currentLabel = 0;
        
        // make the fifth label invisible
        instructionDisplays[4].label.alpha = 0;
                
        // begin timer
        instructionTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(ExerciseViewController.timerEnded), userInfo: nil, repeats: false);
        currentTimerCounter = 3.0;
        counterTimer = Timer.scheduledTimer(timeInterval: TimeInterval(countDownInterval), target: self, selector: #selector(ExerciseViewController.countdown), userInfo: nil, repeats: true);
        
        // begin another timer that plays the beep sound every second
        if playMetronome {
            metronomeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.playBeep), userInfo: nil, repeats: true);
        }
    }
    
    func playBeep() {
        // play the beep sound
        audioPlayer.play()
    }
    
    func timerEnded() {
        
        // check if this is the first time entering. if so, the exercise is just beginning, 
        // so save the timestamp
        if !exerciseBegan {
            // store start timestamp
            let date = Date();
            startTimestamp = Int((date.timeIntervalSince1970-Constants.exerciseStartTimeAdjustment)*256);
            exerciseBegan = true; 
        }
        
        // start next timer here
        if getDisplayInPosition(position: 1).label.text != exerciseCompleteIndicator {
            self.currentTimerCounter = getDisplayInPosition(position: 1).duration;
            instructionTimer = Timer.scheduledTimer(timeInterval: TimeInterval(getDisplayInPosition(position: 1).duration), target: self, selector: #selector(ExerciseViewController.timerEnded), userInfo: nil, repeats: false);
            
            // reset the countdown timer here
            counterTimer.invalidate();
            getDisplayInPosition(position: 0).timerLabel.text = "0.0 s";
            counterTimer = Timer.scheduledTimer(timeInterval: TimeInterval(countDownInterval), target: self, selector: #selector(ExerciseViewController.countdown), userInfo: nil, repeats: true);
            
        } else {
            // Exercise has ended
            exerciseEnded = true;
            counterTimer.invalidate();
            
            if playMetronome {
                metronomeTimer.invalidate();
            }
            
            // store the end time
            let date = Date();
            endTimestamp = Int(date.timeIntervalSince1970*256);
            
            // delay for 2 seconds before going to the results controller
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.addNextButton), userInfo: nil, repeats: false);
            
        }
        
        // set new destinations for the instruction displays
        for index in 0...4 {
            getDisplayInPosition(position: index).labelVerticalConstraint.constant += 50;
        }
        getDisplayInPosition(position: 1).labelVerticalConstraint.constant += 20; // make the final instruction push down further
        
        // display the appropriate wheel
        let nextAction = self.getDisplayInPosition(position: 1).label.text;
        if nextAction == "Inhale" {
            self.imageView.image = UIImage(named: "cw_wheel.png");
        } else if nextAction == "Exhale" {
            self.imageView.image = UIImage(named: "ccw_wheel.png");
        } else {
            self.imageView.image = UIImage(named: "pause_wheel.png");
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            self.getDisplayInPosition(position: 0).label.alpha = 0.0;
            self.getDisplayInPosition(position: 0).timerLabel.alpha = 0.0;
            self.getDisplayInPosition(position: 1).label.textColor = self.currentInstructionTextColor;
            self.getDisplayInPosition(position: 1).label.font = self.getDisplayInPosition(position: 1).label.font.withSize(self.currentInstructionTextSize);
            self.getDisplayInPosition(position: 1).timerLabel.textColor = self.currentInstructionTextColor;
            self.getDisplayInPosition(position: 1).timerLabel.font = self.getDisplayInPosition(position: 1).label.font.withSize(self.currentInstructionTextSize);
            self.getDisplayInPosition(position: 4).label.alpha = 1.0;
            self.getDisplayInPosition(position: 4).timerLabel.alpha = 1.0;
            self.incCurrentLabel();
            self.view.layoutIfNeeded();
        }, completion: { (myBool) in
            // load up the hidden display with the next instruction and move it into the correct position at the top
            let nextAction = self.exercise.next();
            if self.alreadyFinished == true {
                self.getDisplayInPosition(position: 4).label.text = "";
                self.getDisplayInPosition(position: 4).timerLabel.text = "";
            } else if nextAction.action == Strings.notAnAction {
                self.getDisplayInPosition(position: 4).label.text = self.exerciseCompleteIndicator;
                self.getDisplayInPosition(position: 4).timerLabel.text = "--";
                self.alreadyFinished = true;
            } else {
                self.getDisplayInPosition(position: 4).label.text = nextAction.action;
                self.getDisplayInPosition(position: 4).timerLabel.text = String(format: "%.1f s", nextAction.duration);
            }
            
            self.getDisplayInPosition(position: 4).label.textColor = self.queuedInstructionTextColor;
            self.getDisplayInPosition(position: 4).label.font = self.getDisplayInPosition(position: 4).label.font.withSize(self.queuedInstructionTextSize);
            self.getDisplayInPosition(position: 4).timerLabel.textColor = self.queuedInstructionTextColor;
            self.getDisplayInPosition(position: 4).timerLabel.font = self.getDisplayInPosition(position: 4).label.font.withSize(self.queuedInstructionTextSize);
            
            // the following instruction is different bc modification of the struct requires direct access since function getDisplayInPosition returns a copy
            self.instructionDisplays[self.getDisplayNumber(position: 4)].duration = nextAction.duration;
            
            self.getDisplayInPosition(position: 4).labelVerticalConstraint.constant += -270;
            self.view.layoutIfNeeded();
        })
    }
    
    func addCurrentInstructionBorderLines() {
        topBorderLine = UIView();
        self.view.addSubview(topBorderLine);
        topBorderLine.backgroundColor = borderColor;
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false;
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .leading, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(currentInstructionBorderLineWidth)));
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .trailing, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .trailing, multiplier: 1.0, constant: 0));
        let topBorderLineDistanceToTop = CGFloat(4*distanceBetweenQueuedInstructionViews+topInstructionViewStartingPosition+addedDistanceToCurrentInstructionView-currentInstructionBorderLineWidth-distanceBetweenBorderLineAndCurrentInstruction)
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .top, relatedBy: .equal, toItem: instructionParentView, attribute: .top, multiplier: 1.0, constant: topBorderLineDistanceToTop));
        
        bottomBorderLine = UIView();
        self.view.addSubview(bottomBorderLine);
        bottomBorderLine.backgroundColor = borderColor;
        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false;
        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .leading, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(currentInstructionBorderLineWidth)));
        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .trailing, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .trailing, multiplier: 1.0, constant: 0));
        let bottomBorderLineDistanceToTop = CGFloat(4*distanceBetweenQueuedInstructionViews+topInstructionViewStartingPosition+addedDistanceToCurrentInstructionView+distanceBetweenBorderLineAndCurrentInstruction+instructionLabelHeight)
        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .top, relatedBy: .equal, toItem: instructionParentView, attribute: .top, multiplier: 1.0, constant: bottomBorderLineDistanceToTop));
        self.view.addConstraints(constraints);
    }
    
    func removeCurrentInstructionBorderLines() {
        topBorderLine.removeFromSuperview();
        bottomBorderLine.removeFromSuperview();
    }
    
    func addNextButton() {
        
        // clear the instruction views and indicate completed
        removeCurrentInstructionBorderLines();
        self.getDisplayInPosition(position: 0).label.text = "";
        self.getDisplayInPosition(position: 0).timerLabel.text = "";
        let completedLabel = UILabel();
        completedLabel.translatesAutoresizingMaskIntoConstraints = false;
        completedLabel.numberOfLines = 0;
        completedLabel.backgroundColor = .clear;
        completedLabel.textAlignment = .center;
        completedLabel.textColor = exerciseCompletedTextColor;
        completedLabel.text = "Exercise\nCompleted";
        completedLabel.font = completedLabel.font.withSize(35);
        instructionParentView.addSubview(completedLabel);
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .leading, relatedBy: .equal, toItem: instructionParentView, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 90));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .trailing, relatedBy: .equal, toItem: instructionParentView, attribute: .trailing, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .bottom, relatedBy: .equal, toItem: instructionParentView, attribute: .centerY, multiplier: 1.0, constant: -10));
        
        // add next button right below the completed label
//        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(ExerciseViewController.pushResultsController));
        let nextButton = UIButton();
        nextButton.translatesAutoresizingMaskIntoConstraints = false;
        nextButton.isUserInteractionEnabled = true;
        nextButton.addTarget(self, action: #selector(ExerciseViewController.pushResultsController), for: .touchUpInside);
        instructionParentView.addSubview(nextButton);
        nextButton.setTitleColor(Constants.basicTextColor, for: .normal);
        nextButton.backgroundColor = continueButtonColor;
        nextButton.layer.cornerRadius = 8;
        nextButton.setTitle("Continue", for: .normal);
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .centerX, relatedBy: .equal, toItem: instructionParentView, attribute: .centerX, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40));
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .top, relatedBy: .equal, toItem: instructionParentView, attribute: .centerY, multiplier: 1.0, constant: 20));
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120));
        instructionParentView.addConstraints(constraints);

        
    }
    
    func pushResultsController() {
        
        // instantiate the view controller from interface builder
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "analysisPreparationViewController") as? AnalysisPreparationViewController;
                
        // send the timestamps to the next view controller for result viewing
        viewController?.startTimestamp = startTimestamp;
        viewController?.endTimestamp = endTimestamp;
        viewController?.accessToken = accessToken;
        viewController?.tokenType = tokenType;
        viewController?.exercise = exercise;
        viewController?.ringActions = ringActions;
        viewController?.signedIn = signedIn; 
        self.navigationController?.pushViewController(viewController!, animated: true);
    }
    
    /*
     Function that executes whenever the countdownTimer fires. This function calculates
     the time left during the execution of the current instruction and displays it as
     feedback for the user.
    */
    func countdown() {
        if currentTimerCounter - countDownInterval < 0.0 {
            // The intruction has been completed and the clock should show 0 seconds left
            getDisplayInPosition(position: 0).timerLabel.text = "0.0 s";
        } else {
            // The instruction has not been completed and the clock should be updated to
            // the time remaining
            getDisplayInPosition(position: 0).timerLabel.text = String(format: "%.1f s", currentTimerCounter - countDownInterval);
            currentTimerCounter = currentTimerCounter - countDownInterval;
        }
    }
    
    
    func distance(firstPoint: CGPoint, secondPoint: CGPoint) -> Float {
        let x1 = Float(firstPoint.x);
        let x2 = Float(secondPoint.x);
        let y1 = Float(firstPoint.y);
        let y2 = Float(secondPoint.y);
        return sqrt(powf(x2-x1,2) + powf(y2-y1,2));
    }
    
    func getAngle(centralPoint: CGPoint, secondPoint: CGPoint) -> Float {
        let x1 = Float(centralPoint.x);
        let x2 = Float(secondPoint.x);
        let y1 = Float(centralPoint.y);
        let y2 = Float(secondPoint.y);
        let xdelta = x2-x1;
        let ydelta = y2-y1;
        let pi = Float(M_PI);
        let baseAngle = atan(ydelta/xdelta)*180/pi;
        
        if xdelta > 0 {
            if ydelta > 0 {
                // bottom right quadrant
                return 360 - baseAngle;
            } else {
                // top right quadrant
                return -1 * baseAngle;
            }
        } else {
            if ydelta < 0 {
                // top left quadrant
                return 180 - baseAngle;
            } else {
                // bottom left quadrant
                return 180 + -1 * baseAngle;
            }
        }
    }

    func incCurrentLabel() {
        currentLabel = currentLabel + 1;
        if currentLabel == 5 {
            currentLabel = 0;
        }
    }
    
    func getDisplayInPosition(position: Int) -> InstructionDisplay {
        var returnPosition = position + self.currentLabel;
        if returnPosition >= 5 {
            returnPosition = returnPosition - 5;
        }
        return instructionDisplays[returnPosition];
    }
    
    func getDisplayNumber(position: Int) -> Int {
        var returnPosition = position + self.currentLabel;
        if returnPosition >= 5 {
            returnPosition = returnPosition - 5;
        }
        return returnPosition;
    }
    
    func addBlurView() {
        //only apply the blur if the user hasn't disabled transparency effects
        if !UIAccessibilityIsReduceTransparencyEnabled() {
            self.view.backgroundColor = UIColor.white
            
            let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.dark)
            blurEffectView = UIVisualEffectView(effect: blurEffect)
            //always fill the view
            blurEffectView.frame = self.view.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            self.view.addSubview(blurEffectView)
            
        } else {
            self.view.backgroundColor = UIColor.black
        }
    }
    
    func addBeginButton() {
        // now add a begin button
        beginButton = UIButton(frame: CGRect.zero);
        self.view.addSubview(beginButton);
        beginButton.layer.cornerRadius = 8;
        beginButton.titleLabel?.font = beginButton.titleLabel?.font.withSize(30);
        beginButton.addTarget(self, action: #selector(ExerciseViewController.beginExercise), for: .touchUpInside);
        beginButton.translatesAutoresizingMaskIntoConstraints = false;
        let horizontalConstraint = NSLayoutConstraint(item: beginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0);
        let verticalConstraint = NSLayoutConstraint(item: beginButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0);
        let widthConstraint = NSLayoutConstraint(item: beginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 150);
        let heightConstraint = NSLayoutConstraint(item: beginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50);
        let constraints = [horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint];
        self.view.addConstraints(constraints);
        beginButton.setTitle("Begin", for: .normal);
        beginButton.setTitleColor(Constants.basicTextColor, for: .normal)
        beginButton.backgroundColor = Constants.basicButtonBackgroundColor;
    }
    
    func initInstructionDisplays() {
        // initialize the array of instruction labels
        let display1 = InstructionDisplay(label: firstInstructionLabel, timerLabel: firstTimerLabel, labelVerticalConstraint: firstVerticalConstraint, labelHorizontalConstraint: firstHorizontalConstraint, timerLabelHorizontalConstraint: firstInstructionTimerHorizontalConstraint, duration: 0.0);
        let display2 = InstructionDisplay(label: secondInstructionLabel, timerLabel: secondTimerLabel, labelVerticalConstraint: secondVerticalConstraint, labelHorizontalConstraint: secondHorizontalConstraint, timerLabelHorizontalConstraint: secondInstructionTimerHorizontalConstraint, duration: 0.0);
        let display3 = InstructionDisplay(label: thirdInstructionLabel, timerLabel: thirdTimerLabel, labelVerticalConstraint: thirdVerticalConstraint, labelHorizontalConstraint: thirdHorizontalConstraint, timerLabelHorizontalConstraint: thirdInstructionTimerHorizontalConstraint, duration: 0.0);
        let display4 = InstructionDisplay(label: fourthInstructionLabel, timerLabel: fourthTimerLabel, labelVerticalConstraint: fourthVerticalConstraint, labelHorizontalConstraint: fourthHorizontalConstraint, timerLabelHorizontalConstraint: fourthInstructionTimerHorizontalConstraint, duration: 0.0);
        let display5 = InstructionDisplay(label: fifthInstructionLabel, timerLabel: fifthTimerLabel, labelVerticalConstraint: fifthVerticalConstraint, labelHorizontalConstraint: fifthHorizontalConstraint, timerLabelHorizontalConstraint: fifthInstructionTimerHorizontalConstraint, duration: 0.0);
        instructionDisplays = [display1, display2, display3, display4, display5];
        
        for index in 0...4 {
            instructionDisplays[index].label.text = "";
            instructionDisplays[index].timerLabel.text = "";
            instructionDisplays[index].labelVerticalConstraint.constant = CGFloat(-25 + 50 * (4-index));
            instructionDisplays[index].labelHorizontalConstraint.constant = 0;
            instructionDisplays[index].timerLabelHorizontalConstraint.constant = 0;
        }
        instructionDisplays[0].labelVerticalConstraint.constant += 20; 
        
    }
    
}
