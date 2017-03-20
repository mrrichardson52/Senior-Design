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
    static let inhaleIndicatorColor = UIColor(red:0.96, green:0.94, blue:0.78, alpha:1.0)
    static let exhaleIndicatorColor = UIColor(red: 0.78, green: 0.87, blue: 0.96, alpha: 1.0)
    static let noDataIndicatorColor = UIColor.lightGray;
    static let radioButtonUnselectedColor = UIColor(red:0.78, green:0.78, blue:0.74, alpha:1.0)
    static let radioButtonSelectedColor = UIColor(red:0.00, green:0.49, blue:0.55, alpha:1.0);
    
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
