//
//  ExerciseDesignerViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/20/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class ExerciseDesignerViewController: UIViewController {
    
    // token information used for REST API calls
    var accessToken: String!
    var tokenType: String!
    
    
    // outlets
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationStepper: UIStepper!
    @IBOutlet weak var durationCountLabel: UILabel!
    @IBOutlet weak var cyclesLabel: UILabel!
    @IBOutlet weak var cyclesStepper: UIStepper!
    @IBOutlet weak var cyclesCountLabel: UILabel!
    @IBOutlet weak var metronomeSwitch: UISwitch!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Configure"
        
        // Do any additional setup after loading the view.
        prepareSteppers();
        prepareMetronomeSwitch();
        
        // create a next button in top right of navigation bar
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(ExerciseDesignerViewController.nextPressed));
    }
    
    // initialize steppers
    func prepareSteppers() {
        // configure duration stepper
        durationStepper.isContinuous = true;
        durationStepper.isUserInteractionEnabled = true;
        durationStepper.minimumValue = 4.0;
        durationStepper.maximumValue = 60.0;
        durationStepper.autorepeat = true;
        durationStepper.stepValue = 1.0;
        durationStepper.value = 6.0;
        durationCountLabel.text = "\(Int(durationStepper.value))";
        
        // configure cycle stepper
        cyclesStepper.isContinuous = true;
        cyclesStepper.isUserInteractionEnabled = true;
        cyclesStepper.minimumValue = 1.0;
        cyclesStepper.maximumValue = 20.0;
        cyclesStepper.autorepeat = true;
        cyclesStepper.stepValue = 1.0;
        cyclesStepper.value = 3.0;
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))";
    }
    
    func prepareMetronomeSwitch() {
        metronomeSwitch.isOn = true;
    }
    
    func nextPressed() {
        // create the exercise based on the stepper values and then push to exercise view controller
        let exercise = BreathingExercise(duration: durationStepper.value, cycles: Int(cyclesStepper.value));
        
        // instantiate the view controller from interface builder
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "exerciseViewController") as? ExerciseViewController;
        
        // set the authorization details and exercise members for the exercise view controller
        viewController?.playMetronome = metronomeSwitch.isOn; 
        viewController?.accessToken = accessToken;
        viewController?.tokenType = tokenType;
        viewController?.exercise = exercise;
        self.navigationController?.pushViewController(viewController!, animated: true);
    }
    
    @IBAction func durationStepperPressed(_ sender: Any) {
        durationCountLabel.text = "\(Int(durationStepper.value))";
    }
    
    @IBAction func cycleStepperPressed(_ sender: Any) {
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))";
    }

}
