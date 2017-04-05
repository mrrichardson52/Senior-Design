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
