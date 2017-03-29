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
    @IBOutlet weak var editTitleLabel: UILabel!
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
    @IBOutlet weak var editContainer: UIView!
    
    var editViews: [UIView]!
    var rowBeingEdited: Int = -1;
    
    // indicate signed in status
    var signedIn: Bool!
    
    // exercise sets
    // the exercise sets correspond to the entries in the scroll view and
    // the indices should be the same
    var exerciseSets: [(Double, Int)]!;
    
    // colors for elements
    let stepperLabelColor: UIColor = Constants.phoneBoothRed
    let stepperTitleLabelColor: UIColor = .black;
    let editContainerTitleColor: UIColor = .black
    let stepperColor: UIColor = .black;
    let switchColor: UIColor = Constants.electricBlue
    let borderColor: UIColor = Constants.avocadoColor;
    let addRowColor: UIColor = Constants.phoneBoothRed;
    let exerciseRowColor: UIColor = Constants.electricBlue;
    let continueButtonBackgroundColor: UIColor = Constants.avocadoColor;
    let metronomeLabelColor: UIColor = Constants.electricBlue
    let selectedBackgroundColor = Constants.backgroundColor;

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Create Exercise"
        
        editViews = [editTitleLabel, durationLabel, durationStepper, durationCountLabel, cyclesLabel, cyclesStepper, cyclesCountLabel, editContainer];
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.addBackButton()
        
        // Do any additional setup after loading the view.
        prepareSteppers();
        prepareMetronomeSwitch();
        setTextColorOfLabels();

        continueButton.setTitleColor(Constants.basicTextColor, for: .normal);
        continueButton.backgroundColor = continueButtonBackgroundColor;
        continueButton.layer.cornerRadius = 8;
        editContainer.layer.cornerRadius = 8;
        editContainer.backgroundColor = .white;
        editContainer.layer.borderColor = borderColor.cgColor;
        editContainer.layer.borderWidth = 2;
        
        // since the steppers have already been prepared with values, set the first exercise set equal 
        // to the stepper values
        exerciseSets = [(durationStepper.value, Int(cyclesStepper.value))];
        
        // set tableview delegates
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white;
        tableView.layer.borderColor = borderColor.cgColor;
        tableView.layer.borderWidth = 2;
        tableView.layer.cornerRadius = 8;
        tableView.bounces = false;
        
        // fade all views initially until a row is selected and the row should be edited
        fadeAllEditViews();
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated);
        
        self.showNavigationBar();
        
        tableView.reloadData();
    }

    func setTextColorOfLabels() {
        durationLabel.textColor = stepperTitleLabelColor;
        durationCountLabel.textColor = stepperLabelColor;
        cyclesLabel.textColor = stepperTitleLabelColor;
        cyclesCountLabel.textColor = stepperLabelColor;
        metronomeLabel.textColor = metronomeLabelColor;
        metronomeTitleLabel.textColor = metronomeLabelColor;
        editTitleLabel.textColor = editContainerTitleColor;
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
        durationStepper.tintColor = stepperColor;
        
        // configure cycle stepper
        cyclesStepper.isContinuous = true;
        cyclesStepper.isUserInteractionEnabled = true;
        cyclesStepper.minimumValue = 1.0;
        cyclesStepper.maximumValue = 20.0;
        cyclesStepper.autorepeat = true;
        cyclesStepper.stepValue = 1.0;
        cyclesStepper.value = 3.0;
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))x";
        cyclesStepper.tintColor = stepperColor;
    }
    
    func prepareMetronomeSwitch() {
        metronomeSwitch.isOn = true;
        metronomeLabel.text = "On";
        metronomeSwitch.onTintColor = switchColor;

    }
    
    @IBAction func ContinuePressed(_ sender: Any) {
        // create the exercise based on the stepper values and then push to exercise view controller
        if exerciseSets.count != 0 {
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
        } else {
            let alert = UIAlertController(title: "Exercise is empty", message: "Please add instructions.", preferredStyle: .alert);
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil));
            self.present(alert, animated: true, completion: nil);
        }
    }
    
    @IBAction func durationStepperPressed(_ sender: Any) {
        durationCountLabel.text = "\(Int(durationStepper.value))s";
        
        // check which cell is being edited and adjust that text and the exerciseSets entry
        let cell = tableView.cellForRow(at: IndexPath(row: rowBeingEdited, section: 0));
        let cycles = exerciseSets[rowBeingEdited].1;
        exerciseSets[rowBeingEdited] = (durationStepper.value, cycles);
        cell?.textLabel?.text = "\(Int(rowBeingEdited+1)). Inhale \(Int(exerciseSets[rowBeingEdited].0)) s, Exhale \(Int(exerciseSets[rowBeingEdited].0)) s   x   \(exerciseSets[rowBeingEdited].1)";
    }
    
    @IBAction func cycleStepperPressed(_ sender: Any) {
        cyclesCountLabel.text = "\(Int(cyclesStepper.value))x";
        
        let cell = tableView.cellForRow(at: IndexPath(row: rowBeingEdited, section: 0));
        let duration = exerciseSets[rowBeingEdited].0;
        exerciseSets[rowBeingEdited] = (duration, Int(cyclesStepper.value));
        cell?.textLabel?.text = "\(Int(rowBeingEdited+1)). Inhale \(Int(exerciseSets[rowBeingEdited].0)) s, Exhale \(Int(exerciseSets[rowBeingEdited].0)) s   x   \(exerciseSets[rowBeingEdited].1)";
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
        return exerciseSets.count + 1;
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        if indexPath.row == exerciseSets.count {
            // make a row that indicates they should press it to add a new instructions
            cell.textLabel?.text = "Add instruction set";
            cell.textLabel?.textColor = addRowColor;
        } else {
            cell.textLabel?.text = "\(Int(indexPath.row+1)). Inhale \(Int(exerciseSets[indexPath.row].0)) s, Exhale \(Int(exerciseSets[indexPath.row].0)) s   x   \(exerciseSets[indexPath.row].1)";
            cell.textLabel?.textColor = exerciseRowColor;
        }
        
        // check to see if this the row that is being edited
        // if so, set is as selected
        if indexPath.row == rowBeingEdited {
            cell.backgroundColor = selectedBackgroundColor;
        } else {
            cell.backgroundColor = UIColor.white;
        }
        
        return cell;
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // fade all edit views
            self.fadeAllEditViews();
            
            // clear the row being edited
            rowBeingEdited = -1;
            
            // deleting row at this indexPath
            removeExerciseSet(indexPath: indexPath);
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if indexPath.row == exerciseSets.count {
            return false;
        }
        return true;
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if rowBeingEdited != indexPath.row {
            
            // unfade edit views
            self.revealAllEditViews();
            editTitleLabel.text = "Edit instructions in row \(indexPath.row+1)";
            
            // set which row is being edited
            rowBeingEdited = indexPath.row;
            
            if indexPath.row == exerciseSets.count {
                // add set to exerciseSets
                exerciseSets.append((durationStepper.value, Int(cyclesStepper.value)));
            } else {
                // set the stepper values to that of the instruction being currently edited
                durationStepper.value = exerciseSets[rowBeingEdited].0;
                durationCountLabel.text = "\(Int(durationStepper.value))s";
                cyclesStepper.value = Double(exerciseSets[rowBeingEdited].1);
                cyclesCountLabel.text = "\(Int(cyclesStepper.value))x";
            }
            
        } else {
            rowBeingEdited = -1;
            self.fadeAllEditViews();
        }

        // reload data to observe changes
        tableView.reloadData();
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Your Exercise";
    }

//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerCell = tableView.dequeueReusableCell(withIdentifier: "HeaderCell")! as! CustomHeaderCell;
//        headerCell.backgroundColor = .white;
//        headerCell.titleLabel.textColor = Constants.navigationBarColor;
//        headerCell.titleBorderView.backgroundColor = Constants.navigationBarColor;
//        return headerCell;
//    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50;
    }
    
    func removeExerciseSet(indexPath: IndexPath) {
        exerciseSets.remove(at: indexPath.row);
        
        tableView.beginUpdates()
        
        // Note that indexPath is wrapped in an array:  [indexPath]
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        tableView.endUpdates()
        tableView.reloadData()
    }
    
    func fadeAllEditViews() {
        for view in editViews {
            view.alpha = 0;
        }
    }
    
    func revealAllEditViews() {
        for view in editViews {
            view.alpha = 1.0;
        }
    }



}
