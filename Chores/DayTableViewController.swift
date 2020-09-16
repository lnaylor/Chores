//
//  DayTableViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit
import os.log

class DayTableViewController: UITableViewController {
    
    //MARK: Properties
    
    @IBOutlet weak var homeButton: UIBarButtonItem!
    
    @IBOutlet weak var rightArrowButton: UIBarButtonItem!
    @IBOutlet weak var leftArrowButton: UIBarButtonItem!
    @IBOutlet weak var rightSpacer: UIBarButtonItem!
    @IBOutlet weak var leftSpacer: UIBarButtonItem!
    
    
    var chores = [Chore]()
    var currentChores = [Chore]()
    
    var titleButton = UIButton(type: .custom)
    
    var todayView = false
    var unscheduledView = false
    var allView = false
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter
    }()
    var displayDate = getCorrectDate(date: Date())
    

    override func viewDidLoad() {
        super.viewDidLoad()
       
        displayDate = getCorrectDate(date: Date())
        
        setLeftArrowUsability()
       
        homeButton.action = #selector(backAction)
        homeButton.target = self
        
        leftArrowButton.action = #selector(leftArrowAction)
        leftArrowButton.target = self
       
        rightArrowButton.action = #selector(rightArrowAction)
        rightArrowButton.target = self
        
        if (!todayView) {
                   leftArrowButton.isEnabled = false
                   leftArrowButton.tintColor = UIColor.clear
                   
                   rightArrowButton.isEnabled = false
                   rightArrowButton.tintColor = UIColor.clear
               }
               else {
                   setLeftArrowUsability()
                   leftArrowButton.tintColor = nil
                   
                   rightArrowButton.isEnabled = true
                   rightArrowButton.tintColor = nil
               }
       
        if(todayView) {
            self.title=dateFormatter.string(for: displayDate)
            titleButton.frame = CGRect(x: 0, y:0, width: 100, height: 40)
            titleButton.backgroundColor = .clear
            titleButton.setTitleColor(.black, for: .normal)
            titleButton.setTitle(dateFormatter.string(for: displayDate), for: .normal)
            titleButton.addTarget(self, action: #selector(clickOnTitleButton), for: .touchUpInside)
            navigationItem.titleView = titleButton
          
        }
        else if (unscheduledView) {
            self.title = "To Do"
            titleButton.frame = CGRect(x: 0, y:0, width: 100, height: 40)
            titleButton.backgroundColor = .clear
            titleButton.setTitleColor(.black, for: .normal)
            titleButton.setTitle("To Do", for: .normal)
            titleButton.addTarget(self, action: #selector(clickOnTitleButton), for: .touchUpInside)
            navigationItem.titleView = titleButton
    
            
        }
        else if (allView) {
            self.title = "All Chores"
           
        }
        
        
       updateChores()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)
        }

    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chores.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ChoreTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ChoreTableViewCell else {
            fatalError("The dequeued cell is not an instance of ChoreTableViewCell.")
        }
        
        let chore = chores[indexPath.row]
        
        cell.nameLabel.text = chore.name
        cell.isHidden = shouldHideCell(chore: chore)
        cell.chore = chore
        cell.delegate = self
        
        if chore.repeatType == RepeatType.none {
            cell.skipButton.isHidden = true
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            chores.remove(at: indexPath.row)
            saveChores()
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
        let itemToMove = chores[fromIndexPath.row]
        chores.remove(at: fromIndexPath.row)
        chores.insert(itemToMove, at: to.row)
    }
    

    
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let chore = chores[indexPath.row]
        
        let rowHeight:CGFloat = shouldHideCell(chore: chore) ? 0.0 : 55.0
       
        return rowHeight
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new chore", log: OSLog.default, type: .debug)
           
            if let destinationNavigationController = segue.destination as? UINavigationController {
                for index in (0 ... (destinationNavigationController.viewControllers.count) - 1).reversed(){
                    if let createChoreController = destinationNavigationController.viewControllers[index] as? CreateChoreViewController {
                    createChoreController.displayDate = getCorrectDate(date: displayDate)
                    }
                }
            }
            
        case "ShowDetail":
            guard let choreDetailViewController = segue.destination as? CreateChoreViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            guard let selectedChoreCell = sender as? ChoreTableViewCell else {
                fatalError("Unexpected sender: \(sender)")
            }
            guard let indexPath = tableView.indexPath(for: selectedChoreCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            let selectedChore = chores[indexPath.row]
            choreDetailViewController.chore = selectedChore
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //MARK: Loading and Saving
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func saveChores() {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: chores, requiringSecureCoding: false)
            try data.write(to:Chore.ArchiveURL)
        } catch {
             os_log("Failed to save chores", log: OSLog.default, type: .error)
        }
    }
    
    private func loadChores() -> [Chore]? {
        do {
            let rawData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("chores"))
            return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawData) as! [Chore]?
        } catch {
            os_log("Failed to load chores", log: OSLog.default, type: .error)
            return nil
        }
    }
    
    func updateChores() {
        if let savedChores = loadChores() {
            chores = savedChores
            for chore in chores {
                if (chore.date != nil) {
                    if (Calendar.current.compare(getCorrectDate(date: chore.date!), to: getCorrectDate(date: Date()), toGranularity: Calendar.Component.day) == ComparisonResult.orderedAscending) {
                                  
                        chore.date = getCorrectDate(date: Date())
                    }
                }
            }
           tableView.reloadData()
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToChoreList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? CreateChoreViewController, let chore = sourceViewController.chore {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                chores[selectedIndexPath.row] = chore
                tableView.reloadRows(at: [selectedIndexPath], with: .none)
            }
            else {
                let newIndexPath = IndexPath(row: chores.count, section: 0)
                chores.append(chore)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
            }
            saveChores()
        }
    }
    
   //MARK: Private functions
   
   private func setLeftArrowUsability() -> Void {
       if Calendar.current.isDate(getCorrectDate(date: displayDate), inSameDayAs: getCorrectDate(date: Date())) {
           leftArrowButton.isEnabled = false
       }
       else {
           leftArrowButton.isEnabled = true
       }
   }
   
   private func shouldHideCell(chore: Chore) -> Bool {
       var shouldHide = false
       if (todayView) {
           shouldHide = !isChoreOnDate(chore: chore, date: displayDate)
       }
       else if (unscheduledView) {
           if (chore.date != nil) {
               shouldHide = true
           }
           else if (self.title == "To Do" && !chore.toDo) {
               shouldHide = true
           }
           else if (self.title == "Saved" && chore.toDo) {
               shouldHide = true
           }
       }
       return shouldHide
   }
    
    private func addRepeatAmountToChore(chore: Chore) -> Date? {
        var date: Date
        if (chore.repeatFromDate != nil) {
            date = chore.repeatFromDate!
        }
        else if (chore.date != nil){
            date = chore.date!
        }
        else {
            return nil
        }
        if (chore.repeatType == RepeatType.none) {
            return nil
        }
        let d = addRepeatAmountToDate(date: date, repeatType: chore.repeatType, customRepeatNumber: chore.customRepeatNumber, customRepeatUnit: chore.customRepeatUnit)
        
        if (chore.endRepeatDate != nil && d != nil) {
            if (Calendar.current.compare(d!, to: chore.endRepeatDate!, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending) {
                return nil
            }
        }
        return d
    }

    private func addRepeatAmountToDate(date: Date, repeatType: RepeatType, customRepeatNumber: Int?, customRepeatUnit: CustomRepeatUnit?) -> Date? {
        var d: Date?
        switch repeatType {
        case RepeatType.none:
            return nil
        case RepeatType.daily:
            d = Calendar.current.date(byAdding: .day, value: 1, to: date)
        case RepeatType.weekly:
            d = Calendar.current.date(byAdding: .day, value: 7, to: date)
        case RepeatType.biweekly:
            d = Calendar.current.date(byAdding: .day, value: 14, to: date)
        case RepeatType.monthly:
            d = Calendar.current.date(byAdding: .month, value: 1, to: date)
        case RepeatType.bimonthly:
            d = Calendar.current.date(byAdding: .month, value: 2, to: date)
        case RepeatType.yearly:
            d = Calendar.current.date(byAdding: .year, value: 1, to: date)
        case RepeatType.custom:
            if (customRepeatNumber != nil && customRepeatNumber ?? -1 > 0 && customRepeatUnit != nil) {
                let numUnits = customRepeatNumber
                switch customRepeatUnit! {
                case CustomRepeatUnit.days:
                    d = Calendar.current.date(byAdding: .day, value: numUnits!, to: date) ?? date
                case CustomRepeatUnit.weeks:
                    d = Calendar.current.date(byAdding: .day, value: numUnits! * 7, to: date) ?? date
                case CustomRepeatUnit.months:
                    d = Calendar.current.date(byAdding: .month, value: numUnits!, to: date) ?? date
                case CustomRepeatUnit.years:
                    d = Calendar.current.date(byAdding: .year, value: numUnits!, to: date) ?? date
                }
            }
        }
        return d
    }
    
    private func isChoreOnDate(chore: Chore, date: Date) -> Bool{
        if (chore.date == nil) {
            return false
        }
        if (Calendar.current.compare(chore.date!, to: date, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending) {
            return false
        }
        var d = chore.date
        while (d != nil) {
            if (isDateGreaterThan(date1: d!, date2: date)) {
                return false
            }
            if Calendar.current.isDate(d!, inSameDayAs: date) {
                return true
            }
            d = addRepeatAmountToDate(date: d!, repeatType: chore.repeatType, customRepeatNumber: chore.customRepeatNumber, customRepeatUnit: chore.customRepeatUnit)
            if (chore.endRepeatDate != nil) {
                if (isDateGreaterThan(date1: d!, date2: chore.endRepeatDate!)) {
                    return false
                }
            }
        }

        return false
    }
    
    
    private func updateChoreDate(chore: Chore) {
        chore.date = addRepeatAmountToChore(chore: chore)
        saveChores()
    }
    
    
    //MARK: Objc functions
       
    @objc func backAction() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
       
    @objc func rightArrowAction() -> Void {
        displayDate = Calendar.current.date(byAdding: .day, value: 1, to: displayDate) ?? displayDate
        self.title=dateFormatter.string(for: displayDate)
        titleButton.setTitle(dateFormatter.string(for: displayDate), for: .normal)
        setLeftArrowUsability()
        tableView.reloadData()
    }
          
    @objc func leftArrowAction() -> Void {
        displayDate = Calendar.current.date(byAdding: .day, value: -1, to: displayDate) ?? displayDate
        self.title=dateFormatter.string(for: displayDate)
        titleButton.setTitle(dateFormatter.string(for: displayDate), for: .normal)
        setLeftArrowUsability()
        tableView.reloadData()
    }
       
    @objc func clickOnTitleButton() {
        if (todayView) {
            let calendarView = self.storyboard!.instantiateViewController(withIdentifier: "calendarView") as! CalendarViewController
            calendarView.settings = CalendarSettings()
            calendarView.tableDate=displayDate
            calendarView.setTableDate=true
            calendarView.setScheduleButton=false
            calendarView.setEndRepeatButton=false
            self.navigationController?.pushViewController(calendarView, animated:   true)
        }
        else if (unscheduledView) {
            self.title = (self.title == "To Do") ? "Saved" : "To Do"
            titleButton.setTitle(self.title, for: .normal)
            tableView.reloadData()
        }
              
    }
       

}

extension DayTableViewController : ChoreTableViewCellDelegate {
    func choreDoneButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore) {
        updateChoreDate(chore: chore)
        if (chore.date == nil && chore.deleteOnCompletion) {
            print(tableView.indexPath(for: choreTableViewCell))
            if let selectedIndexPath = tableView.indexPath(for: choreTableViewCell) {
                print("deleting at")
                print(selectedIndexPath.row)
                chores.remove(at: selectedIndexPath.row)
            }
           
        }
        else {
            chore.completedDates.append(getCorrectDate(date: Date()))
        }
        
        tableView.reloadData()
    }
    
    func choreSkipButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore) {
        updateChoreDate(chore: chore)
        tableView.reloadData()
    }
    
    func chorePushButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore) {
        let alert = UIAlertController(title: "Push back how many days?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { action in

            if let days = alert.textFields?.first?.text {
                chore.date = Calendar.current.date(byAdding: .day, value: Int(days) ?? 1, to: chore.date!)
                if (chore.repeatFromDate != nil) {
                    var d = chore.repeatFromDate
                    while (isDateGreaterThan(date1: chore.date!, date2: chore.repeatFromDate!)) {
                        chore.repeatFromDate = d
                        d = self.addRepeatAmountToDate(date: d!, repeatType: chore.repeatType, customRepeatNumber: chore.customRepeatNumber, customRepeatUnit: chore.customRepeatUnit)
                    }
                }
               
                self.saveChores()
                self.tableView.reloadData()
            }
        })

        alert.addTextField(configurationHandler: { textField in
            textField.text = "1"
            textField.keyboardType = .numberPad
            textField.textAlignment =  .center
            
            NotificationCenter.default.addObserver(forName: UITextField.textDidChangeNotification, object: textField, queue: OperationQueue.main, using:
                {_ in
                   
                    let textCount = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines).count ?? 0
                    let textIsNotEmpty = textCount > 0
                    
                    okAction.isEnabled = textIsNotEmpty
                
            })
        })

        alert.addAction(okAction)

        self.present(alert, animated: true)
    }
    
    func choreHistoryButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore) {
        let calendarView = self.storyboard!.instantiateViewController(withIdentifier: "calendarView") as! CalendarViewController
        
        let settings = CalendarSettings()
        settings.selectionType = .none
        calendarView.settings = settings
        
        calendarView.setTableDate=false
        calendarView.setScheduleButton=false
        calendarView.setEndRepeatButton=false
        calendarView.showHistory=true
        calendarView.completedDates = chore.completedDates
        self.navigationController?.pushViewController(calendarView, animated:   true)
    }
    
}

