//
//  DataViewingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/16/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataViewingViewController: UIViewController {
    
    // exercise information and data
    var performanceResults: [(completed: Bool, instruction: String, duration: Double)]!;
    var results: [breathingAction]!;
    
    // horizontal scrollview
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollParentView: UIView!
    
    // indicator views
    @IBOutlet weak var inhaleIndicator: UILabel!
    @IBOutlet weak var exhaleIndicator: UILabel!
    @IBOutlet weak var noDataIndicator: UILabel!

    
    // ratio of pixels to seconds
    let pixelSecondRatio: Double = 30;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white;
        
        // print the performance results
        print("Performance results:");
        for result in performanceResults {
            print("\(result.instruction) \(result.duration) was completed: \(result.completed)");
        }
        print("\nUser Actions:");
        for action in results {
            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
        }
        
        // add views to the scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        
        // set the colors of the indicator views
        inhaleIndicator.backgroundColor = Constants.inhaleIndicatorColor;
        exhaleIndicator.backgroundColor = Constants.exhaleIndicatorColor;
        noDataIndicator.backgroundColor = Constants.noDataIndicatorColor;
        inhaleIndicator.textColor = .black;
        exhaleIndicator.textColor = .black;
        noDataIndicator.textColor = .black;
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        populateScrollView();

    }
    
    func populateScrollView() {
        
        self.view.setNeedsLayout()
        
        var totalExerciseDuration: Double = 0.0;
        
        // calculate the heights of all of the views
        let scrollHeight = scrollView.frame.height;
        print("Scroll height: \(scrollHeight)");
        print("View height: \(scrollParentView.frame.height)");
        let splitHeight = scrollHeight/2;
        let labelHeight = splitHeight*0.33;
        let viewHeight = splitHeight*0.6;
        
        // iterate through the prescribed exercises first
        var previousLabel: UILabel! = nil;
        for instruction in performanceResults {
            // first determine width based on duration
            let width = instruction.duration * pixelSecondRatio;
            
            // create the label that lists the action and duration
            let label = UILabel();
            label.font = label.font.withSize(15);
            if instruction.duration >= Constants.resultsViewDurationThreshold {
                // display the duration
                label.text = "\(Int(instruction.duration))  s";
            } else {
                // not worth showing the duration for such a short breath
                label.text = "";
            }
            label.translatesAutoresizingMaskIntoConstraints = false;
            contentView.addSubview(label);
            label.textAlignment = .center;
            // constrain the label
            let horizontalLabelConstraint: NSLayoutConstraint!
            if previousLabel == nil {
                // constrain to the left edge of the scrollview
                horizontalLabelConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1.0, constant: CGFloat(-1*pixelSecondRatio*max(-results[0].start, 0)));
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalLabelConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelHeight);
            let verticalLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1.0, constant: 0);
            
            // create the view that visualizes the duration
            let view = UIView();
            view.translatesAutoresizingMaskIntoConstraints = false;
            contentView.addSubview(view);
            if instruction.instruction == "Inhale" {
                view.backgroundColor = UIColor(red:0.96, green:0.94, blue:0.78, alpha:1.0);
            } else if instruction.instruction == "Exhale" {
                view.backgroundColor = UIColor(red:0.78, green:0.87, blue:0.96, alpha:1.0);
            } else {
                view.backgroundColor = .black;
            }
            // constrain the view
            let horizontalViewConstraint: NSLayoutConstraint!
            if previousLabel == nil {
                // constrain to the left edge of the scrollview
                horizontalViewConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalViewConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: viewHeight);
            let verticalViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0);
            
            // add all of the constraints
            scrollView.addConstraints([horizontalLabelConstraint, widthLabelConstraint, heightLabelConstraint, verticalLabelConstraint, horizontalViewConstraint, widthViewConstraint, heightViewConstraint, verticalViewConstraint]);
            
            // add the checkmark/x image to the view depending on whether or not it was completed
            var image: UIImage!
            if instruction.completed {
                // instruction was completed - mark with a checkmark
                image = UIImage(named: "greencheck");
            } else {
                // instruction was not completed - mark with red x
                image = UIImage(named: "redx");
            }
            let imageView: UIImageView = UIImageView(image: image);
            imageView.translatesAutoresizingMaskIntoConstraints = false;
            view.addSubview(imageView);
            let imageViewWidthConstraint: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40);
            let imageViewHeightConstraint: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 40);
            let centerYConstraint: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0);
            let centerXConstraint: NSLayoutConstraint = NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0);
            scrollView.addConstraints([imageViewWidthConstraint, imageViewHeightConstraint, centerYConstraint, centerXConstraint]);
            
            // increment the total duration by the current duration
            totalExerciseDuration += instruction.duration;
            
            // set current label as previous label
            previousLabel = label;
            
        }
        
        // iterate through the user's actions
        previousLabel = nil;
        for action in results {
            // first determine width based on duration
            let width = action.duration * pixelSecondRatio;
            
            // create the label that lists the action and duration
            let label = UILabel();
            label.font = label.font.withSize(15);
            if action.duration >= Constants.resultsViewDurationThreshold {
                let formattedDuration: String = String.init(format: "%.1f s", action.duration);
                label.text = formattedDuration;
            } else {
                label.text = "";
            }
            label.translatesAutoresizingMaskIntoConstraints = false;
            contentView.addSubview(label);
            label.textAlignment = .center;
            // constrain the label
            let horizontalLabelConstraint: NSLayoutConstraint!
            if previousLabel == nil {
                // constrain to the left edge of the scrollview
                horizontalLabelConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1.0, constant: CGFloat(-1*pixelSecondRatio*max(action.start, 0)));
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalLabelConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: label, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelHeight);
            let verticalLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .centerY, relatedBy: .equal, toItem: label, attribute: .top, multiplier: 1.0, constant: 0);
            
            // create the view that visualizes the duration
            let view = UIView();
            view.translatesAutoresizingMaskIntoConstraints = false;
            contentView.addSubview(view);
            if action.action == "Inhale" {
                view.backgroundColor = UIColor(red:0.96, green:0.94, blue:0.78, alpha:1.0);
            } else if action.action == "Exhale" {
                view.backgroundColor = UIColor(red:0.78, green:0.87, blue:0.96, alpha:1.0);
            } else {
                view.backgroundColor = .black;
            }
            // constrain the view
            let horizontalViewConstraint: NSLayoutConstraint!
            if previousLabel == nil {
                // constrain to the left edge of the scrollview
                horizontalViewConstraint = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalViewConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: viewHeight);
            let verticalViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0);
            
            // add all of the constraints
            scrollView.addConstraints([horizontalLabelConstraint, widthLabelConstraint, heightLabelConstraint, verticalLabelConstraint, horizontalViewConstraint, widthViewConstraint, heightViewConstraint, verticalViewConstraint]);
            
            // set current label as previous label
            previousLabel = label;
            
        }
        
        // set the end of the last label to the end of the content view
        let endConstraint: NSLayoutConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: CGFloat(-1*pixelSecondRatio*max(totalExerciseDuration-results[results.count-1].end, 0)));
        scrollView.addConstraint(endConstraint);
        
        // set the content size such that it shows the entire exercise
        let totalDisplayedDuration = totalExerciseDuration + min(results[0].start, 0) + max(results[results.count-1].end - totalExerciseDuration, 0);
        let totalDisplayedPixels = totalDisplayedDuration * pixelSecondRatio;
        scrollView.contentSize = CGSize(width: totalDisplayedPixels, height: 200);
        
    }
    

}
