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
    static let inhaleIndicatorColor = UIColor(red:0.93, green:0.72, blue:0.24, alpha:1.0);
    static let exhaleIndicatorColor = UIColor(red:0.28, green:0.59, blue:0.85, alpha:1.0);
//    static let noDataIndicatorColor = UIColor(red:0.38, green:0.43, blue:0.44, alpha:1.0); // grayish
    static let noDataIndicatorColor = UIColor.black;
    static let inhaleIndicatorTextColor = UIColor.white
//    static let exhaleIndicatorTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // basic text color
    static let exhaleIndicatorTextColor = UIColor.white // silver color
//    static let noDataIndicatorTextColor = UIColor(red:0.90, green:0.87, blue:0.77, alpha:1.0) // grayish
    static let noDataIndicatorTextColor = UIColor.clear
    static let radioButtonUnselectedColor = UIColor(red:0.78, green:0.78, blue:0.74, alpha:1.0)
    static let radioButtonSelectedColor = UIColor(red:0.28, green:0.59, blue:0.85, alpha:1.0)
    
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
    static let avocadoColor = UIColor(red:0.15, green:0.50, blue:0.22, alpha:1.0);
    static let yellowPepperColor = UIColor(red:0.96, green:0.75, blue:0.25, alpha:1.0);
    static let aquaBlueColor = UIColor(red:0.19, green:0.66, blue:0.72, alpha:1.0);
    static let tomato = UIColor(red:0.81, green:0.22, blue:0.13, alpha:1.0);
    static let phoneBoothRed = UIColor(red:0.84, green:0.00, blue:0.15, alpha:1.0);
    static let flashColor = UIColor(red:0.93, green:0.72, blue:0.24, alpha:1.0);
    static let navyColor = UIColor(red:0.00, green:0.04, blue:0.16, alpha:1.0);
    static let peach = UIColor(red:1.00, green:0.80, blue:0.67, alpha:1.0)
    static let babyBlue = UIColor(red:0.76, green:0.88, blue:0.86, alpha:1.0)
    static let butter = UIColor(red:1.00, green:0.92, blue:0.58, alpha:1.0)
    static let butterScotch = UIColor(red:0.99, green:0.83, blue:0.46, alpha:1.0)
    
    // colors for ui elements
    static let navigationBarColor = UIColor(red:0.84, green:0.00, blue:0.15, alpha:1.0)
    static let backgroundColor = UIColor(red:0.97, green:0.96, blue:0.95, alpha:1.0)
    static let basicTextColor = UIColor.white
    static let basicButtonBackgroundColor = UIColor(red:0.84, green:0.00, blue:0.15, alpha:1.0);
    static let basicButtonTextColor = UIColor.white
    static let navigationBarDividerColor = UIColor(red:0.69, green:0.67, blue:0.63, alpha:1.0) // grayish
    static let secondaryTextColor = UIColor(red:0.71, green:0.51, blue:0.46, alpha:1.0) // dark tan
    static let highlightColor = UIColor(red:0.57, green:0.78, blue:0.66, alpha:1.0);
    static let darkViewBackground = UIColor(red:0.25, green:0.25, blue:0.25, alpha:1.0);
    static let completedColor = UIColor(red:0.15, green:0.50, blue:0.22, alpha:1.0);
    static let notCompletedColor = UIColor(red:0.84, green:0.00, blue:0.15, alpha:1.0);
    
    // various thresholds
    static let resultsViewDurationThreshold = 2.0;
    static let breathLengthAllowableError = 2.0;
    static let startBreathSearchWindow = 2.0;
    static let exerciseStartTimeAdjustment = 2.0;
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
