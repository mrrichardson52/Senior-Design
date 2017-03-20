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

    // section views within scroll view
    // index 0 is the top third
    // index 1 is the middle third
    // index 2 is the bottom third
    var sectionViews: [UIView]! = nil;
    
    // ratio of pixels to seconds
    let pixelSecondRatio: Double = 30;
    
    // boolean that says whether or not to display the Hexoskin data
    var displayHexData: Bool = false;
    var displayRingData: Bool = false;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white;
        
        self.title = "Analysis"; 
        
        // remove the back button here
//        self.navigationItem.setHidesBackButton(true, animated: false);
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DataViewingViewController.donePressed));
        
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
//        print("BEFORE EQUALIZING");
//        printAllData();
        
        // prepare the data for display
        // only equalize if ring or hexoskin is showing
        if displayRingData || displayHexData {
            equalizeDataSources();
        }
        
        // print data after equalizing
//        print("\nAFTER EQUALIZING");
//        printAllData();
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated);
        
        // now that the constraints are active, we can add the views to the scroll view
        populateScrollView();
    }
    
    func donePressed() {
        
    }
    
    func populateScrollView() {
        
        // add the section views to the content view in the scroll. 
        // these will each store the data source views
        addSectionViews();
        
        // add the views for all of the included data sources
        addViewsForDataSource(actions: exerciseData, section: 0, title: "Exercise");
        if displayHexData {
            addViewsForDataSource(actions: hexoskinData, section: 1, title: "Hexoskin data");
            if displayRingData {
                addViewsForDataSource(actions: ringData, section: 2, title: "Ring data");
            }
        } else if displayRingData {
            addViewsForDataSource(actions: ringData, section: 1, title: "Ring data");
        }
        
        // store the total exercise duration
        let totalExerciseDuration: Double = exerciseData[exerciseData.count-1].end - exerciseData[0].start;
        let totalDisplayedPixels = totalExerciseDuration * pixelSecondRatio;
        scrollView.contentSize = CGSize(width: totalDisplayedPixels, height: Double(scrollParentView.frame.height));
        
    }
    
    func equalizeDataSources() {
        
        // verify that the ringData array is not empty
        if displayRingData && ringData.count == 0 {
            ringData.append(breathingAction(action: Strings.notAnAction, duration: 0.0, start: 0.0, end: 0.0));
        }
        
        // verify that the hexData array is not empty
        if displayHexData && hexoskinData.count == 0 {
            ringData.append(breathingAction(action: Strings.notAnAction, duration: 0.0, start: 0.0, end: 0.0));
        }
        
        // grab the earliest start time and latest end time
        let earliestStart: Double!
        let latestEnding: Double!
        if displayHexData && displayRingData {
            earliestStart = min(exerciseData[0].start, hexoskinData[0].start, ringData[0].start);
            latestEnding = max(exerciseData[exerciseData.count-1].end, hexoskinData[hexoskinData.count-1].end, ringData[ringData.count-1].end);
        } else if displayRingData {
            earliestStart = min(exerciseData[0].start, ringData[0].start);
            latestEnding = max(exerciseData[exerciseData.count-1].end, ringData[ringData.count-1].end);
        } else {
            earliestStart = min(exerciseData[0].start, hexoskinData[0].start);
            latestEnding = max(exerciseData[exerciseData.count-1].end, hexoskinData[hexoskinData.count-1].end);
        }
        
        // check if the data source has a beginning equal to that of the earliest start.
        // if not, add a "not an action" action to the beginning of it.
        if exerciseData[0].start != earliestStart {
            exerciseData.insert(breathingAction(action: Strings.notAnAction, duration: exerciseData[0].start - earliestStart, start: earliestStart, end: exerciseData[0].start), at: 0);
        }
        if displayHexData && hexoskinData[0].start != earliestStart {
            hexoskinData.insert(breathingAction(action: Strings.notAnAction, duration: hexoskinData[0].start - earliestStart, start: earliestStart, end: hexoskinData[0].start), at: 0);
        }
        if displayRingData && ringData[0].start != earliestStart {
            ringData.insert(breathingAction(action: Strings.notAnAction, duration: ringData[0].start - earliestStart, start: earliestStart, end: ringData[0].start), at: 0);
        }
        
        // do the similar thing for the endings
        if exerciseData[exerciseData.count-1].end != latestEnding {
            exerciseData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - exerciseData[exerciseData.count-1].end, start: exerciseData[exerciseData.count-1].end, end: latestEnding));
        }
        if displayHexData && hexoskinData[hexoskinData.count-1].end != latestEnding {
            hexoskinData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - hexoskinData[hexoskinData.count-1].end, start: hexoskinData[hexoskinData.count-1].end, end: latestEnding));
        }
        if displayRingData && ringData[ringData.count-1].end != latestEnding {
            ringData.append(breathingAction(action: Strings.notAnAction, duration: latestEnding - ringData[ringData.count-1].end, start: ringData[ringData.count-1].end, end: latestEnding));
        }
        
    }

    func addViewsForDataSource(actions: [breathingAction], section: Int, title: String) {
        
        // store the heights for label
        let labelHeight = 21;
        
        // add the title label at the top
        let titleLabel = UILabel();
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.text = title;
        titleLabel.textAlignment = .center;
        titleLabel.textColor = .black;
        titleLabel.font = titleLabel.font.withSize(25);
        scrollParentView.addSubview(titleLabel);
        
        // constrain the title
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: sectionViews[section], attribute: .top, multiplier: 1.0, constant: 0);
        let titleHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: sectionViews[section], attribute: .height, multiplier: 0.4, constant: 0);
        let titleWidthConstraint = NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: scrollParentView, attribute: .width, multiplier: 1.0, constant: 0);
        let titleHorizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollParentView, attribute: .centerX, multiplier: 1.0, constant: 0);
        scrollParentView.addConstraints([titleTopConstraint, titleHorizontalConstraint, titleWidthConstraint, titleHeightConstraint]);
        
        // iterate through all of the actions
        var previousLabel: UILabel! = nil;
        for action in actions {
            
            // calculate width based on duration of current action
            let width = action.duration * pixelSecondRatio;
            
            // create the view that visualizes the duration
            let view = UIView();
            view.translatesAutoresizingMaskIntoConstraints = false;
            sectionViews[section].addSubview(view);
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
                horizontalViewConstraint = NSLayoutConstraint(item: sectionViews[section], attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalViewConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: sectionViews[section], attribute: .height, multiplier: 0.5, constant: 0);
            let verticalViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0);
            
            
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
            scrollParentView.addConstraints([centerHorizontalLabelConstraint, widthLabelConstraint, heightLabelConstraint, centerVerticalLabelConstraint, horizontalViewConstraint, widthViewConstraint, heightViewConstraint, verticalViewConstraint]);
            
            // set current label as previous label
            previousLabel = label;
            
        }
        
        
        // set the end of the last label to the end of the sectionview
        let endConstraint: NSLayoutConstraint = NSLayoutConstraint(item: previousLabel, attribute: .trailing, relatedBy: .equal, toItem: sectionViews[section], attribute: .trailing, multiplier: 1.0, constant: 0);
        scrollView.addConstraint(endConstraint);

    }
    
    func addSectionViews() {
        // iterate three times to make three uiviews
        sectionViews = [];
        var previousSectionView: UIView!
        var constraintsArray: [NSLayoutConstraint]!
        for index in 0...2 {
            
            // clear the constraintsArray
            constraintsArray = [];
            
            // create the view
            let sectionView = UIView();
            sectionView.backgroundColor = .clear;
            sectionView.translatesAutoresizingMaskIntoConstraints = false;
            sectionViews.append(sectionView);
            contentView.addSubview(sectionViews[sectionViews.count-1]);
            
            // constrain the view, but don't add the width in yet since that will be determined 
            // when the data source views are added
            constraintsArray.append(NSLayoutConstraint(item: contentView, attribute: .leading, relatedBy: .equal, toItem: sectionView, attribute: .leading, multiplier: 1.0, constant: 0));
            if index == 0 {
                constraintsArray.append(NSLayoutConstraint(item: contentView, attribute: .top, relatedBy: .equal, toItem: sectionView, attribute: .top, multiplier: 1.0, constant: 0));
            } else if index == 1 {
                constraintsArray.append(NSLayoutConstraint(item: previousSectionView, attribute: .bottom, relatedBy: .equal, toItem: sectionView, attribute: .top, multiplier: 1.0, constant: 0));
                constraintsArray.append(NSLayoutConstraint(item: previousSectionView, attribute: .height, relatedBy: .equal, toItem: sectionView, attribute: .height, multiplier: 1.0, constant: 0));
            } else {
                constraintsArray.append(NSLayoutConstraint(item: previousSectionView, attribute: .bottom, relatedBy: .equal, toItem: sectionView, attribute: .top, multiplier: 1.0, constant: 0));
                constraintsArray.append(NSLayoutConstraint(item: contentView, attribute: .bottom, relatedBy: .equal, toItem: sectionView, attribute: .bottom, multiplier: 1.0, constant: 0));
                constraintsArray.append(NSLayoutConstraint(item: previousSectionView, attribute: .height, relatedBy: .equal, toItem: sectionView, attribute: .height, multiplier: 1.0, constant: 0));
            }
            constraintsArray.append(NSLayoutConstraint(item: sectionView, attribute: .trailing, relatedBy: .equal, toItem: contentView, attribute: .trailing, multiplier: 1.0, constant: 0))
            scrollView.addConstraints(constraintsArray);
            
            previousSectionView = sectionView;
        }
    }

//    // print all data for debugging purposes
//    func printAllData() {
//        print("\nExercise Data:");
//        for action in exerciseData {
//            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
//        }
//        print("\nHexoskin Data:");
//        for action in hexoskinData {
//            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
//        }
//        print("\nRing Data:");
//        for action in ringData {
//            print("\(action.action) \(action.duration) start: \(action.start) end: \(action.end)");
//        }
//    }
    
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
