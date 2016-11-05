//
//  ExerciseViewController.swift
//  Breathing Data Viewer
//
//  Created by Matthew Richardson on 11/2/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController {
    
    @IBOutlet weak var nextInstructionLabel: UILabel!
    @IBOutlet weak var currentInstructionLabel: UILabel!
    
    
    @IBOutlet weak var slidingButton: UIView!
    @IBOutlet weak var slidingButtonBarPositionConstraint: NSLayoutConstraint!
    
    let panRecognizer = MRRImmediatePanGestureRecognizer() // recognizer for sliding the button up the bar
    
    var panStartingVerticalPosition: CGFloat!
    
    var slidingButtonStartingVerticalPosition: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title for the nav bar
        title = "Breathing Intervention";
        
        // initially set the sliding button position to the bottom of the bar
        slidingButtonBarPositionConstraint.constant = 0;
        
        // add target to the pan gesture recognizer
        panRecognizer.addTarget(self, action: #selector(MRRBreathingExerciseViewController.panned));
        panRecognizer.minimumNumberOfTouches = 1;
        panRecognizer.maximumNumberOfTouches = 1;
        
        // add the gesture recongizer to the sliding button
        slidingButton.addGestureRecognizer(panRecognizer);
        
    }
    
    // function called when the sliding button is panned
    func panned(sender:UIPanGestureRecognizer) {
        switch(sender.state) {
        case UIGestureRecognizerState.began:
            print("gesture began");
            // Store the starting vertical position for the pan so we can find the vertical change
            let point: CGPoint = sender.translation(in: self.view);
            panStartingVerticalPosition = point.y;
            slidingButtonStartingVerticalPosition = slidingButtonBarPositionConstraint.constant;
            break;
        case UIGestureRecognizerState.changed:
            let buttonPositionChange: CGFloat = panStartingVerticalPosition - sender.translation(in:self.view).y;
            var buttonNewConstraint: CGFloat = slidingButtonStartingVerticalPosition + buttonPositionChange;
            if buttonNewConstraint < 0 {
                buttonNewConstraint = 0;
            }
            else if buttonNewConstraint > barView.frame.height - slidingButton.frame.height {
                buttonNewConstraint = barView.frame.height - slidingButton.frame.height;
            }
            slidingButtonBarPositionConstraint.constant = buttonNewConstraint;
            break;
        case UIGestureRecognizerState.ended:
            
            break;
        case UIGestureRecognizerState.cancelled:
            // This should not be reached
            print("uipangesturerecognizer: state cancelled");
            break;
        default:
            // This should not be reached
            print("uipangesturerecognizer: state not recognized");
            break;
        }
    }
    
}
