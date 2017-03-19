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

class ExerciseViewController: UIViewController {
    
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
    let queuedInstructionTextColor: UIColor = UIColor.red;
    let currentInstructionTextColor: UIColor = UIColor.blue;
    let exerciseCompleteIndicator: String = "Complete";
    
    
    var circleCenter : CGPoint!
    
    var state: Int!
    
    var panRecognizer = MRRImmediatePanGestureRecognizer() // recognizer for sliding the button up the bar
    
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
    var ringActions: [breathingAction] = [];
    var timeOfRingRelease: Double!
    var exerciseEnded: Bool = false;
    var lastActionCaptured: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title for the nav bar
        title = "Breathing Exercise";
        
        // initialize wheel image and add gesture recognizer
        imageView.image = UIImage(named: "pause_wheel.png");
        state = 1;
        panRecognizer = MRRImmediatePanGestureRecognizer(target: self, action: #selector(ExerciseViewController.imageViewPanned(sender:)));
        imageView.addGestureRecognizer(panRecognizer);
        imageView.isUserInteractionEnabled = true;
        
        alreadyFinished = false;
        exercise = BreathingExercise();
        
        beepSound = URL(fileURLWithPath: Bundle.main.path(forResource: "beep", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: beepSound);
            audioPlayer.prepareToPlay();
        } catch {
            print("Error initializing audio player.");
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated);
        
        // invalidate the timers and stop the exercise
        if instructionTimer != nil {
            instructionTimer.invalidate();
        }
        if counterTimer != nil {
            counterTimer.invalidate();
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
                    let action = breathingAction(action: "Pause", duration: startOfCurrentAction - timeOfRingRelease, start: timeOfRingRelease, end: startOfCurrentAction);
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
            if exerciseEnded && !lastActionCaptured {
                print("Exercise ended. Capturing last action.");
                // exercise is over. record the last action and then prevent other actions from 
                // being captured
                lastActionCaptured = true;
                if rotatingClockwise == true {
                    let actionEndTime = Date().timeIntervalSince1970;
                    let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                    ringActions.append(action);
                } else {
                    let actionEndTime = Date().timeIntervalSince1970;
                    let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                    ringActions.append(action);
                }
            } else if previousAngle - angle > 0 || previousAngle - angle < -300 {
                // clockwise
                print("Clockwise");
                if rotatingClockwise == nil {
                    print("rotating clockwise is nil. beginning first action");
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
                    let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                    ringActions.append(action);
                    startOfCurrentAction = actionEndTime;
                }
                
            } else {
                // counter clockwise
                print("Counter clockwise");
                if rotatingClockwise == nil {
                    // this is the first action
                    rotatingClockwise = false;
                    print("rotating clockwise is nil. beginning first action");
                    
                    // savethe start time here
                    startOfCurrentAction = Date().timeIntervalSince1970;
                    
                } else if rotatingClockwise == true {
                    // the previous clockwise action just ended
                    // save the times and calculate the duration
                    rotatingClockwise = false;
                    let date = Date();
                    let actionEndTime = date.timeIntervalSince1970;
                    let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                    ringActions.append(action);
                    startOfCurrentAction = actionEndTime;
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
            if lastActionCaptured {
                // nothing should happen ifthe last action has already been captured
            } else if rotatingClockwise == nil {
                // enters here if the action is ending before the exercise even started
            } else if rotatingClockwise == true {
                // the last action was clockwise
                // save the info for clockwise
                let date = Date();
                let actionEndTime = date.timeIntervalSince1970;
                let action = breathingAction(action: "Inhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                ringActions.append(action);
                startOfCurrentAction = actionEndTime;
                timeOfRingRelease = actionEndTime;
                
            } else if rotatingClockwise == false {
                // the last action was counterclockwise
                // save the info for counterclockwise
                let date = Date();
                let actionEndTime = date.timeIntervalSince1970;
                let action = breathingAction(action: "Exhale", duration: actionEndTime - startOfCurrentAction, start: startOfCurrentAction, end: actionEndTime);
                ringActions.append(action);
                startOfCurrentAction = actionEndTime;
                timeOfRingRelease = actionEndTime;
                
            }
            
            break;
        }
//        case UIGestureRecognizerState.ended:
//            // determine which action just terminated and save the info
//            if rotatingClockwise == nil {
//                // this is most likely an error, but nothing should happen
//            } else if rotatingClockwise == true {
//                // the last action was clockwise
//                // save the info for clockwise
//                
//            } else if rotatingClockwise == false {
//                // the last action was counterclockwise 
//                // save the info for counterclockwise
//                
//            }
//            
//            let date = Date();
//            timeOfRingRelease = (date.timeIntervalSince1970)*256;
//            
//            break;
//        case UIGestureRecognizerState.cancelled:
//            // This should not be reached
//            print("uipangesturerecognizer: state cancelled");
//            break;
//        default:
//            // This should not be reached
//            print("uipangesturerecognizer: state not recognized");
//            break;
//        }
    }
    
    func beginExercise() {
        // remove blurring view and begin button
        blurEffectView.removeFromSuperview();
        beginButton.removeFromSuperview();
        
        // initialize the instruction labels with the instructions and their durations
        // initialize the first/current instruction label with starting exercise indicator
        instructionDisplays[0].label.text = "Starting in: ";
        instructionDisplays[0].timerLabel.text = "3.0 s";
        instructionDisplays[0].duration = 3.0;
        instructionDisplays[0].label.font = instructionDisplays[0].label.font.withSize(currentInstructionTextSize);
        instructionDisplays[0].timerLabel.font = instructionDisplays[0].timerLabel.font.withSize(currentInstructionTextSize);
        instructionDisplays[0].label.textColor = currentInstructionTextColor;
        instructionDisplays[0].timerLabel.textColor = currentInstructionTextColor;

        
        var instruction: (complete: Bool, instruction: String, duration: Double);
        for index in 1...4 {
            // get the next instruction from the exercise
            instruction = exercise.next();
            
            instructionDisplays[index].label.font = instructionDisplays[index].label.font.withSize(queuedInstructionTextSize);
            instructionDisplays[index].timerLabel.font = instructionDisplays[index].timerLabel.font.withSize(queuedInstructionTextSize);
            instructionDisplays[index].label.textColor = queuedInstructionTextColor;
            instructionDisplays[index].timerLabel.textColor = queuedInstructionTextColor;
            if !instruction.complete {
                instructionDisplays[index].label.text = instruction.instruction;
                instructionDisplays[index].timerLabel.text = String(format: "%.1f s", instruction.duration);
                instructionDisplays[index].duration = instruction.duration;
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
//        timerLabel.text = "3.0";
        counterTimer = Timer.scheduledTimer(timeInterval: TimeInterval(countDownInterval), target: self, selector: #selector(ExerciseViewController.countdown), userInfo: nil, repeats: true);
        
        // begin another timer that plays the beep sound every second
        metronomeTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(ExerciseViewController.playBeep), userInfo: nil, repeats: true);
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
//            print("Timer scheduled for: \(getDisplayInPosition(position: 1).duration) seconds"); 
            
            // reset the countdown timer here
            counterTimer.invalidate();
            getDisplayInPosition(position: 0).timerLabel.text = "0.0 s";
            counterTimer = Timer.scheduledTimer(timeInterval: TimeInterval(countDownInterval), target: self, selector: #selector(ExerciseViewController.countdown), userInfo: nil, repeats: true);
            
        } else {
            // Exercise has ended
            exerciseEnded = true;
            counterTimer.invalidate();
            metronomeTimer.invalidate();
            
            // store the end time
            let date = Date();
            endTimestamp = Int(date.timeIntervalSince1970*256);
            
//            // delay for 2 seconds before going to the results controller
            Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(ExerciseViewController.pushResultsController), userInfo: nil, repeats: false);
            
        }
        
        // set new destinations for the instruction displays
        for index in 0...4 {
            getDisplayInPosition(position: index).labelVerticalConstraint.constant += 50;
        }
        
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
            let next = self.exercise.next();
            if self.alreadyFinished == true {
                self.getDisplayInPosition(position: 4).label.text = "";
                self.getDisplayInPosition(position: 4).timerLabel.text = "";
            } else if next.complete {
                self.getDisplayInPosition(position: 4).label.text = self.exerciseCompleteIndicator;
                self.getDisplayInPosition(position: 4).timerLabel.text = "--";
                self.alreadyFinished = true;
            } else {
                self.getDisplayInPosition(position: 4).label.text = next.instruction;
                self.getDisplayInPosition(position: 4).timerLabel.text = String(format: "%.1f s", next.duration);
            }
            
            self.getDisplayInPosition(position: 4).label.textColor = self.queuedInstructionTextColor;
            self.getDisplayInPosition(position: 4).label.font = self.getDisplayInPosition(position: 4).label.font.withSize(self.queuedInstructionTextSize);
            self.getDisplayInPosition(position: 4).timerLabel.textColor = self.queuedInstructionTextColor;
            self.getDisplayInPosition(position: 4).timerLabel.font = self.getDisplayInPosition(position: 4).label.font.withSize(self.queuedInstructionTextSize);
            
            // the following instruction is different bc modification of the struct requires direct access since function getDisplayInPosition returns a copy
            self.instructionDisplays[self.getDisplayNumber(position: 4)].duration = next.duration;
            
            self.getDisplayInPosition(position: 4).labelVerticalConstraint.constant += -250;
            self.view.layoutIfNeeded();
        })
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
        beginButton.addTarget(self, action: #selector(ExerciseViewController.beginExercise), for: .touchUpInside);
        beginButton.translatesAutoresizingMaskIntoConstraints = false;
        let horizontalConstraint = NSLayoutConstraint(item: beginButton, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: 1.0, constant: 0);
        let verticalConstraint = NSLayoutConstraint(item: beginButton, attribute: .centerY, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1.0, constant: 0);
        let widthConstraint = NSLayoutConstraint(item: beginButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200);
        let heightConstraint = NSLayoutConstraint(item: beginButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 60);
        let constraints = [horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint];
        self.view.addConstraints(constraints);
        beginButton.setTitle("Begin Exercise", for: .normal);
        beginButton.setTitleColor(.black, for: .normal)
        beginButton.backgroundColor = .white;
        self.view.addSubview(beginButton);
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
        
    }
    
    
}
