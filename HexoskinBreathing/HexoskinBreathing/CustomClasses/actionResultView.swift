//
//  actionResultView.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/22/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class actionResultView: UIView {
    
    // subviews
    var numberLabel: UILabel!
    var indicatorView: UIView!
    
    // saved constraints
    var indicatorHeightConstraint: NSLayoutConstraint!
    
    // threshold values
    var minimumBreathPercentageForLabel: Double = 0.48;
    
    // customizing values
    var fontSize: CGFloat! = 25;
    var labelHeight: CGFloat! = 50;
    var indicatorViewBuffer: CGFloat! = 3;
    var indicatorViewHeight: CGFloat! = 5;
    
    // timestamp view parameters
    var tickHeight: CGFloat = 8
    var tickWidth: CGFloat = 2;
    var timeLabelWidth: CGFloat = 45;
    var timeLabelHeight: CGFloat = 21;
    var timeLabelFontSize: CGFloat = 15;
    var tickViewToLabelDistance: CGFloat = 3;
    var tickViewLabelOffset: CGFloat = 3;
    

    init(action: breathingAction, baseDuration: Double, position: String, showTimestamps: Bool) {
        super.init(frame: .zero);
        self.translatesAutoresizingMaskIntoConstraints = false;
        
        // if action is notAnAction/pause, no other info is needed in the view
        if action.action == Strings.notAnAction || action.action == Strings.pause {
            self.backgroundColor = Constants.noDataIndicatorColor;
            return;
        }
        
        switch action.action {
        case Strings.inhale:
            self.backgroundColor = Constants.inhaleIndicatorColor;
            break;
        case Strings.exhale:
            self.backgroundColor = Constants.exhaleIndicatorColor;
            break;
        default:
            // nothing should reach this point
            self.backgroundColor = Constants.noDataIndicatorColor;
            break;
        }
        
        // if duration is too short or the action is not an inhale or exhale, no more 
        // information is needed past the action indicator color. just return
        if action.duration < minimumBreathPercentageForLabel*baseDuration || action.action == Strings.notAnAction || action.action == Strings.pause {
            return;
        }
        
        // initialize array of constraints
        var constraints: [NSLayoutConstraint] = [];
        
        // configure the number label
        numberLabel = UILabel();
        numberLabel.translatesAutoresizingMaskIntoConstraints = false;
        self.addSubview(numberLabel);
        numberLabel.font = numberLabel.font.withSize(fontSize);
        numberLabel.textAlignment = .center;
        let formattedString = String.init(format: "%.1f s", action.duration);
        numberLabel.text = formattedString;
        
        // set the color of the number label
        if action.action == Strings.inhale {
            numberLabel.textColor = Constants.inhaleIndicatorTextColor;
        } else if action.action == Strings.exhale {
            numberLabel.textColor = Constants.exhaleIndicatorTextColor; 
        }
        
        // constrain the label
        constraints.append(NSLayoutConstraint(item: numberLabel, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: numberLabel, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: numberLabel, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: numberLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: labelHeight));
        
        // configure the indicator view
        if action.status != Strings.ignored {
            
            // initialize the indicator view
            indicatorView = UIView();
            indicatorView.translatesAutoresizingMaskIntoConstraints = false;
            self.addSubview(indicatorView);
            
            if action.status == Strings.completed {
                indicatorView.backgroundColor = Constants.completedColor;
            } else if action.status == Strings.notCompleted {
                indicatorView.backgroundColor = Constants.notCompletedColor;
            }
            
            // constrain the view
            constraints.append(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: indicatorView, attribute: .bottom, multiplier: 1.0, constant: indicatorViewBuffer));
            constraints.append(NSLayoutConstraint(item: indicatorView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: indicatorViewBuffer));
            constraints.append(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: indicatorView, attribute: .trailing, multiplier: 1.0, constant: indicatorViewBuffer));
            constraints.append(NSLayoutConstraint(item: indicatorView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: indicatorViewHeight));
        }
        
        // add the constraints to this view
        self.addConstraints(constraints);
        
        // add a timerstamp label here if this is the exercise data
        //        if action.status != Strings.ignored {
        // this action belongs to the exercise
        // create a view and a label.
        // The view is a vertical tick that points to the spot in time
        // The label displays the time
        if showTimestamps == true {
            let tickView = UIView();
            tickView.translatesAutoresizingMaskIntoConstraints = false;
            tickView.backgroundColor = .black;
            self.addSubview(tickView);
            constraints = [];
            constraints.append(NSLayoutConstraint(item: tickView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0));
            constraints.append(NSLayoutConstraint(item: tickView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tickWidth));
            constraints.append(NSLayoutConstraint(item: tickView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tickHeight));
            constraints.append(NSLayoutConstraint(item: tickView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 2));
            
            let timeLabel = UILabel();
            timeLabel.translatesAutoresizingMaskIntoConstraints = false;
            timeLabel.backgroundColor = .clear;
            timeLabel.textColor = .black;
            timeLabel.text = "\(Int(action.start)) s";
            self.addSubview(timeLabel);
            constraints.append(NSLayoutConstraint(item: timeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: timeLabelHeight));
            constraints.append(NSLayoutConstraint(item: timeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: timeLabelWidth));
            if position == ActionPosition.first {
                constraints.append(NSLayoutConstraint(item: timeLabel, attribute: .leading, relatedBy: .equal, toItem: tickView, attribute: .trailing, multiplier: 1.0, constant: tickViewToLabelDistance));
                timeLabel.textAlignment = .left;
            } else {
                constraints.append(NSLayoutConstraint(item: timeLabel, attribute: .centerX, relatedBy: .equal, toItem: tickView, attribute: .centerX, multiplier: 1.0, constant: 0));
                timeLabel.textAlignment = .center;
            }
            constraints.append(NSLayoutConstraint(item: timeLabel, attribute: .top, relatedBy: .equal, toItem: tickView, attribute: .bottom, multiplier: 1.0, constant: tickViewLabelOffset));
            
            // if this is the last view, add another time label and tick for the end
            if position == ActionPosition.last {
                let endTickView = UIView()
                endTickView.translatesAutoresizingMaskIntoConstraints = false;
                endTickView.backgroundColor = .black;
                self.addSubview(endTickView);
                constraints.append(NSLayoutConstraint(item: endTickView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0));
                constraints.append(NSLayoutConstraint(item: endTickView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tickWidth));
                constraints.append(NSLayoutConstraint(item: endTickView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: tickHeight));
                constraints.append(NSLayoutConstraint(item: endTickView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 2));
                
                let endTimeLabel = UILabel();
                endTimeLabel.translatesAutoresizingMaskIntoConstraints = false;
                endTimeLabel.backgroundColor = .clear;
                endTimeLabel.textColor = .black;
                endTimeLabel.text = "\(Int(action.end)) s";
                endTimeLabel.textAlignment = .right;
                self.addSubview(endTimeLabel);
                constraints.append(NSLayoutConstraint(item: endTimeLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: timeLabelHeight));
                constraints.append(NSLayoutConstraint(item: endTimeLabel, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: timeLabelWidth));
                constraints.append(NSLayoutConstraint(item: endTimeLabel, attribute: .trailing, relatedBy: .equal, toItem: endTickView, attribute: .leading, multiplier: 1.0, constant: -tickViewToLabelDistance));
                constraints.append(NSLayoutConstraint(item: endTimeLabel, attribute: .top, relatedBy: .equal, toItem: tickView, attribute: .bottom, multiplier: 1.0, constant: tickViewLabelOffset));
                
            }
            
            // add the constraints to this view
            self.addConstraints(constraints);
            
        }
//        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        // do not intend on creating these views in IB
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
//    func addBorder(edges: UIRectEdge, color: UIColor = UIColor.white, thickness: CGFloat = 1.0) -> [UIView] {
//        
//        var borders = [UIView]()
//        
//        func border() -> UIView {
//            let border = UIView(frame: CGRect.zero)
//            border.backgroundColor = color
//            border.translatesAutoresizingMaskIntoConstraints = false
//            return border
//        }
//        
//        if edges.contains(.top) || edges.contains(.all) {
//            let top = border()
//            addSubview(top)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[top(==thickness)]",
//                                               options: [],
//                                               metrics: ["thickness": thickness],
//                                               views: ["top": top]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[top]-(0)-|",
//                                               options: [],
//                                               metrics: nil,
//                                               views: ["top": top]))
//            borders.append(top)
//        }
//        
//        if edges.contains(.left) || edges.contains(.all) {
//            let left = border()
//            addSubview(left)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[left(==thickness)]",
//                                               options: [],
//                                               metrics: ["thickness": thickness],
//                                               views: ["left": left]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[left]-(0)-|",
//                                               options: [],
//                                               metrics: nil,
//                                               views: ["left": left]))
//            borders.append(left)
//        }
//        
//        if edges.contains(.right) || edges.contains(.all) {
//            let right = border()
//            addSubview(right)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:[right(==thickness)]-(0)-|",
//                                               options: [],
//                                               metrics: ["thickness": thickness],
//                                               views: ["right": right]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[right]-(0)-|",
//                                               options: [],
//                                               metrics: nil,
//                                               views: ["right": right]))
//            borders.append(right)
//        }
//        
//        if edges.contains(.bottom) || edges.contains(.all) {
//            let bottom = border()
//            addSubview(bottom)
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "V:[bottom(==thickness)]-(0)-|",
//                                               options: [],
//                                               metrics: ["thickness": thickness],
//                                               views: ["bottom": bottom]))
//            addConstraints(
//                NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[bottom]-(0)-|",
//                                               options: [],
//                                               metrics: nil,
//                                               views: ["bottom": bottom]))
//            borders.append(bottom)
//        }
//        
//        return borders
//    }

}
