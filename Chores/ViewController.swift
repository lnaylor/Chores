//
//  ViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/28/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit

class CalendarSettings {
    var gridType: CalendarType = .threeOnFour
    var scrollDirection: ScrollDirection = .vertical
    var startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
    var endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
    var isPagingEnabled: Bool = false
    var showDaysOut: Bool = true
    var selectionType: SelectionType = .one
    var date: Date = getCorrectDate(date: Date())
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
}()

func getDateString(date: Date) -> String {
    return dateFormatter.string(for: date) ?? ""
}

func getCorrectDate(date: Date) -> Date {
       let formatter = DateFormatter()
       formatter.dateFormat = "MM/dd/yyyy"
     
       return formatter.date(from: formatter.string(from: date)) ?? date
}

func isDateLaterThan(date1: Date?, date2: Date?) -> Bool {
    if (date1 == nil || date2 == nil) {
        return false
    }
    return Calendar.current.compare(date1!, to: date2!, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending
}

func isDateEarlierThan(date1: Date?, date2: Date?) -> Bool {
    if (date1 == nil || date2 == nil) {
        return false
    }
    return Calendar.current.compare(date1!, to: date2!, toGranularity: Calendar.Component.day) == ComparisonResult.orderedAscending
}

func areDatesEqual(date1: Date?, date2: Date?) -> Bool {
    if (date1 == nil || date2 == nil) {
        return false
    }
    return Calendar.current.isDate(date1!, inSameDayAs: date2!)
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

