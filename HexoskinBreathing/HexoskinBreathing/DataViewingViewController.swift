//
//  DataViewingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/16/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class DataViewingViewController: UIViewController {
    
    // exercise information and data
    var performanceResults: [(completed: Bool, instruction: String, duration: Double)]!;
    var results: [breathingAction]!;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("View did load");
        
        self.view.backgroundColor = .white;
        
        // print the performance results
        print("Performance results:");
        for result in performanceResults {
            print("\(result.instruction) \(result.duration) was completed: \(result.completed)");
        }
        print("\nUser Actions:");
        for action in results {
            print("\(action.action) \(action.duration)"); 
        }
    }
    

    
    

}
