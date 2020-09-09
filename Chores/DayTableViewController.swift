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
    
    var chores = [Chore]()
    var currentChores = [Chore]()
    
    var titleButton = UIButton(type: .custom)
    
    let dateFormatter: DateFormatter = {
           let formatter = DateFormatter()
           formatter.dateFormat = "MM/dd/yyyy"
           return formatter
       }()
    var date = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        date = getCorrectDate(date: Date())
        self.title=dateFormatter.string(for: date)
        navigationItem.leftBarButtonItem = editButtonItem
    
        titleButton.frame = CGRect(x: 0, y:0, width: 100, height: 40)
        titleButton.backgroundColor = .clear
        titleButton.setTitleColor(.black, for: .normal)
        titleButton.setTitle(dateFormatter.string(for: date), for: .normal)
        titleButton.addTarget(self, action: #selector(clickOnTitleButton), for: .touchUpInside)
        navigationItem.titleView = titleButton
        
       reloadChores()
        
       
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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
        cell.isHidden = !isChoreOnDate(chore: chore, date: date)
        cell.chore = chore
        cell.delegate = self
        

        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            chores.remove(at: indexPath.row)
            saveChores()
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new chore", log: OSLog.default, type: .debug)
            let testController = segue.destination as? UINavigationController
            if testController != nil {
               for index in (0 ... (testController?.viewControllers.count)! - 1).reversed(){
                if let previousController = testController?.viewControllers[index] as? CreateChoreViewController {
                    previousController.displayDate = getCorrectDate(date: date)
                }
                }
            }
            if let choreDetailViewController = segue.destination as? CreateChoreViewController {
                choreDetailViewController.displayDate = getCorrectDate(date: date)
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
    
    func reloadChores() {
        if let savedChores = loadChores() {
            
           chores = savedChores
            for chore in chores {
                if (chore.date != nil) {
                    if (Calendar.current.compare(getCorrectDate(date: chore.date!), to: getCorrectDate(date: Date()), toGranularity: Calendar.Component.day) == ComparisonResult.orderedAscending) {
                                  
                                  chore.date = getCorrectDate(date: Date())
                                  print("updated old date")
                              }
                }
          
                print(chore.name)
                print(chore.date ?? "NO Date")
                print()
            }
           tableView.reloadData()
        }
        else {
             loadPresetChores()
        }
    }
    
    private func loadPresetChores() {
        let chore1 = Chore(name: "Vaccuum2", type: ChoreType.scheduled, date: Calendar.current.date(byAdding: .day, value: 1, to: Date())!, repeatType: RepeatType.daily, endRepeatDate: nil)
        
        chores += [chore1]
    }
    
    private func saveChores() {
       // let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(chores, toFile: Chore.ArchiveURL.path)
        //let fullPath = getDocumentsDirectory().appendingPathComponent("chores")
        do {
            for chore in chores {
            print("SAVING CHORES")
            print(chore.name)
            print(chore.date)
            print()
            }
            let data = try NSKeyedArchiver.archivedData(withRootObject: chores, requiringSecureCoding: false)
            try data.write(to:Chore.ArchiveURL)
        } catch {
            print("error saving chore")
        }
        
        /*
        if isSuccessfulSave {
            os_log("Chores successfully saved.", log: OSLog.default, type: .debug)
        }
        else {
            os_log("Failed to save chores.", log: OSLog.default, type: .error)
        }*/
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func loadChores() -> [Chore]? {
       // return NSKeyedUnarchiver.unarchiveObject(withFile: Chore.ArchiveURL.path) as? [Chore]
        do {
             let rawData = try Data(contentsOf: getDocumentsDirectory().appendingPathComponent("chores"))
            print("LOADING CHORES")
             return try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(rawData) as! [Chore]?
        } catch {
            print ("error")
            return nil
        }
    }
    
    //MARK: Actions
    
    @IBAction func unwindToChoreList(sender: UIStoryboardSegue) {
        
        if let sourceViewController = sender.source as? CreateChoreViewController, let chore = sourceViewController.chore {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                chores[selectedIndexPath.row] = chore
                tableView.reloadData()
                //Update existing chore
              //  tableView.reloadRows(at: [selectedIndexPath], with: .none)
              /*
                if Calendar.current.isDate(chore.date, inSameDayAs: date) {
                    
                    tableView.reloadRows(at: [selectedIndexPath], with: .none)
                }
                else {
                    tableView.reloadData()
                }
 */
            }
            else {
                let newIndexPath = IndexPath(row: chores.count, section: 0)
                chores.append(chore)
                tableView.insertRows(at: [newIndexPath], with: .automatic)
                tableView.reloadData()
            }
            saveChores()
        }
    }
    
    @objc func clickOnTitleButton() {
        let calendarView = self.storyboard!.instantiateViewController(withIdentifier: "calendarView") as! CalendarViewController
        calendarView.settings = CalendarSettings()
        calendarView.tableDate=date
        calendarView.setTableDate=true
        calendarView.setScheduleButton=false
        calendarView.setEndRepeatButton=false
        self.navigationController?.pushViewController(calendarView, animated:   true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight:CGFloat = 55.0

        let chore = chores[indexPath.row]
        if !isChoreOnDate(chore: chore, date: date){
            rowHeight = 0.0
        }
        return rowHeight
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let selectedIndexPath = tableView.indexPathForSelectedRow {
            // chores[selectedIndexPath.row] = chore
            tableView.reloadRows(at: [selectedIndexPath], with: .automatic)

        }

    }
    
    private func isChoreOnDate(chore: Chore, date: Date) -> Bool{
        if (chore.date == nil) {
            return false
        }
        if !Calendar.current.isDate(chore.date!, inSameDayAs: date) {
            let repeatType = chore.repeatType
            if repeatType != RepeatType.none {
                var d = chore.date!
                while (Calendar.current.compare(d, to: date, toGranularity: Calendar.Component.day) == ComparisonResult.orderedAscending || Calendar.current.isDate(d, inSameDayAs: date)) {
                    
                    if let endD = chore.endRepeatDate {
                        if Calendar.current.compare(d, to: endD, toGranularity: Calendar.Component.day) == ComparisonResult.orderedDescending {
                            return false
                        }
                    }
            
                    if Calendar.current.isDate(d, inSameDayAs: date) {
                        return true
                    }
                    
                    switch repeatType {
                    case RepeatType.daily:
                        d = Calendar.current.date(byAdding: .day, value: 1, to: d) ?? date
                    case RepeatType.weekly:
                        d = Calendar.current.date(byAdding: .day, value: 7, to: d) ?? date
                    case RepeatType.biweekly:
                        d = Calendar.current.date(byAdding: .day, value: 14, to: d) ?? date
                    case RepeatType.monthly:
                        d = Calendar.current.date(byAdding: .month, value: 1, to: d) ?? date
                    case RepeatType.bimonthly:
                        d = Calendar.current.date(byAdding: .month, value: 2, to: d) ?? date
                    case RepeatType.yearly:
                        d = Calendar.current.date(byAdding: .year, value: 1, to: d) ?? date
                    default:
                        d = date
                    }
                    
                }
                
            }
            return false
        }
        return true
    }

}

extension DayTableViewController : ChoreTableViewCellDelegate {
    func choreDoneButtonCell(_ choreTableViewCell: ChoreTableViewCell, chore: Chore) {
        if (chore.date != nil) {
            if (chore.repeatType != RepeatType.none) {
                var d : Date?
                switch chore.repeatType {
                case RepeatType.daily:
                    d = Calendar.current.date(byAdding: .day, value: 1, to: chore.date!)
                case RepeatType.weekly:
                    d = Calendar.current.date(byAdding: .day, value: 7, to: chore.date!)
                case RepeatType.biweekly:
                    d = Calendar.current.date(byAdding: .day, value: 14, to: chore.date!)
                case RepeatType.monthly:
                    d = Calendar.current.date(byAdding: .month, value: 1, to: chore.date!)
                case RepeatType.bimonthly:
                    d = Calendar.current.date(byAdding: .month, value: 2, to: chore.date!)
                case RepeatType.yearly:
                    d = Calendar.current.date(byAdding: .year, value: 1, to: chore.date!)
                default:
                    d = nil
                }
                chore.date = d
            }
            else {
                chore.date = nil
            }
            tableView.reloadData()
        }
    }
}

