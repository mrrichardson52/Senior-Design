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
    var exerciseData: [breathingAction]!;
    var hexoskinData: [breathingAction]!;
    var ringData: [breathingAction]!;
    
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
    
    // boolean that says whether or not to display the Hexoskin data
    var displayHexData: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        
        // prepare the views for autolayout
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        
        // set the colors of the indicator views
        inhaleIndicator.backgroundColor = Constants.inhaleIndicatorColor;
        exhaleIndicator.backgroundColor = Constants.exhaleIndicatorColor;
        noDataIndicator.backgroundColor = Constants.noDataIndicatorColor;
        inhaleIndicator.textColor = .black;
        exhaleIndicator.textColor = .black;
        noDataIndicator.textColor = .black;
        
        // print data before equalizing
        print("BEFORE EQUALIZING");
        printAllData();
        
        // prepare the data for display
        equalizeDataSources();
        
        // print data after equalizing
        print("\nAFTER EQUALIZING");
        printAllData();
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // now that the constraints are active, we can add the views to the scroll view
        populateScrollView();
    }
    
    func populateScrollView() {
                
        // add the views for all of the included data sources
        addViewsForDataSource(actions: exerciseData, section: 1, title: "Exercise");
        if displayHexData {
            addViewsForDataSource(actions: hexoskinData, section: 2, title: "Hexoskin data");
            addViewsForDataSource(actions: ringData, section: 3, title: "Ring data");
        } else {
            addViewsForDataSource(actions: ringData, section: 2, title: "Ring data");
        }
        
        // store the total exercise duration
        let totalExerciseDuration: Double = exerciseData[exerciseData.count-1].end - exerciseData[0].start;
        let totalDisplayedPixels = totalExerciseDuration * pixelSecondRatio;
        scrollView.contentSize = CGSize(width: totalDisplayedPixels, height: Double(scrollParentView.frame.height));
        
    }
    
    func equalizeDataSources() {
        
        // verify that the ringData array is not empty
        if ringData.count == 0 {
            ringData.append(breathingAction(action: Strings.notAnAction, duration: 0.0, start: 0.0, end: 0.0));
        }
        
        // grab the earliest start time and latest end time
        let earliestStart: Double!
        let latestEnding: Double!
        if displayHexData {
            earliestStart = min(exerciseData[0].start, hexoskinData[0].start, ringData[0].start);
            latestEnding = max(exerciseData[exerciseData.count-1].end, hexoskinData[hexoskinData.count-1].end, ringData[ringData.count-1].end);
        } else {
            earliestStart = min(exerciseData[0].start, ringData[0].start);
            latestEnding = max(exerciseData[exerciseData.count-1].end, ringData[ringData.count-1].end);
        }
        
        // check if the data source has a beginning equal to that of the earliest start.
        // if not, add a "not an action" action to the beginning of it.
        if exerciseData[0].start != earliestStart {
            exerciseData.insert(breathingAction(action: Strings.notAnAction, duration: exerciseData[0].start - earliestStart, start: earliestStart, end: exerciseData[0].start), at: 0);
        }
        if hexoskinData[0].start != earliestStart && displayHexData {
            hexoskinData.insert(breathingAction(action: Strings.notAnAction, duration: hexoskinData[0].start - earliestStart, start: earliestStart, end: hexoskinData[0].start), at: 0);
        }
        if ringData[0].start != earliestStart {
            ringData.insert(breathingAction(action: Strings.notAnAction, duration: ringData[0].start - earliestStart, start: earliestStart, end: ringData[0].start), at: 0);
        }
        
        // do the similar thing for the endings
        if exerciseData[exerciseData.count-1].end != latestEnding {
            exerciseData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - exerciseData[exerciseData.count-1].end, start: exerciseData[exerciseData.count-1].end, end: latestEnding));
        }
        if hexoskinData[hexoskinData.count-1].end != latestEnding && displayHexData {
            hexoskinData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - hexoskinData[hexoskinData.count-1].end, start: hexoskinData[hexoskinData.count-1].end, end: latestEnding));
        }
        if ringData[ringData.count-1].end != latestEnding {
            ringData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - ringData[ringData.count-1].end, start: ringData[ringData.count-1].end, end: latestEnding));
        }
        
    }

    func addViewsForDataSource(actions: [breathingAction], section: Int, title: String) {
        
        // store the heights for the two views
        let labelHeight = 21;
        let viewHeight = scrollParentView.frame.height * 0.33 * 0.5;
        print("View Height: \(viewHeight)");
        
        // calculate the distance from the top for the views
        let sectionHeight: Double = Double(scrollParentView.frame.height) * 0.33;
        let sectionPosition: Double = sectionHeight * (Double(section) - 1);
        let distanceToTop = sectionHeight * (Double(section) - 1) + sectionHeight * 0.4;
        print("Section Height: \(sectionHeight)");
        print("Distance to Top: \(distanceToTop)");
        
        // iterate through all of the actions
        var previousLabel: UILabel! = nil;
        for action in actions {
            
            // calculate width based on duration of current action
            let width = action.duration * pixelSecondRatio;
            
            // create the view that visualizes the duration
            let view = UIView();
            view.translatesAutoresizingMaskIntoConstraints = false;
            contentView.addSubview(view);
            if action.action == Strings.inhale {
                view.backgroundColor = Constants.inhaleIndicatorColor;
            } else if action.action == Strings.exhale {
                view.backgroundColor = Constants.exhaleIndicatorColor;
            } else if action.action == Strings.notAnAction || action.action == Strings.pause {
                view.backgroundColor = Constants.noDataIndicatorColor;
            } else {
                // code shouldn't reach this, so black will indicate error
                view.backgroundColor = UIColor.black;
            }
            
            // constrain the view
            let horizontalViewConstraint: NSLayoutConstraint!
            if previousLabel == nil {
                // constrain to the left edge of the scrollview
                horizontalViewConstraint = NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalViewConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: viewHeight);
            let verticalViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: CGFloat(-distanceToTop));
            
            
            // create the label that displays duration
            let label = UILabel();
            label.translatesAutoresizingMaskIntoConstraints = false;
            label.font = label.font.withSize(15);
            label.textAlignment = .center;
            label.backgroundColor = UIColor.clear;
            if action.duration >= Constants.resultsViewDurationThreshold && action.action != Strings.notAnAction {
                // display the duration
                let formattedText = String.init(format: "%.1f s", action.duration);
                label.text = formattedText;
            } else {
                // not worth showing the duration for such a short breath
                label.text = "";
            }
            view.addSubview(label);
            
            // constrain the label to the center of the previously added view
            let centerHorizontalLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1.0, constant: 0);
            let centerVerticalLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1.0, constant: 0);
            let widthLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightLabelConstraint: NSLayoutConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(labelHeight));

            
            // add all of the constraints
            scrollView.addConstraints([centerHorizontalLabelConstraint, widthLabelConstraint, heightLabelConstraint, centerVerticalLabelConstraint, horizontalViewConstraint, widthViewConstraint, heightViewConstraint, verticalViewConstraint]);
            
            // set current label as previous label
            previousLabel = label;
            
        }
        
        // add the title label at the top
        let titleLabel = UILabel();
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.text = title;
        titleLabel.textAlignment = .center;
        titleLabel.textColor = .black;
        titleLabel.font = titleLabel.font.withSize(25);
        scrollParentView.addSubview(titleLabel);
        
        // constrain the title
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: scrollParentView, attribute: .top, multiplier: 1.0, constant: CGFloat(sectionPosition));
        let titleHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(sectionHeight*0.4));
        let titleWidthConstraint = NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: scrollParentView, attribute: .width, multiplier: 1.0, constant: 0);
        let titleHorizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollParentView, attribute: .centerX, multiplier: 1.0, constant: 0);
        scrollParentView.addConstraints([titleTopConstraint, titleHorizontalConstraint, titleWidthConstraint, titleHeightConstraint]);
        
        // set the end of the last label to the end of the content view
        let endConstraint: NSLayoutConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0);
        scrollView.addConstraint(endConstraint);

    }

    // print all data for debugging purposes
    func printAllData() {
        print("\nExercise Data:");
        for action in exerciseData {
            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
        }
        print("\nHexoskin Data:");
        for action in hexoskinData {
            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
        }
        print("\nRing Data:");
        for action in ringData {
            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator);
        print("Before rotation");
        coordinator.animate(alongsideTransition: {
            _ in
            print("During rotation");
        }, completion: {
            _ in
            print("After rotation");
            DispatchQueue.main.async {
                self.scrollParentView.layoutSubviews()
            }
        })
        
    }
    
}
