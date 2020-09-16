//
//  ViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/28/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit

func getCorrectDate(date: Date) -> Date {
       let formatter = DateFormatter()
       formatter.dateFormat = "MM/dd/yyyy"
     
       return formatter.date(from: formatter.string(from: date)) ?? date
}

func isDateGreaterThan(date1: Date, date2: Date) -> Bool {
    return Calendar.current.compare(getCorrectDate(date: date1), to: getCorrectDate(date: date2), toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending
}

func isDateLessThan(date1: Date, date2: Date) -> Bool {
    return Calendar.current.compare(getCorrectDate(date: date1), to: getCorrectDate(date: date2), toGranularity: Calendar.Component.day) == ComparisonResult.orderedAscending
}

func areDatesEqual(date1: Date, date2: Date) -> Bool {
    return Calendar.current.isDate(getCorrectDate(date: date1), inSameDayAs: getCorrectDate(date: date2))
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
         
        let destinationController = segue.destination as? UINavigationController
        switch(segue.identifier) {
        case "todayButton":
           
            if destinationController != nil {
                let tableController = (destinationController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = true
                tableController.unscheduledView = false
                tableController.allView = false
            }
        case "unscheduledButton":
           if destinationController != nil {
                let tableController = (destinationController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = false
                tableController.unscheduledView = true
                tableController.allView = false
            }
        case "allButton":
            if destinationController != nil {
                let tableController = (destinationController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = false
                tableController.unscheduledView = false
                tableController.allView = true
            }
        default:
           break
        }
    }

}

