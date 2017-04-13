//
//  Structs.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/23/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import Foundation

struct breathingAction {
    var action: String = "";
    var duration: Double = 0.0;
    var start: Double = 0;
    var end: Double = 0;
    var status: String = "";
    var metByInstruction: Int = -1;
    
    init(action: String, duration: Double, start: Double, end: Double) {
        self.action = action;
        self.duration = duration;
        self.start = start;
        self.end = end;
        self.status = Strings.ignored;
        self.metByInstruction = -1;
    }
    
    init(action: String, duration: Double, start: Double, end: Double, status: String) {
        self.action = action;
        self.duration = duration;
        self.start = start;
        self.end = end;
        self.status = status;
        self.metByInstruction = -1;
    }
    
    init(action: String, duration: Double, start: Double, end: Double, status: String, metByInstruction: Int) {
        self.action = action;
        self.duration = duration;
        self.start = start;
        self.end = end;
        self.status = status;
        self.metByInstruction = metByInstruction;
    }
}

struct InstructionDisplay {
    var label: UILabel!
    var timerLabel: UILabel!
    var labelVerticalConstraint: NSLayoutConstraint!
    var labelHorizontalConstraint: NSLayoutConstraint!
    var timerLabelHorizontalConstraint: NSLayoutConstraint!
    var duration: Double = 0.0;
}

struct ActionPosition {
    static let first: String = "actionPositionFirst";
    static let middle: String = "actionPositionMiddle";
    static let last: String = "actionPositionLast";
}

struct ActionCheckingHelper {
    
    var checkingState: ActionCheckingState!
    var lastCandidateActionStart: Double!
    var deviationStartTime: Double!
    var deviationStartAngle: Double!
    let deviationThresholdAngle: Double!
    var firstActionIsExhale: Bool!
    
    init() {
        checkingState = .none;
        lastCandidateActionStart = 0.0;
        deviationStartTime = 0.0;
        deviationStartAngle = 0.0;
        deviationThresholdAngle = 8;
        firstActionIsExhale = false;
    }
    
}

struct ErrorResult {
    
    var errors: [Double]!
    var percentErrors: [Double]!
    var averagePercentError: Double!
    var averagePercentUndershootError: Double!
    var averagePercentOvershootError: Double!
    var averageError: Double!
    var averageUndershootError: Double!
    var averageOvershootError: Double!
    var overshootInstructions: Double!
    var undershootInstructions: Double!
    var percentOvershootInstructions: Double!
    var percentUndershootInstructions: Double!
    
    init(percentErrors: [Double], errors: [Double]) {
        self.errors = errors;
        self.percentErrors = percentErrors;
        averagePercentError = 0.0;
        averagePercentUndershootError = 0.0;
        averagePercentOvershootError = 0.0;
        averageError = 0.0;
        averageUndershootError = 0.0;
        averageOvershootError = 0.0;
        overshootInstructions = 0.0;
        undershootInstructions = 0.0;
        percentOvershootInstructions = 0.0;
        percentUndershootInstructions = 0.0;
    }
    
    mutating func analyzeErrors() {
        
        // initialize helper variables
        var cumulativePercentError = 0.0;
        var cumulativePercentUndershootError = 0.0;
        var cumulativePercentOvershootError = 0.0;
        var percentUndershootCount = 0;
        var percentOvershootCount = 0;
        
        // using the percentErrors array, figure out the other error information
        for percentError in percentErrors {
            cumulativePercentError += abs(percentError);
            
            if percentError < 0 {
                cumulativePercentUndershootError += percentError;
                percentUndershootCount += 1;
            } else if percentError > 0 {
                cumulativePercentOvershootError += percentError;
                percentOvershootCount += 1;
            }
            
        }
        
        // set the error variables
        if percentErrors.count == 0 {
            averagePercentError = 0.0;
        } else {
            averagePercentError = cumulativePercentError / Double(percentErrors.count);
        }
        
        if percentUndershootCount == 0 {
            averagePercentUndershootError = 0.0;
            undershootInstructions = 0;
            percentUndershootInstructions = 0;
        } else {
            averagePercentUndershootError = cumulativePercentUndershootError / Double(percentUndershootCount);
            undershootInstructions = Double(percentUndershootCount);
            percentUndershootInstructions = Double(percentUndershootCount)/Double(percentErrors.count);
        }
        
        if percentOvershootCount == 0 {
            averagePercentOvershootError = 0.0;
            overshootInstructions = 0;
            percentOvershootInstructions = 0;
        } else {
            averagePercentOvershootError = cumulativePercentOvershootError / Double(percentOvershootCount);
            overshootInstructions = Double(percentOvershootCount);
            percentOvershootInstructions = Double(percentOvershootCount)/Double(percentErrors.count);
        }
        
        var cumulativeError = 0.0;
        var cumulativeUndershootError = 0.0;
        var cumulativeOvershootError = 0.0;
        var undershootCount = 0;
        var overshootCount = 0;
        
        // do the same with the non percent errors
        for error in errors {
            cumulativeError += abs(error);
            
            if error < 0 {
                cumulativeUndershootError += error;
                undershootCount += 1;
            } else if error > 0 {
                cumulativeOvershootError += error;
                overshootCount += 1;
            }
        }
        
        // set the error variables
        if errors.count == 0 {
            averageError = 0.0;
        } else {
            averageError = cumulativeError / Double(errors.count);
        }
        
        if undershootCount == 0 {
            averageUndershootError = 0.0;
        } else {
            averageUndershootError = cumulativeUndershootError / Double(undershootCount);
        }
        
        if overshootCount == 0 {
            averageOvershootError = 0.0;
        } else {
            averageOvershootError = cumulativeOvershootError / Double(overshootCount);
        }
        
    }
    
}





