//
//  BreathingExercise.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

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

class BreathingExercise: NSObject {
    
    var actionCount: Int!
    var currentAction: Int!
    var actions: [breathingAction]!
    
    override init() {
        // create a breathing exercise here
//        actions = [breathingAction(action: Strings.inhale, duration: 4, start: 0, end: 4), breathingAction(action: Strings.exhale, duration: 4, start: 4, end: 8)];
        
        actions = [breathingAction(action: Strings.inhale, duration: 4, start: 0, end: 4), breathingAction(action: Strings.exhale, duration: 4, start: 4, end: 8), breathingAction(action: Strings.inhale, duration: 6, start: 8, end: 14), breathingAction(action: Strings.exhale, duration: 6, start: 14, end: 20), breathingAction(action: Strings.inhale, duration: 8, start: 20, end: 28), breathingAction(action: Strings.exhale, duration: 8, start: 28, end: 36)];
        actionCount = actions.count;
        currentAction = -1;
    }
    
    func next() -> breathingAction {
        currentAction = currentAction + 1;
        if currentAction >= actionCount {
            return breathingAction(action: Strings.notAnAction, duration: 0, start: 0, end: 0);
        } else {
            return actions[currentAction];
        }
    }
    
    func reset() {
        currentAction = -1;
    }

}
