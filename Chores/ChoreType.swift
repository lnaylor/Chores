//
//  ChoreType.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit

enum ChoreType: String {
    case oneTime = "OneTime"
    case scheduled = "Scheduled"
}

enum RepeatType: String, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Biweekly"
    case monthly = "Montly"
    case bimonthly = "BiMonthly"
    case yearly = "Yearly"
}
