//
//  ExerciseViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class ExerciseViewController: UIViewController {
    
    @IBOutlet weak var nextInstructionLabel: UILabel!
    @IBOutlet weak var currentInstructionLabel: UILabel!
    
    @IBOutlet weak var outerCircle: UIView!
    @IBOutlet weak var innerCircle: UIView!
    
    var circleCenter : CGPoint!
    
    var panRecognizer = MRRImmediatePanGestureRecognizer() // recognizer for sliding the button up the bar
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set the title for the nav bar
        title = "Breathing Intervention";
        
        //view.layoutIfNeeded();
        
        outerCircle.layer.cornerRadius=120;
        innerCircle.layer.cornerRadius=90;
        
        panRecognizer = MRRImmediatePanGestureRecognizer(target: self, action: #selector(ExerciseViewController.panned(sender:)));
        outerCircle.addGestureRecognizer(panRecognizer);
        
    }
    
    override func viewDidLayoutSubviews() {
        print("View Did Layout Subviews");
        //        circleCenter = CGPoint(x: outerCircle.frame.origin.x + outerCircle.frame.size.width/2, y: outerCircle.frame.origin.y + outerCircle.frame.size.height/2+(navigationController?.navigationBar.frame.size.height)!+UIApplication.shared.statusBarFrame.height);
        circleCenter = CGPoint(x: outerCircle.frame.origin.x + outerCircle.frame.size.width/2, y: outerCircle.frame.origin.y + outerCircle.frame.size.height/2);
    }
    
    // function called when the sliding button is panned
    func panned(sender:UIPanGestureRecognizer) {
        switch(sender.state) {
        case UIGestureRecognizerState.began:
            // Store the starting vertical position for the pan so we can find the vertical change
//            let point: CGPoint = sender.translation(in: self.view);
            let point: CGPoint = sender.location(in: view);
            let dist = distance(firstPoint: point, secondPoint: self.circleCenter);
            let angle = getAngle(centralPoint: self.circleCenter, secondPoint: point);
            
            //print("Distance: \(dist)");
            print("Angle: \(angle)");
            
            if dist < 90 || dist > 120 {
                sender.state = UIGestureRecognizerState.cancelled;
            }
            break;
        case UIGestureRecognizerState.changed:
            let point: CGPoint = sender.location(in: view);
            let dist = distance(firstPoint: point, secondPoint: self.circleCenter);
            let angle = getAngle(centralPoint: self.circleCenter, secondPoint: point);
            
            //print("Distance: \(dist)");
            print("Angle: \(angle)");
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
    
}
