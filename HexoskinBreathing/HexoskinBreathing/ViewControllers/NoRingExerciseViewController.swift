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
    
    // colors
    let startButtonColor: UIColor = Constants.avocadoColor;
    let stopButtonColor: UIColor = Constants.phoneBoothRed;
    let analyzeButtonColor: UIColor = Constants.electricBlue;
    
    // the programmatically created label that displays the exercise description
    var exerciseLabel: UILabel!
    
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
    
}
