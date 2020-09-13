//
//  ViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/28/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
         let testController = segue.destination as? UINavigationController
        switch(segue.identifier ?? "") {
        case "todayButton":
           
            if testController != nil {
                let tableController = (testController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = true
                tableController.unscheduledView = false
                tableController.allView = false
            }
        case "unscheduledButton":
           if testController != nil {
                let tableController = (testController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = false
                tableController.unscheduledView = true
                tableController.allView = false
            }
        case "allButton":
            if testController != nil {
                let tableController = (testController?.viewControllers[0])! as! DayTableViewController as DayTableViewController
                tableController.todayView = false
                tableController.unscheduledView = false
                tableController.allView = true
            }
        default:
           break
        }
    }

}

