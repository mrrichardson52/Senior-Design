//
//  BreathingExercise.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

enum BreathingInstruction {
    case Inhale
    case Exhale
    case Pause
}

class BreathingExercise: NSObject {
    
    var instructionCount: Int!
    var instructions: [BreathingInstruction : Float]!
    
    func BreathingExercise() {
        // create a blank breathing exercise here 
        instructions = [.Inhale : 4, .Pause : 2, .Exhale : 4, .Pause : 2, .Inhale : 6, .Pause : 2, .Exhale : 6];
        instructionCount = instructions.count;
    }

}
