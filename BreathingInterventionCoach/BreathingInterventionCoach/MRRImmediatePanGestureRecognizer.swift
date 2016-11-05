//
//  MRRImmediatePanGestureRecognizer.swift
//  BreathingInterventionCoach
//
//  Created by Matthew Richardson on 10/17/16.
//  Copyright © 2016 Gurjeet Birdee. All rights reserved.
//

import UIKit


class MRRImmediatePanGestureRecognizer: UIPanGestureRecognizer {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        print("touches began");
        if (self.state == UIGestureRecognizerState.began) {
            return
        }
        super.touchesBegan(touches, with: event)
        self.state = UIGestureRecognizerState.began;
    }
    
    
}
