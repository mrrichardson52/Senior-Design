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
