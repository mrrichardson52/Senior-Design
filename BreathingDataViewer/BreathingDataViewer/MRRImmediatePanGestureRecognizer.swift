//
//  MRRImmediatePanGestureRecognizer.swift
//  Breathing Data Viewer
//
//  Created by Matthew Richardson on 11/5/16.
//  Copyright © 2016 Matthew Richardson. All rights reserved.
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
