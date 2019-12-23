//
//  DataViewingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/16/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataViewingViewController: MRRViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    // colors for ui elements
    let sectionTitleColor: UIColor = .black; 
    
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
    
    // statistics views
//    @IBOutlet weak var instructionsCompletedTitleLabel: UILabel!
//    @IBOutlet weak var errorTitleLabel: UILabel!
//    @IBOutlet weak var instructionsCompletedLabel: UILabel!
//    @IBOutlet weak var errorLabel: UILabel!
//    @IBOutlet weak var errorContainer: UIView!
//    @IBOutlet weak var instructionsCompletedContainer: UIView!
    
    // stats
    var percentInstructionsCompleted: Double!
    var percentErrorPerInstruction: Double!
    
    var caratLabels: [UILabel]!

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
    var baseDuration: Double!;
    
    // original exercise duration
    var exerciseDuration: Double = 0;
    
    // data used to load up the tableview
    var dataToBeViewed: [(String, [(String, Double)])] = []; 
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        self.title = "Analysis";
                
        calculateThresholdsAndRatios();
        
        caratLabels = [];
        
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
        scrollView.delegate = self;
        
        // set up the tableview
        tableView.layer.borderColor = UIColor.black.cgColor;
        tableView.layer.borderWidth = 3;
        tableView.layer.cornerRadius = 8;
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.reloadData(); 
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

    func addViewsForDataSource(actions: [breathingAction], section: Int, title: String) {
        
        // add the title label at the top
        let titleLabel = UILabel();
        titleLabel.translatesAutoresizingMaskIntoConstraints = false;
        titleLabel.text = title;
        titleLabel.textAlignment = .center;
        titleLabel.textColor = sectionTitleColor;
        titleLabel.font = titleLabel.font.withSize(20);
        scrollParentView.addSubview(titleLabel);
        
        // constrain the title
        let titleTopConstraint = NSLayoutConstraint(item: titleLabel, attribute: .top, relatedBy: .equal, toItem: sectionViews[section], attribute: .top, multiplier: 1.0, constant: 0);
        let titleHeightConstraint = NSLayoutConstraint(item: titleLabel, attribute: .height, relatedBy: .equal, toItem: sectionViews[section], attribute: .height, multiplier: 0.3, constant: 0);
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
            
            var showTimestamps: Bool = false;
            if section == 0 {
                showTimestamps = true;
            }
            let view = actionResultView(action: action, baseDuration: baseDuration, position: position, showTimestamps: showTimestamps);
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
        
        // add the constraints to the section view
        sectionViews[section].addConstraints(constraints);
        
        // create a UILabel and display it at the right side of the section view to indicate
        // scrollability
        if 2*baseDuration < exerciseDuration {
            let label = UILabel();
            label.translatesAutoresizingMaskIntoConstraints = false;
            label.text = ">";
            label.textColor = .white;
            label.textAlignment = .right;
            label.font = label.font.withSize(20);
            scrollParentView.addSubview(label);
            constraints = [];
            constraints.append(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: label.superview, attribute: .trailing, multiplier: 1.0, constant: -10));
            constraints.append(NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 25));
            constraints.append(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 30));
            constraints.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: previousView, attribute: .top, multiplier: 1.0, constant: 5));
            scrollParentView.addConstraints(constraints);
            caratLabels.append(label);
        }
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
        
        if baseDuration == nil {
            baseDuration = 6;
        }
        pixelSecondRatio = Double(self.view.frame.width)/(baseDuration*2);
    }
    
//    func printData(data: [breathingAction], heading: String) {
//        print("\n\(heading)");
//        for action in data {
//            print("\(action.action) \(action.duration)s start: \(action.start) end: \(action.end)");
//        }
//    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Once the scroll view scrolls, hide the carats indicating scroll functionality
        for label in caratLabels {
            label.alpha = 0.0;
        }
    }
    
    // MARK: Table View Functions
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "dataViewingCell") as! DataViewingTableViewCell;
        cell.contentView.backgroundColor = .white;
        let sectionValues = dataToBeViewed[indexPath.section].1;
        cell.descriptionLabel.text = sectionValues[indexPath.row].0;
        
        // format the value label
        let value = sectionValues[indexPath.row].1;
        var formattedString = "";
        if abs(value) < 1 {
            formattedString = String.init(format: "%.3f", value);
        } else if abs(value) < 10 {
            formattedString = String.init(format: "%.2f", value);
        } else if abs(value) < 100 {
            formattedString = String.init(format: "%.1f", value);
        } else {
            formattedString = String.init(format: "%.0f", value);
        }
        
        cell.valueLabel.text = formattedString;
        return cell;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataToBeViewed.count;
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataToBeViewed[section].1.count;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataToBeViewed[section].0;
    }
}
