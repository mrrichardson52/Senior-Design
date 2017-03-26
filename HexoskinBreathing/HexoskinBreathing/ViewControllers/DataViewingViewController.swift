//
//  DataViewingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/16/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataViewingViewController: MRRViewController {
    
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
    var pixelSecondRatio: Double = 30;
    
    // boolean that says whether or not to display the Hexoskin data
    var displayHexData: Bool = false;
    var displayRingData: Bool = false;
    
    // graph border line height
    let borderLineHeight: CGFloat = 2;
    let borderLineColor: UIColor = .clear;
    let borderLineBuffer: CGFloat = 12;
    
    // base duration for exercise
    var baseDuration: Double = 0;
    
    // original exercise duration
    var exerciseDuration: Double = 0;
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.title = "Analysis";
        
        print("Exercise duration: \(exerciseDuration)");
        
        calculateThresholdsAndRatios();
        
        self.addBackButton()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(DataViewingViewController.donePressed));
        
        // prepare the views for autolayout
        scrollView.translatesAutoresizingMaskIntoConstraints = false;
        contentView.translatesAutoresizingMaskIntoConstraints = false;
        
        // set the colors of the indicator views
        inhaleIndicator.backgroundColor = Constants.inhaleIndicatorColor;
        exhaleIndicator.backgroundColor = Constants.exhaleIndicatorColor;
        noDataIndicator.backgroundColor = .black;
        inhaleIndicator.textColor = Constants.inhaleIndicatorTextColor;
        exhaleIndicator.textColor = Constants.exhaleIndicatorTextColor;
        noDataIndicator.textColor = Constants.basicTextColor;
        
        // set the background colors for the scrollview
        scrollView.backgroundColor = Constants.backgroundColor;
        contentView.backgroundColor = Constants.backgroundColor;
        scrollParentView.backgroundColor = Constants.backgroundColor;
        
        // prepare the data for display
        // only equalize if ring or hexoskin is showing
        if displayRingData || displayHexData {
//            print("\nBefore Equalization:\n");
//            printData(data: exerciseData, heading: "Exercise Data");
//            printData(data: hexoskinData, heading: "Hexoskin Data");
//            printData(data: ringData, heading: "Ring Data");
            
            equalizeDataSources();
            
//            print("After Equalization:\n");
//            printData(data: exerciseData, heading: "Exercise Data");
//            printData(data: hexoskinData, heading: "Hexoskin Data");
//            printData(data: ringData, heading: "Ring Data");
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.showNavigationBar();
        
        populateScrollView()
    }
    
    func donePressed() {
        // pop back to main menu
        _ = self.navigationController?.popToRootViewController(animated: true); 
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
        
        // add the title label at the top
        let titleLabel = UILabel();
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.text = title;
        titleLabel.textAlignment = .center;
        titleLabel.textColor = Constants.basicTextColor;
        titleLabel.font = titleLabel.font.withSize(25);
        scrollParentView.addSubview(titleLabel);
        
        // constrain the title
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: sectionViews[section], attribute: .top, multiplier: 1.0, constant: 0);
        let titleHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: sectionViews[section], attribute: .height, multiplier: 0.4, constant: 0);
        let titleWidthConstraint = NSLayoutConstraint(item: titleLabel, attribute: .width, relatedBy: .equal, toItem: scrollParentView, attribute: .width, multiplier: 1.0, constant: 0);
        let titleHorizontalConstraint = NSLayoutConstraint(item: titleLabel, attribute: .centerX, relatedBy: .equal, toItem: scrollParentView, attribute: .centerX, multiplier: 1.0, constant: 0);
        scrollParentView.addConstraints([titleTopConstraint, titleHorizontalConstraint, titleWidthConstraint, titleHeightConstraint]);
        
        // iterate through all of the actions
        var previousView: UIView! = nil;
        var counter = -1;
        for action in actions {
            counter += 1;
            
            // calculate width based on duration of current action
            let width = action.duration * pixelSecondRatio;
            
            // create the view that visualizes the duration
            var position: String = "";
            if counter == 0 {
                // first action
                position = ActionPosition.first;
            } else if action.end == exerciseDuration {
                // last action
                position = ActionPosition.last;
            } else {
                position = ActionPosition.middle;
            }
            let view = actionResultView(action: action, baseDuration: baseDuration, position: position);
            sectionViews[section].addSubview(view);
            
            // constrain the view
            let horizontalViewConstraint: NSLayoutConstraint!
            if previousView == nil {
                // constrain to the left edge of the scrollview
                horizontalViewConstraint = NSLayoutConstraint(item: sectionViews[section], attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
                
            } else {
                // constrain to the trailing edge of the previous view
                horizontalViewConstraint = NSLayoutConstraint(item: previousView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1.0, constant: 0);
            }
            let widthViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(width));
            let heightViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: view, attribute: .height, relatedBy: .equal, toItem: sectionViews[section], attribute: .height, multiplier: 0.5, constant: 0);
            let verticalViewConstraint: NSLayoutConstraint = NSLayoutConstraint(item: titleLabel, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0);
            
            // add all of the constraints
            scrollParentView.addConstraints([horizontalViewConstraint, widthViewConstraint, heightViewConstraint, verticalViewConstraint]);
            
            // set current label as previous label
            previousView = view;
            
        }
        
        // set the end of the last label to the end of the sectionview
        let endConstraint: NSLayoutConstraint = NSLayoutConstraint(item: previousView, attribute: .trailing, relatedBy: .equal, toItem: sectionViews[section], attribute: .trailing, multiplier: 1.0, constant: 0);
        scrollView.addConstraint(endConstraint);
        
        // add borderlines around the views
        let topBorderLine = UIView();
        topBorderLine.backgroundColor = borderLineColor;
        topBorderLine.translatesAutoresizingMaskIntoConstraints = false;
        sectionViews[section].addSubview(topBorderLine);
        var constraints: [NSLayoutConstraint] = [];
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .leading, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .trailing, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .trailing, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: topBorderLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: borderLineHeight));
        constraints.append(NSLayoutConstraint(item: previousView, attribute: .top, relatedBy: .equal, toItem: topBorderLine, attribute: .bottom, multiplier: 1.0, constant: borderLineBuffer));
        
//        let bottomBorderLine = UIView();
//        bottomBorderLine.backgroundColor = borderLineColor;
//        bottomBorderLine.translatesAutoresizingMaskIntoConstraints = false;
//        sectionViews[section].addSubview(bottomBorderLine);
//        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .leading, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .leading, multiplier: 1.0, constant: 0));
//        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .trailing, relatedBy: .equal, toItem: topBorderLine.superview, attribute: .trailing, multiplier: 1.0, constant: 0));
//        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: borderLineHeight));
//        constraints.append(NSLayoutConstraint(item: bottomBorderLine, attribute: .top, relatedBy: .equal, toItem: previousView, attribute: .bottom, multiplier: 1.0, constant: borderLineBuffer));

        // add the constraints to the section view
        sectionViews[section].addConstraints(constraints);
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
    
    func calculateThresholdsAndRatios() {
        
        baseDuration = exerciseData[0].duration;
        pixelSecondRatio = Double(self.view.frame.width)/(baseDuration*2);
        
    }
    
    func printData(data: [breathingAction], heading: String) {
        print("\n\(heading)");
        for action in data {
            print("\(action.action) \(action.duration)s start: \(action.start) end: \(action.end)");
        }
    }
    
}
