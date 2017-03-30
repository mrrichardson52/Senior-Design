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
    
    init(action: String, duration: Double, start: Double, end: Double) {
        self.action = action;
        self.duration = duration;
        self.start = start;
        self.end = end;
        self.status = Strings.ignored;
    }
    
    init(action: String, duration: Double, start: Double, end: Double, status: String) {
        self.action = action;
        self.duration = duration;
        self.start = start;
        self.end = end;
        self.status = status;
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
