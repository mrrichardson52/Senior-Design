//
//  Enums.swift
//  HexoskinBreathing
//
//  Created by Matthew Richardson on 3/23/17.
//  Copyright © 2017 Matthew Richardson. All rights reserved.
//

import Foundation


enum ExerciseState {
    case notStarted;
    case starting;
    case started;
    case ended;
}

enum ActionCheckingState {
    case none;
    case checkingFirstAction;
    case currentActionInhale;
    case currentActionExhale;
    case lastActionPause;
    case deviatingAfterInhale;
    case deviatingAfterExhale;
    case deviatingAfterPause;
}
