//
//  RotationTestingViewController.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 11/6/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
//

import UIKit

class RotationTestingViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.imageView.image = UIImage(named: "ccw_wheel.png");
        
        UIView.animate(withDuration: 2.0, animations: {
            self.imageView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(M_PI/2)) / 180.0)
        }, completion: { (myBool) in
            UIView.animate(withDuration: 2.0, animations: {
                self.imageView.image = UIImage(named: "no_arrow_wheel.png");
            }, completion: { (myBool) in
                UIView.animate(withDuration: 2.0, animations: {
                    self.imageView.image = UIImage(named: "cw_wheel.png");
                })
            })
        })
        

    }
    
    

}
