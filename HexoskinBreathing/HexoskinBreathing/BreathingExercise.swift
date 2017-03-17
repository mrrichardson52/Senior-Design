//
//  BreathingExercise.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit


class BreathingExercise: NSObject {
    
    var instructionCount: Int!
    var currentInstruction: Int!
    var instructions: [Int : (instruction: String, duration: Double)]!
    
    override init() {
        print("BreathingExercise"); 
        // create a blank breathing exercise here 
//        instructions = [0 : ("Inhale", 2)];
        instructions = [0 : ("Inhale", 4), 1 : ("Exhale", 4), 2 : ("Inhale", 6), 3 : ("Exhale", 6), 4 : ("Inhale", 6), 5 : ("Exhale", 6)];
        instructionCount = instructions.count;
        currentInstruction = -1;
    }
    
    func next() -> (complete: Bool, instruction: String, duration: Double){
        currentInstruction = currentInstruction + 1;
        if self.currentInstruction >= instructionCount {
            return (true, "Not an instruction", 0.0);
        } else {
            let next = instructions[currentInstruction];
            return (false, (next?.instruction)!, (next?.duration)!);
        }
    }
    
    func stringAtIndex(index: Int) -> String {
        
        if index > instructionCount - 1 {
            return "--";
        }
        return String.init(format: "%@ %.2f", (instructions[index]?.instruction)!, (instructions[index]?.duration)!);
    }
    
    func reset() {
        currentInstruction = -1; 
    }

}
