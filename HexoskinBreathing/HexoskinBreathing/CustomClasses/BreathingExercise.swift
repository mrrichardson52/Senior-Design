//
//  BreathingExercise.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class BreathingExercise: NSObject {
    
    var actionCount: Int!
    var currentAction: Int!
    var actions: [breathingAction]!
    var exerciseDuration: Double!
    
    override init() {
        actions = []; 
        actionCount = actions.count;
        currentAction = -1;
    }
    
    // create an exercise with the specified breath duration and the number of cycles
    init(duration: Double, cycles: Int) {
        actions = [];
        var lastEnding: Double = 0;
        for _ in 1...cycles {
            actions.append(breathingAction(action: Strings.inhale, duration: duration, start: lastEnding, end: duration + lastEnding));
            lastEnding += duration;
            actions.append(breathingAction(action: Strings.exhale, duration: duration, start: lastEnding, end: duration+lastEnding));
            lastEnding += duration;
        }
        self.exerciseDuration = lastEnding;
        print("Exercise Duration: \(self.exerciseDuration)"); 
        actionCount = actions.count;
        currentAction = -1;
    }
    
    func addExerciseSets(exerciseSets: [(Double, Int)]) {
        for set in exerciseSets {
            addExerciseSet(duration: set.0, cycles: set.1);
        }
        actionCount = actions.count;
    }
    
    // add exercise set to the existing exercise
    func addExerciseSet(duration: Double, cycles: Int) {
        var lastEnding: Double = 0;
        if actions.count == 0 {
            lastEnding = 0;
        } else {
            lastEnding = actions[actions.count-1].end;
        }
        for _ in 1...cycles {
            actions.append(breathingAction(action: Strings.inhale, duration: duration, start: lastEnding, end: duration + lastEnding));
            lastEnding += duration;
            actions.append(breathingAction(action: Strings.exhale, duration: duration, start: lastEnding, end: duration+lastEnding));
            lastEnding += duration;
        }
        self.exerciseDuration = lastEnding;
        actionCount = actions.count;
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
    
    func exerciseDescription() -> String {
        var description: String = "";
        var counter = 0;
        for action in actions {
            counter += 1;
            description += "\(counter). \(action.action) for \(action.duration) s\n";
        }
        return description;
    }

}
