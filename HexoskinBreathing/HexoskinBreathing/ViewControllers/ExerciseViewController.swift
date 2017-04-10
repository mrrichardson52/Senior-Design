//
//  ExerciseViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit
import AVFoundation

class ExerciseViewController: DataAnalyzingViewController {
    
    // colors for ui elements
    let beginButtonColor: UIColor = Constants.avocadoColor;
    let queuedInstructionTextColor: UIColor = Constants.electricBlue;
    let currentInstructionTextColor: UIColor = Constants.avocadoColor
    let borderColor: UIColor = Constants.phoneBoothRed;
    let continueButtonColor: UIColor = Constants.electricBlue;
    let exerciseCompletedTextColor: UIColor = .black;
    
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
 
    // imageview that stores the wheel
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewContainer: UIView!
    
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
    
    var alreadyFinished: Bool!
    
    var currentTimerCounter: Double!
    var counterTimer: Timer!
    var instructionTimer: Timer!
    let countUpInterval: Double = 0.1;
    var metronomeTimer: Timer!
    var beginExerciseTimer: Timer!
    var countUpTimer: Timer!;
    var nextInstructionDelayTimer: Timer!;
    
    // used for playing beep sound
    var beepSound: URL!
    var audioPlayer: AVAudioPlayer!
    
    // boolean used for checking when the exercise begins
    var exerciseBegan: Bool = false;
    
    var previousAngle: Double = 0.0;
    var rotatingClockwise: Bool!
    var startOfCurrentAction: Double!
    var timeOfRingRelease: Double!
    var exerciseEnded: Bool = false;

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
    
    // count up timer label
    var countUpTimerLabel: UILabel!
    var countUpCurrentValue: Double = 0.0;
    
    // indicate signed in
    var signedIn: Bool!
    
    var wearingHexoskin: Bool! = false;
    
    var exerciseState: ExerciseState = .notStarted;
    var actionCheckingHelper: ActionCheckingHelper!
    
    var startIndicatorString: String = "Starting in:";
    
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
        
        // we are definitely analyzing the ring, but we need to check for hexoskin
        analyzingRing = true;
        analyzingHexoskin = signedIn && wearingHexoskin;
        
        // initialize the action checking helper
        actionCheckingHelper = ActionCheckingHelper();
        
    }
    
    override func loadView() {
        super.loadView();
    
        // init constraints and text for instruction labels
        initInstructionDisplays();
        
        // add count up timer label
        addCountUpTimerLabel();
        
        // add border lines for current instruction
        addCurrentInstructionBorderLines();
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // store the center of the imageview to be used for detecting distances of taps on the ring
        circleCenter = CGPoint(x: imageViewContainer.frame.origin.x + imageViewContainer.frame.size.width/2, y: imageViewContainer.frame.origin.y + imageViewContainer.frame.size.height/2);
        
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
            
            switch exerciseState {
            case .notStarted:
                // start the exercise
                // the exercise will begin in 3 seconds
                beginExerciseTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ExerciseViewController.beginExercise), userInfo: nil, repeats: false);
                
                
                // begin another timer that plays the beep sound every second
                if playMetronome {
                    metronomeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.playBeep), userInfo: nil, repeats: true);
                }
                
                // indicate the exercise is starting
                exerciseState = .starting;
                
                // show the starting instruction
                print("Began: .notStarted");
                displayNextInstruction();
                
                break;
            case .started:
                
                // since the exercise has already started, the last action must have been a pause
                let date = Date();
                startOfCurrentAction = date.timeIntervalSince1970;
                actionCheckingHelper.checkingState = .deviatingAfterPause;
                actionCheckingHelper.lastCandidateActionStart = startOfCurrentAction;
                actionCheckingHelper.deviationStartTime = startOfCurrentAction;
                actionCheckingHelper.deviationStartAngle = angle;
                
                // this last action was a pause
                // save the times and calculate the duration of the pause
                if timeOfRingRelease != nil {
                    let action = breathingAction(action: "Pause", duration: startOfCurrentAction - timeOfRingRelease, start: timeOfRingRelease - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing, end: startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing);
                    ringDataRaw.append(action);
                }
                
                break;
            default:
                // do nothing if the exercise has already ended and .starting shouldn't be reachable
                break;
            }
            
            break;
        case UIGestureRecognizerState.changed:
            let point: CGPoint = sender.location(in: view);
            var angle = getAngle(centralPoint: self.circleCenter, secondPoint: point);
            
            angle = angle - 90;
            if angle < 0 {
                angle = angle + 360;
            }
            
            // filter out massive changes that are more than likely mistakes
            if abs(previousAngle - angle) > 150 && abs(previousAngle - angle) < 210 {
                // this was most likely a mistake and should be ignored
                if rotatingClockwise != nil {
                    if rotatingClockwise == true {
                        
                        angle = previousAngle - 0.1;
                        if angle < 0 {
                            angle += 360;
                        }
                    } else {
                        angle = previousAngle + 0.1;
                        if angle >= 360 {
                            angle -= 360;
                        }
                    }
                }
            }
            
            let angleChange = previousAngle - angle;
            
            switch exerciseState {
            case .started:
                if angleChange < 300 && (angleChange > 0 || angleChange < -300) {
                    // clockwise
                    if rotatingClockwise == nil {
                        
                        if actionCheckingHelper.checkingState == .none {
                            
                            // this is the beginning state, so initialize the deviation angle
                            actionCheckingHelper.deviationStartAngle = angle;
                            actionCheckingHelper.checkingState = .checkingFirstAction;
                            actionCheckingHelper.lastCandidateActionStart = Date().timeIntervalSince1970;
                            actionCheckingHelper.deviationStartTime = actionCheckingHelper.lastCandidateActionStart;
                            
                        } else if actionCheckingHelper.checkingState == .checkingFirstAction {
                            
                            // calculate the total angle change since the beginning
                            var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                            if angleDeviation < 0 {
                                angleDeviation += 360;
                            }
                            
                            // see if the difference overcame the difference threshold
                            if angleDeviation > actionCheckingHelper.deviationThresholdAngle {
                                // the first instruction is an inhale
                                rotatingClockwise = true;
                                actionCheckingHelper.checkingState = .currentActionInhale;
                                actionCheckingHelper.deviationStartAngle = angle;
                            }
                            
                        }
                        
                    } else if rotatingClockwise == false {
                        // Since we only change rotatingClockwise when we officially begin a new action, we can be sure that we are currently deviating in some way in this block
                        // Determine what state of deviation we are in
                        switch actionCheckingHelper.checkingState! {
                        case .lastActionPause:
                            actionCheckingHelper.checkingState = .deviatingAfterPause;
                            break;
                        case .currentActionExhale:
                            actionCheckingHelper.checkingState = .deviatingAfterExhale;
                            break;
                        case .currentActionInhale:
                            actionCheckingHelper.checkingState = .deviatingAfterInhale;
                            break;
                        default:
                            // otherwise, we are already in a deviating state - do nothing
                            break;
                        }
                        
                        // check to see if this clockwise rotation was enough to be a new action
                        var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                        if angleDeviation < 0 {
                            angleDeviation += 360;
                        }
                        
                        // see if the difference overcame the difference threshold
                        if angleDeviation > actionCheckingHelper.deviationThresholdAngle {
                            // this instruction is an inhale
                            
                            // now that we know a new instruction has begun, check the state
                            switch actionCheckingHelper.checkingState! {
                            case .deviatingAfterExhale:
                                // we are ending the exhale and beginning a new inhale
                                ringDataRaw.append(breathingAction(action: Strings.exhale, duration: actionCheckingHelper.deviationStartTime - actionCheckingHelper.lastCandidateActionStart, start: actionCheckingHelper.lastCandidateActionStart - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing, end: actionCheckingHelper.deviationStartTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing));
                                actionCheckingHelper.lastCandidateActionStart = actionCheckingHelper.deviationStartTime;
                                print("Changed: .started cw deviating after exhale");
                                
                                if actionCheckingHelper.firstActionIsExhale != true {
                                    print("Displaying next instruction even though first action is exhale");
                                    displayNextInstruction();
                                }
                                actionCheckingHelper.firstActionIsExhale = false;
                                
                                break;
                            case .deviatingAfterPause:
                                if getDisplayInPosition(position: 0).label.text == Strings.exhale {
                                    // if the current instruction is showing exhale, then we should display the next one
                                    print("Changed: .started cw deviating after pause");
                                    displayNextInstruction();
                                }
                                break;
                            default:
                                // we do nothing in the other scenarios
                                break;
                            }
                            
                            // set the values for the next round
                            rotatingClockwise = true;
                            actionCheckingHelper.checkingState = .currentActionInhale;
                            actionCheckingHelper.deviationStartAngle = angle;
                            actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                        }
                        
                    } else {
                        // continuing rotating clockwise - check if we are deviating
                        if actionCheckingHelper.checkingState != .deviatingAfterInhale && actionCheckingHelper.checkingState != .deviatingAfterExhale && actionCheckingHelper.checkingState != .deviatingAfterPause {
                            // since we are not deviating, we should update the deviation values
                            actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                            actionCheckingHelper.deviationStartAngle = angle;
                        } else {
                            // if we are deviating, it is important to determine if the inhale resumes and update the deviation values
                            
                            // check to see if this clockwise rotation was enough to continue the inhale
                            var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                            if angleDeviation < 0 {
                                angleDeviation += 360;
                            }
                            
                            // see if the difference overcame the difference threshold
                            if angleDeviation > actionCheckingHelper.deviationThresholdAngle {
                                actionCheckingHelper.checkingState = .currentActionInhale;
                                actionCheckingHelper.deviationStartAngle = angle;
                                actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                            }
                        }
                        
                    }
                    
                } else {
                    // counter clockwise
                    if rotatingClockwise == nil {
                        
                        if actionCheckingHelper.checkingState == .none {
                            
                            // this is the beginning state, so initialize the deviation angle
                            actionCheckingHelper.deviationStartAngle = angle;
                            actionCheckingHelper.checkingState = .checkingFirstAction;
                            actionCheckingHelper.lastCandidateActionStart = Date().timeIntervalSince1970;
                            actionCheckingHelper.deviationStartTime = actionCheckingHelper.lastCandidateActionStart;
                            
                        } else if actionCheckingHelper.checkingState == .checkingFirstAction {
                            
                            // calculate the total angle change since the beginning
                            var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                            if angleDeviation > 0 {
                                angleDeviation -= 360;
                            }
                            
                            // see if the difference overcame the difference threshold
                            if angleDeviation < -actionCheckingHelper.deviationThresholdAngle {
                                // the first instruction is an exhale
                                rotatingClockwise = false;
                                actionCheckingHelper.checkingState = .currentActionExhale;
                                actionCheckingHelper.deviationStartAngle = angle;
                                actionCheckingHelper.firstActionIsExhale = true;
                                print("First action marked as exhale");
                            }
                            
                        }
                    } else if rotatingClockwise == true {
                        // Since we only change rotatingClockwise when we officially begin a new action, we can be sure that we are currently deviating in some way in this block
                        // Determine what state of deviation we are in
                        switch actionCheckingHelper.checkingState! {
                        case .lastActionPause:
                            actionCheckingHelper.checkingState = .deviatingAfterPause;
                            break;
                        case .currentActionExhale:
                            actionCheckingHelper.checkingState = .deviatingAfterExhale;
                            break;
                        case .currentActionInhale:
                            actionCheckingHelper.checkingState = .deviatingAfterInhale;
                            break;
                        default:
                            // otherwise, we are already in a deviating state - do nothing
                            break;
                        }
                        
                        // check to see if this clockwise rotation was enough to be a new action
                        var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                        if angleDeviation > 0 {
                            angleDeviation -= 360;
                        }
                        
                        // see if the difference overcame the difference threshold
                        if angleDeviation < -actionCheckingHelper.deviationThresholdAngle {
                            // this instruction is an exhale
                            
                            // now that we know a new instruction has begun, check the state
                            switch actionCheckingHelper.checkingState! {
                            case .deviatingAfterInhale:
                                // we are ending the inhale and beginning a new exhale
                                ringDataRaw.append(breathingAction(action: Strings.inhale, duration: actionCheckingHelper.deviationStartTime - actionCheckingHelper.lastCandidateActionStart, start: actionCheckingHelper.lastCandidateActionStart - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing, end: actionCheckingHelper.deviationStartTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing));
                                actionCheckingHelper.lastCandidateActionStart = actionCheckingHelper.deviationStartTime;
                                print("Changed: .started ccw - deviating after inhale")
                                displayNextInstruction();
                                break;
                            case .deviatingAfterPause:
                                if getDisplayInPosition(position: 0).label.text == Strings.inhale {
                                    // if the current instruction is showing inhale, then we should display the next one
                                    print("Changed: .started ccw - deviating after pause");
                                    displayNextInstruction();
                                }
                                break;
                            default:
                                // we do nothing in the other scenarios
                                break;
                            }
                            
                            // set the values for the next round
                            rotatingClockwise = false;
                            actionCheckingHelper.checkingState = .currentActionExhale;
                            actionCheckingHelper.deviationStartAngle = angle;
                            actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                        }
                        
                    } else {
                        // continuing rotating counterclockwise - check if we are deviating
                        if actionCheckingHelper.checkingState != .deviatingAfterInhale && actionCheckingHelper.checkingState != .deviatingAfterExhale && actionCheckingHelper.checkingState != .deviatingAfterPause {
                            // since we are not deviating, we should reset the deviation values
                            actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                            actionCheckingHelper.deviationStartAngle = angle;
                        } else {
                            // if we are deviating, it is important to determine if the inhale resumes and update the deviation values
                            
                            // check to see if this clockwise rotation was enough to continue the inhale
                            var angleDeviation = actionCheckingHelper.deviationStartAngle - angle;
                            if angleDeviation > 0 {
                                angleDeviation -= 360;
                            }
                            
                            // see if the difference overcame the difference threshold
                            if angleDeviation < -actionCheckingHelper.deviationThresholdAngle {
                                actionCheckingHelper.checkingState = .currentActionExhale;
                                actionCheckingHelper.deviationStartAngle = angle;
                                actionCheckingHelper.deviationStartTime = NSDate().timeIntervalSince1970;
                            }
                        }
                        
                    }
                    
                }
                
                break;
            default:
                // do nothing if the exercise is starting, not started, or ended
                break;
            }
            
            previousAngle = angle;
            
            UIView.animate(withDuration: 0.1, animations: {
                self.imageView.transform = CGAffineTransform(rotationAngle: -(CGFloat(angle) * CGFloat(M_PI) / 180.0))
            })
            
            break;
        default:
            // this default should catch state ended and cancelled
            switch exerciseState {
            case .starting:
                
                // if the exercise is starting and the user removed their finger from the wheel, reset
                exerciseState = .notStarted;
                
                // invalidate the timer that is beginning the exercise
                beginExerciseTimer.invalidate();
                if metronomeTimer != nil {
                    metronomeTimer.invalidate();
                }
                countUpTimer.invalidate();
                countUpTimerLabel.text = "0.0";
                countUpCurrentValue = 0.0;
                
                // reset the instruction displays
                initInstructionDisplays();
                
                break;
            case .started:
                
                // determine which action just terminated and save the info
                if rotatingClockwise == nil {
                    // enters here if the action is begun and ends in the same position on the ring - do nothing
                } else {
                    
                    let actionEndTime = Date().timeIntervalSince1970;
                    let duration = actionEndTime - startOfCurrentAction;
                    let start = startOfCurrentAction - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing;
                    let end = actionEndTime - Double(startTimestamp)/256 - Constants.exerciseStartTimeAdjustmentForRing
                    startOfCurrentAction = actionEndTime;
                    timeOfRingRelease = actionEndTime;
                    
                    if rotatingClockwise == true {
                        
                        // the last action was clockwise
                        // save the info for clockwise
                        ringDataRaw.append(breathingAction(action: "Inhale", duration: duration, start: start, end: end));
                        
                    } else if rotatingClockwise == false {
                        
                        // the last action was counterclockwise
                        // save the info for counterclockwise
                        ringDataRaw.append(breathingAction(action: "Exhale", duration: duration, start: start, end: end));

                    }
                    
                    // check if this action satisfies the current instruction and move to the next if it does
                    if duration > getDisplayInPosition(position: 0).duration {
                        // proceed to the next instruction
                        print("Cancelled: .started");
                        displayNextInstruction();
                        
                    }
                    
                }
                
                break;
            default:
                // do nothing if the exercise is not started yet or if the exercise already ended
                break;
            }
            
            break;
        }
        
    }
    
    func displayNextInstruction() {
        
        // check if the next instruction is the starting indicator
        if getDisplayInPosition(position: 1).label.text == self.startIndicatorString {
            // start the count up timer
            self.countUpTimerLabel.text = "0.0";
            countUpTimer = Timer.scheduledTimer(withTimeInterval: TimeInterval(self.countUpInterval), repeats: true, block: {
                _ in
                self.countUpCurrentValue += self.countUpInterval;
                let formattedValue = String.init(format: "%.1f", self.countUpCurrentValue);
                self.countUpTimerLabel.text = formattedValue;
            })
        } else if getDisplayInPosition(position: 1).label.text == exerciseCompleteIndicator {
            // Exercise has ended
            exerciseState = .ended;
            
            // stop the count up timer
            countUpTimer.invalidate();
            countUpTimerLabel.text = "";
            
            // kill the metronome
            if playMetronome {
                metronomeTimer.invalidate();
            }
            
            // store the end time
            endTimestamp = Int(Date().timeIntervalSince1970*256);
            
            // delay for 1 seconds before adding the next button - this allows for the animations to complete
            Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.addNextButton), userInfo: nil, repeats: false);
            
        } else {
            // the exercise is continuing to the next instruction
            // reset the count up label to 0.0
            countUpTimerLabel.text = "0.0";
            countUpCurrentValue = 0.0;
            
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
        
        UIView.animate(withDuration: 0.2, animations: {
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
    
    func addCountUpTimerLabel() {
        countUpTimerLabel = UILabel();
        countUpTimerLabel.translatesAutoresizingMaskIntoConstraints = false;
        countUpTimerLabel.font = countUpTimerLabel.font.withSize(20);
        countUpTimerLabel.textColor = .black;
        countUpTimerLabel.text = "0.0";
        countUpTimerLabel.textAlignment = .center;
        imageViewContainer.addSubview(countUpTimerLabel);
        
        // add constraints
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: countUpTimerLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 100));
        constraints.append(NSLayoutConstraint(item: countUpTimerLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30));
        constraints.append(NSLayoutConstraint(item: countUpTimerLabel, attribute: .centerY, relatedBy: .equal, toItem: imageViewContainer, attribute: .centerY, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: countUpTimerLabel, attribute: .centerX, relatedBy: .equal, toItem: imageViewContainer, attribute: .centerX, multiplier: 1.0, constant: 0));
        imageViewContainer.addConstraints(constraints);
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
        completedLabel.font = completedLabel.font.withSize(25);
        instructionParentView.addSubview(completedLabel);
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .leading, relatedBy: .equal, toItem: instructionParentView, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .trailing, relatedBy: .equal, toItem: instructionParentView, attribute: .trailing, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: completedLabel, attribute: .bottom, relatedBy: .equal, toItem: instructionParentView, attribute: .centerY, multiplier: 1.0, constant: -30));
        
        let uploadLabel = UILabel();
        if wearingHexoskin == true {
            // add the upload label right beneath
            uploadLabel.translatesAutoresizingMaskIntoConstraints = false;
            uploadLabel.numberOfLines = 0;
            uploadLabel.backgroundColor = .clear;
            uploadLabel.textColor = exerciseCompletedTextColor;
            uploadLabel.font = uploadLabel.font.withSize(17);
            uploadLabel.text = "Upload Hexoskin data using HxServices before analyzing";
            uploadLabel.textAlignment = .center;
            instructionParentView.addSubview(uploadLabel);
            constraints.append(NSLayoutConstraint(item: uploadLabel, attribute: .width, relatedBy: .equal, toItem: completedLabel, attribute: .width, multiplier: 1.0, constant: 0));
            constraints.append(NSLayoutConstraint(item: uploadLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 50));
            constraints.append(NSLayoutConstraint(item: uploadLabel, attribute: .top, relatedBy: .equal, toItem: completedLabel, attribute: .bottom, multiplier: 1.0, constant: 0));
            constraints.append(NSLayoutConstraint(item: uploadLabel, attribute: .centerX, relatedBy: .equal, toItem: instructionParentView, attribute: .centerX, multiplier: 1.0, constant: 0));
        }
        
        // add next button right below the completed label
        let nextButton = UIButton();
        nextButton.translatesAutoresizingMaskIntoConstraints = false;
        nextButton.isUserInteractionEnabled = true;
        nextButton.addTarget(self, action: #selector(ExerciseViewController.nextPressed), for: .touchUpInside);
        instructionParentView.addSubview(nextButton);
        nextButton.setTitleColor(Constants.basicTextColor, for: .normal);
        nextButton.backgroundColor = continueButtonColor;
        nextButton.layer.cornerRadius = 8;
        nextButton.setTitle("Analyze", for: .normal);
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .centerX, relatedBy: .equal, toItem: instructionParentView, attribute: .centerX, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40));
        if wearingHexoskin == false {
            constraints.append(NSLayoutConstraint(item: nextButton, attribute: .top, relatedBy: .equal, toItem: instructionParentView, attribute: .centerY, multiplier: 1.0, constant: 20));
        } else {
            constraints.append(NSLayoutConstraint(item: nextButton, attribute: .top, relatedBy: .equal, toItem: uploadLabel, attribute: .bottom, multiplier: 1.0, constant: 20));
        }
        constraints.append(NSLayoutConstraint(item: nextButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120));
        instructionParentView.addConstraints(constraints);

        
    }
    
    func beginExercise() {
        // indicate that the exercise has started
        self.exerciseState = .started;
        self.startOfCurrentAction = Date().timeIntervalSince1970;
        self.startTimestamp = Int(self.startOfCurrentAction*256);
        displayNextInstruction();
        print("Begin Exercise: Display next instruction");
    }
    
    
    
    func nextPressed() {
        
        if signedIn == true && wearingHexoskin == true {
            self.getRecordID();
        } else {
            prepareDataAndSendToDataViewer();
        }
        
    }
    
    func distance(firstPoint: CGPoint, secondPoint: CGPoint) -> Double {
        let x1 = Double(firstPoint.x);
        let x2 = Double(secondPoint.x);
        let y1 = Double(firstPoint.y);
        let y2 = Double(secondPoint.y);
        return sqrt(pow(x2-x1,2) + pow(y2-y1,2));
    }
    
    func getAngle(centralPoint: CGPoint, secondPoint: CGPoint) -> Double {
        let x1 = Double(centralPoint.x);
        let x2 = Double(secondPoint.x);
        let y1 = Double(centralPoint.y);
        let y2 = Double(secondPoint.y);
        let xdelta = x2-x1;
        let ydelta = y2-y1;
        let pi = Double(M_PI);
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
    
    func initInstructionDisplays() {
        
        if instructionDisplays == nil {
            // initialize the array of instruction labels
            let display1 = InstructionDisplay(label: firstInstructionLabel, timerLabel: firstTimerLabel, labelVerticalConstraint: firstVerticalConstraint, labelHorizontalConstraint: firstHorizontalConstraint, timerLabelHorizontalConstraint: firstInstructionTimerHorizontalConstraint, duration: 0.0);
            let display2 = InstructionDisplay(label: secondInstructionLabel, timerLabel: secondTimerLabel, labelVerticalConstraint: secondVerticalConstraint, labelHorizontalConstraint: secondHorizontalConstraint, timerLabelHorizontalConstraint: secondInstructionTimerHorizontalConstraint, duration: 0.0);
            let display3 = InstructionDisplay(label: thirdInstructionLabel, timerLabel: thirdTimerLabel, labelVerticalConstraint: thirdVerticalConstraint, labelHorizontalConstraint: thirdHorizontalConstraint, timerLabelHorizontalConstraint: thirdInstructionTimerHorizontalConstraint, duration: 0.0);
            let display4 = InstructionDisplay(label: fourthInstructionLabel, timerLabel: fourthTimerLabel, labelVerticalConstraint: fourthVerticalConstraint, labelHorizontalConstraint: fourthHorizontalConstraint, timerLabelHorizontalConstraint: fourthInstructionTimerHorizontalConstraint, duration: 0.0);
            let display5 = InstructionDisplay(label: fifthInstructionLabel, timerLabel: fifthTimerLabel, labelVerticalConstraint: fifthVerticalConstraint, labelHorizontalConstraint: fifthHorizontalConstraint, timerLabelHorizontalConstraint: fifthInstructionTimerHorizontalConstraint, duration: 0.0);
            instructionDisplays = [display1, display2, display3, display4, display5];
        }
        
        for index in 0...4 {
            instructionDisplays[index].labelVerticalConstraint.constant = CGFloat(-25 + 50 * (4-index));
            instructionDisplays[index].labelHorizontalConstraint.constant = 0;
            instructionDisplays[index].timerLabelHorizontalConstraint.constant = 0;
        }
        instructionDisplays[0].labelVerticalConstraint.constant += 20;
        
        
        // initialize the instruction labels with the instructions and their durations
        // initialize the first/current instruction label with starting exercise indicator
        instructionDisplays[0].label.text = "Hold wheel to begin";
        instructionDisplays[0].timerLabel.text = "";
        instructionDisplays[0].duration = 0.0;
        instructionDisplays[0].label.font = instructionDisplays[0].label.font.withSize(queuedInstructionTextSize);
        instructionDisplays[0].timerLabel.font = instructionDisplays[0].timerLabel.font.withSize(queuedInstructionTextSize);
        instructionDisplays[0].label.textColor = currentInstructionTextColor;
        instructionDisplays[0].timerLabel.textColor = currentInstructionTextColor;
        instructionDisplays[0].timerLabel.alpha = 1.0;
        instructionDisplays[0].label.alpha = 1.0;
        
        instructionDisplays[1].label.text = self.startIndicatorString;
        instructionDisplays[1].timerLabel.text = "3.0 s";
        instructionDisplays[1].duration = 3.0;
        instructionDisplays[1].label.font = instructionDisplays[1].label.font.withSize(queuedInstructionTextSize);
        instructionDisplays[1].timerLabel.font = instructionDisplays[1].timerLabel.font.withSize(queuedInstructionTextSize);
        instructionDisplays[1].label.textColor = queuedInstructionTextColor;
        instructionDisplays[1].timerLabel.textColor = queuedInstructionTextColor;
        
        
        exercise.reset();
        var action: breathingAction!
        for index in 2...4 {
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
        
    }

    
    func playBeep() {
        // play the beep sound
        audioPlayer.play()
    }
    

    
}
