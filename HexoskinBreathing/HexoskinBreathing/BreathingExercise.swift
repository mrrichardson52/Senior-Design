//
//  BreathingExercise.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

//enum BreathingInstruction {
//    case Inhale
//    case Exhale
//    case Pause
//    case NotAnInstruction
//}

class BreathingExercise: NSObject {
    
    var instructionCount: Int!
    var currentInstruction: Int!
    var instructions: [Int : (instruction: String, duration: Float)]!
    
    override init() {
        print("BreathingExercise"); 
        // create a blank breathing exercise here 
        instructions = [0 : ("Inhale", 4), 1 : ("Pause", 2), 2 : ("Exhale", 4), 3 : ("Pause", 2), 4 : ("Inhale", 6), 5 : ("Pause", 2), 6 : ("Exhale", 6)];
        instructionCount = instructions.count;
        currentInstruction = -1;
    }
    
    func next() -> (complete: Bool, instruction: String, duration: Float){
        currentInstruction = currentInstruction + 1;
        if self.currentInstruction >= instructionCount {
            return (true, "Not an instruction", 0.0);
        } else {
            let next = instructions[currentInstruction];
            return (false, (next?.instruction)!, (next?.duration)!);
        }
    }
    
    func reset() {
        currentInstruction = -1; 
    }

}
