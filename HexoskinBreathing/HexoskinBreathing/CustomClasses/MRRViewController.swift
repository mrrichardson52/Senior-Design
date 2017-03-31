//
//  MRRViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/21/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import UIKit

class MRRViewController: UIViewController {
    
//    var disablesLandscape: Bool = false;
    var depthView: UIView!
    var depthViewVerticalConstraint: NSLayoutConstraint! = nil;
    var backgroundImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        /*  
         this custom view controller should:
         1. Modify/Customize Navigation Controller
            Include functions that make adding navigation items simple
         2. Customize background of view controller
 
         */
        
        self.view.backgroundColor = Constants.backgroundColor; 
        self.navigationItem.setHidesBackButton(true, animated: false);

        // add a view that sits right beneath the navigation bar
        var constraints: [NSLayoutConstraint] = [];
        depthView = UIView();
        depthView.backgroundColor = .lightGray;
        depthView.translatesAutoresizingMaskIntoConstraints = false;
        self.view.addSubview(depthView);
        depthViewVerticalConstraint = NSLayoutConstraint(item: depthView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1.0, constant: -1*(self.navigationController?.navigationBar.frame.origin.y)!)
        constraints.append(depthViewVerticalConstraint); // display right below nav bar
        constraints.append(NSLayoutConstraint(item: depthView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 3));
        constraints.append(NSLayoutConstraint(item: depthView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1.0, constant: 0));
        constraints.append(NSLayoutConstraint(item: depthView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0));
        self.view.addConstraints(constraints);
    }
    
    func addBackButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "< Back", style: .plain, target: self, action: #selector(MRRViewController.popViewController));
    }
    
    func popViewController() {
        _ = self.navigationController?.popViewController(animated: true);
    }
    
    func hideNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: true);
        depthView.backgroundColor = .clear;
    }
    
    func showNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true);
        depthView.backgroundColor = .lightGray;
        depthViewVerticalConstraint.constant = (self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.height)!;
    }
    
    func hideBackButton() {
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator);
        
        coordinator.animate(alongsideTransition: {
            _ in
            self.depthViewVerticalConstraint.constant = (self.navigationController?.navigationBar.frame.origin.y)! + (self.navigationController?.navigationBar.frame.height)!;
        }, completion: nil)
    }
    

}
