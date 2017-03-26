//
//  ExerciseDesignerViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/20/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class ExerciseDesignerViewController: MRRViewController, UITableViewDelegate, UITableViewDataSource {
    
    // token information used for REST API calls
    var accessToken: String!
    var tokenType: String!
    
    
    // outlets
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var metronomeTitleLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var durationStepper: UIStepper!
    @IBOutlet weak var durationCountLabel: UILabel!
    @IBOutlet weak var cyclesLabel: UILabel!
    @IBOutlet weak var cyclesStepper: UIStepper!
    @IBOutlet weak var cyclesCountLabel: UILabel!
    @IBOutlet weak var metronomeSwitch: UISwitch!
    @IBOutlet weak var metronomeLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!

    // indicate signed in status
    var signedIn: Bool!
    
    // exercise sets
    // the exercise sets correspond to the entries in the scroll view and
    // the indices should be the same
    var exerciseSets: [(Double, Int)]!;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Configure"
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.addBackButton()
        
        // Do any additional setup after loading the view.
        prepareSteppers();
        prepareMetronomeSwitch();
        setTextColorOfLabels();
        

        continueButton.setTitleColor(Constants.basicTextColor, for: .normal);
        continueButton.backgroundColor = Constants.basicButtonBackgroundColor;
        continueButton.layer.cornerRadius = 8;
        
        exerciseSets = [];
        
        // set tableview delegates
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .clear;
        tableView.layer.borderColor = Constants.basicTextColor.cgColor;
        tableView.layer.borderWidth = 2;
        tableView.layer.cornerRadius = 8;
        tableView.bounces = false;
        
        // create a tap gesture recognizer for the image view
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(ExerciseDesignerViewController.arrowImageViewTapped));
        arrowImageView.isUserInteractionEnabled = true;
        arrowImageView.addGestureRecognizer(recognizer);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.showNavigationBar();
        
        tableView.reloadData();
    }

    func setTextColorOfLabels() {
        durationLabel.textColor = Constants.basicTextColor;
        durationCountLabel.textColor = Constants.basicTextColor;
        cyclesLabel.textColor = Constants.basicTextColor;
        cyclesCountLabel.textColor = Constants.basicTextColor;
        metronomeLabel.textColor = Constants.basicTextColor;
        metronomeTitleLabel.textColor = Constants.basicTextColor;
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
        durationCountLabel.text = "\(Int(durationStepper.value))s";
        durationStepper.tintColor = Constants.electricBlue;
        
        // configure cycle stepper
        cyclesStepper.isContinuous = true;
        cyclesStepper.isUserInteractionEnabled = true;
        cyclesStepper.minimumValue = 1.0;
        cyclesStepper.maximumValue = 20.0;
        cyclesStepper.autorepeat = true;
        cyclesStepper.stepValue = 1.0;
        cyclesStepper.value = 3.0;
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))x";
        cyclesStepper.tintColor = Constants.electricBlue;
    }
    
    func prepareMetronomeSwitch() {
        metronomeSwitch.isOn = true;
        metronomeLabel.text = "On";
        metronomeSwitch.onTintColor = Constants.electricBlue;

    }
    
    @IBAction func ContinuePressed(_ sender: Any) {
        // create the exercise based on the stepper values and then push to exercise view controller
        let exercise = BreathingExercise();
        exercise.addExerciseSets(exerciseSets: exerciseSets);
//        let exercise = BreathingExercise(duration: durationStepper.value, cycles: Int(cyclesStepper.value));
        
        // instantiate the view controller from interface builder
        let storyboard = UIStoryboard(name: "Main", bundle: nil);
        let viewController = storyboard.instantiateViewController(withIdentifier: "exerciseViewController") as? ExerciseViewController;
        
        // set the authorization details and exercise members for the exercise view controller
        viewController?.playMetronome = metronomeSwitch.isOn;
        viewController?.accessToken = accessToken;
        viewController?.tokenType = tokenType;
        viewController?.exercise = exercise;
        viewController?.signedIn = signedIn; 
        self.navigationController?.pushViewController(viewController!, animated: true);
    }
    
    @IBAction func durationStepperPressed(_ sender: Any) {
        durationCountLabel.text = "\(Int(durationStepper.value))s";
    }
    
    @IBAction func cycleStepperPressed(_ sender: Any) {
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))x";
    }

    @IBAction func metronomeSwitch(_ sender: Any) {
        if metronomeSwitch.isOn {
            metronomeLabel.text = "On";
        } else {
            metronomeLabel.text = "Off";
        }
    }
    
    @IBAction func addExerciseSet(_ sender: Any) {
        // here you are adding the exercise specified with the steppers to the scrollview.
        // you will also be adding this to an array of exercise sets
        addExerciseToList();
    }
    
    func addExerciseToList() {
        exerciseSets.append((durationStepper.value, Int(cyclesStepper.value)));
        tableView.reloadData();
    }
    
    // tableview delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exerciseSets.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = "\(Int(indexPath.row+1)). Inhale \(Int(exerciseSets[indexPath.row].0)) s, Exhale \(Int(exerciseSets[indexPath.row].0)) s   x   \(exerciseSets[indexPath.row].1)";
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = Constants.basicTextColor;
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // deleting row at this indexPath
            removeExerciseSet(indexPath: indexPath);
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete exercise set?", message: "Inhale \(Int(exerciseSets[indexPath.row].0)) s, Exhale \(Int(exerciseSets[indexPath.row].0)) s   x   \(exerciseSets[indexPath.row].1)", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: {
            _ in
            // delete the action exercise set at this index
            DispatchQueue.main.async {
                self.removeExerciseSet(indexPath: indexPath);
            }
        }));
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            _ in
            DispatchQueue.main.async {
                self.tableView.deselectRow(at: indexPath, animated: true);
            }
        }));
        self.present(alert, animated: true, completion: nil);
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Exercise";
    }
    
    func removeExerciseSet(indexPath: IndexPath) {
        exerciseSets.remove(at: indexPath.row);
        
        tableView.beginUpdates()
        
        // Note that indexPath is wrapped in an array:  [indexPath]
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    func arrowImageViewTapped() {
        addExerciseToList();
    }
    


}
