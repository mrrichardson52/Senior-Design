//
//  Constants.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/18/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import Foundation

// this files contains the constants for this project
struct Constants {
    
    // colors
//    static let inhaleIndicatorColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // basic text color
    static let inhaleIndicatorColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0); // silver color
    static let exhaleIndicatorColor = UIColor(red:0.71, green:0.51, blue:0.46, alpha:1.0)
//    static let noDataIndicatorColor = UIColor(red:0.38, green:0.43, blue:0.44, alpha:1.0); // grayish
    static let noDataIndicatorColor = UIColor.black;
    static let inhaleIndicatorTextColor = UIColor(red:0.71, green:0.51, blue:0.46, alpha:1.0)
//    static let exhaleIndicatorTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // basic text color
    static let exhaleIndicatorTextColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0); // silver color
//    static let noDataIndicatorTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // grayish
    static let noDataIndicatorTextColor = UIColor.clear
    static let radioButtonUnselectedColor = UIColor(red:0.78, green:0.78, blue:0.74, alpha:1.0)
    static let radioButtonSelectedColor = UIColor(red:0.28, green:0.59, blue:0.85, alpha:1.0);
    
    // specific colors
    static let latteColor = UIColor(red:0.87, green:0.74, blue:0.58, alpha:1.0)
    static let coffeeColor = UIColor(red:0.70, green:0.53, blue:0.40, alpha:1.0)
    static let sageColor = UIColor(red:0.63, green:0.75, blue:0.58, alpha:1.0);
    static let bluebellColor = UIColor(red:0.57, green:0.67, blue:0.78, alpha:1.0);
    static let honeydewColor = UIColor(red:0.89, green:0.87, blue:0.64, alpha:1.0);
    static let brownish = UIColor(red:0.65, green:0.49, blue:0.40, alpha:1.0)
    static let slate = UIColor(red:0.38, green:0.43, blue:0.44, alpha:1.0);
    static let banana = UIColor(red:1.00, green:0.86, blue:0.36, alpha:1.0);
    static let electricBlue = UIColor(red:0.28, green:0.59, blue:0.85, alpha:1.0);
    static let silverColor = UIColor(red:0.85, green:0.85, blue:0.85, alpha:1.0); 
    
    // colors for ui elements
    static let navigationBarColor = UIColor(red:0.13, green:0.12, blue:0.11, alpha:1.0) // dark color
    static let backgroundColor = UIColor(red:0.1, green:0.1, blue:0.1, alpha:1.0) // darker color than background
    static let basicTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // tannish color
    static let basicButtonBackgroundColor = UIColor(red:0.66, green:0.18, blue:0.25, alpha:1.0) // deep red
    static let basicButtonTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0)
    static let navigationBarDividerColor = UIColor(red:0.69, green:0.67, blue:0.63, alpha:1.0) // grayish
    static let secondaryTextColor = UIColor(red:0.71, green:0.51, blue:0.46, alpha:1.0) // dark tan
    static let highlightColor = UIColor(red:0.57, green:0.78, blue:0.66, alpha:1.0);
    static let darkViewBackground = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.0);
    static let completedColor = UIColor(red:0.25, green:0.42, blue:0.27, alpha:1.0);
    static let notCompletedColor = UIColor(red:0.80, green:0.00, blue:0.00, alpha:1.0);
    
    // various thresholds
    static let resultsViewDurationThreshold = 2.0;
    static let breathLengthAllowableError = 2.0;
    static let startBreathSearchWindow = 2.0;
    static let exerciseStartTimeAdjustment = 1.0; 
}

struct Strings {
    
    // strings for breathing actions
    static let inhale = "Inhale";
    static let exhale = "Exhale";
    static let pause = "Pause";
    static let notAnAction = "Not an action";
    static let completed = "completed";
    static let notCompleted = "notCompleted";
    static let ignored = "ignored"; 
    
}
