//
//  ViewController.swift
//  YACalendar
//
//  Created by Vodolazkyi Anton on 1/31/20.
//  Copyright © 2020 Yalantis. All rights reserved.
//

import UIKit

enum ViewType {
    case month, year
}

func getCorrectDate(date: Date) -> Date {
       let formatter = DateFormatter()
       formatter.dateFormat = "MM/dd/yyyy"
     
       return formatter.date(from: formatter.string(from: date)) ?? date
}

class CalendarViewController: UIViewController {
    
    
    @IBOutlet var calendarView: CalendarView!
   // @IBOutlet private var yearBarButton: UIBarButtonItem!
    //@IBOutlet private var yearLabel: UILabel!
    //@IBOutlet private var calendarTrailingConstraint: NSLayoutConstraint!

    private var viewType: ViewType = .month
    var settings: CalendarSettings!
    var displayDate: Date!
    var setScheduleButton = false
    var setEndRepeatButton = false
    var setTableDate = false
    var tableDate: Date!
    var endRepeatDate: Date!
    private let calendar = Calendar.current
    
    var showHistory = false
    var completedDates: [Date]!

    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarView.calendarDelegate = self
        
        applySettings()
      
        if (setScheduleButton) {
             calendarView.selectDay(with: getCorrectDate(date: displayDate))
        }
        else if (setEndRepeatButton) {
            if endRepeatDate != nil {
                calendarView.selectDay(with: endRepeatDate)
            }
           
        }
        else if (setTableDate) {
            calendarView.selectDay(with: tableDate)
        }
        else if (showHistory) {
            calendarView.selectDays(with: completedDates)
        }
       
       // calendarView.selectDays(with: [Calendar.current.date(byAdding: .day, value: 1, to: Date())!])
        // print(calendarView.currentDate)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CreateChoreViewController {
            controller.settings = settings
            controller.applySettings = { [weak self] in
                self?.applySettings()
            }
        }
    }
    
    @IBAction func changeViewType(_ sender: UIBarButtonItem) {
        viewType = viewType == .month ? .year : .month
        applySettings()
    }
    
    private func updateCalendarSize() {
    //    calendarTrailingConstraint.constant = calendarView.isPortrait == false && viewType == .month ? view.frame.width / 2 : 0
   //     view.layoutIfNeeded()
    }
    
    private func applySettings() {
        calendarView.isPagingEnabled = settings.isPagingEnabled
        calendarView.grid.scrollDirection = settings.scrollDirection
        calendarView.selectionType = settings.selectionType
        calendarView.config.month.showDaysOut = settings.showDaysOut
        
       

       /* if #available(iOS 13.0, *) {
            yearBarButton.image = viewType == .month ? UIImage(systemName: "chevron.left") : nil
        }*/
        
        switch viewType {
        case .month:
            calendarView.grid.calendarType = .oneOnOne
            
            let formetter = DateFormatter()
            formetter.dateFormat = "MMMM"
            calendarView.config.monthTitle.formatter = formetter
            calendarView.config.monthTitle.showSeparator = true
            
        case .year:
            calendarView.grid.calendarType = settings.gridType
            
            let formetter = DateFormatter()
            formetter.dateFormat = settings.gridType == .threeOnFour ? "MMM" : "MMMM"
            calendarView.config.monthTitle.formatter = formetter
            calendarView.config.monthTitle.showSeparator = false
        }
        updateCalendarSize()
       
        calendarView.data = CalendarData(calendar: calendar, startDate: settings.startDate, endDate: settings.endDate)
    }
}

extension CalendarView : CalendarViewDelegate {
 
}
extension CalendarViewController: CalendarViewDelegate {
    
    
    
    func didSelectDate(_ date: Date) {
        if viewType == .year {
            viewType = .month
            calendarView.currentDate = date
            applySettings()
            
        }
        for index in (0 ... (navigationController?.viewControllers.count)! - 1).reversed(){
            if let previousController = navigationController?.viewControllers[index] as? CreateChoreViewController {
                if (setScheduleButton) {
                    previousController.displayDateSetFromCalendar=true
                    previousController.displayDate = getCorrectDate(date: date)
                }
                else if (setEndRepeatButton) {
                    previousController.endRepeatDateSetFromCalendar=true
                    previousController.endRepeatDate = getCorrectDate(date: date)
                    previousController.endRepeatSwitch.setOn(true, animated: true)
                    previousController.endRepeatSwitch.isEnabled=true
                }

            }
            else if let previousController = navigationController?.viewControllers[index] as? DayTableViewController {
                if (setTableDate) {
                    previousController.date = getCorrectDate(date: date)
                    previousController.titleButton.setTitle(dateFormatter.string(for: date), for: .normal)
                    previousController.tableView.reloadData()
                   
                }
            }
        }
        
        navigationController?.popViewController(animated: true)
    }
    
    func didSelectRange(_ startDate: Date, endDate: Date) {
        print("did select range \(startDate) - \(endDate)")
        
        calendarView.selectDays(with: completedDates)
    }
    
    func didUpdateDisplayedDate(_ date: Date) {
        //yearLabel.text = yearFormatter.string(from: date)
        //yearLabel.isHidden = viewType == .year
    }
    
    func didChangeOrientation(_ isPortrait: Bool) {
        updateCalendarSize()
    }
}
 
