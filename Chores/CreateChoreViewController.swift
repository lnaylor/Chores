//
//  CreateChoreViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit
import os.log

class CalendarSettings {
    var gridType: CalendarType = .threeOnFour
    var scrollDirection: ScrollDirection = .vertical
    var startDate = Calendar.current.date(byAdding: .year, value: -3, to: Date())!
    var endDate = Calendar.current.date(byAdding: .year, value: 3, to: Date())!
    var isPagingEnabled: Bool = false
    var showDaysOut: Bool = true
    var selectionType: SelectionType = .one
    var date: Date = Date()
}

class CreateChoreViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var calendarButton: UIButton!
    @IBOutlet weak var repeatPicker: UIPickerView!
    @IBOutlet weak var endRepeatButton: UIButton!
    @IBOutlet weak var endRepeatSwitch: UISwitch!
    @IBOutlet weak var pushBackRepeatSwitch: UISwitch!
    @IBOutlet weak var notScheduledSwitch: UISwitch!
    @IBOutlet weak var deleteOnCompletionSwitch: UISwitch!
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var endRepeatLabel: UILabel!
    @IBOutlet weak var pushBackLabel: UILabel!
    
    var chore: Chore?
    var displayDate: Date?
    var displayDateSetFromCalendar = false
    
    var endRepeatDate: Date?
    var endRepeatDateSetFromCalendar = false
    
    var settings = CalendarSettings()
    var applySettings: (() -> Void)?
    
    var repeatPickerData: [String] = [String]()
    var repeatPickerSelection = 0
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter
    }()

    
    override func viewWillAppear(_ animated: Bool) {
        if (chore != nil) && !displayDateSetFromCalendar {
            calendarButton.setTitle(dateFormatter.string(for: chore?.date) ?? "None", for: .normal)
        }
        else if (displayDate != nil) {
             calendarButton.setTitle(dateFormatter.string(for: displayDate), for: .normal)
        }
        else {
            calendarButton.setTitle("None", for: .normal)
        }
        
        if (chore != nil) && !endRepeatDateSetFromCalendar {
            endRepeatButton.setTitle(dateFormatter.string(for: chore?.endRepeatDate) ?? "None", for: .normal)
            endRepeatDate = getCorrectDate(date: chore?.endRepeatDate ?? Date())
        }
        else {
             endRepeatButton.setTitle(dateFormatter.string(for: endRepeatDate) ?? "None", for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayDate = getCorrectDate(date: Date())
        
        self.repeatPicker.delegate = self
        self.repeatPicker.dataSource = self
        repeatPickerData = RepeatType.allCases.map {$0.rawValue}
        nameTextField.delegate = self
        
        endRepeatSwitch.addTarget(self, action: #selector(endRepeatStateChanged), for:   .valueChanged)
        endRepeatSwitch.setOn(false, animated: true)
        endRepeatSwitch.isEnabled=false
        
        pushBackRepeatSwitch.setOn(false, animated: true)
        pushBackRepeatSwitch.isEnabled=false
        
        notScheduledSwitch.addTarget(self, action: #selector(notScheduledStateChanged), for: .valueChanged)
        notScheduledSwitch.setOn(false, animated: true)
        
        deleteOnCompletionSwitch.setOn(false, animated: true)
        
        deleteButton.addTarget(self, action: #selector(deleteButtonPushed), for: .touchUpInside)
        
        
        if let chore = chore {
            navigationItem.title = chore.name
            nameTextField.text = chore.name
            displayDate=chore.date ?? getCorrectDate(date: Date())
           
            repeatPicker.selectRow(repeatPickerData.firstIndex(of: chore.repeatType.rawValue) ?? 0, inComponent: 0, animated: true)
            repeatPickerSelection = repeatPickerData.firstIndex(of: chore.repeatType.rawValue) ?? 0
            
            if chore.endRepeatDate != nil {
                endRepeatSwitch.setOn(true, animated: true)
                endRepeatSwitch.isEnabled=true
            }
            
            if chore.date == nil {
                notScheduledSwitch.setOn(true, animated: true)
                hideScheduleItems()
            }
        }
       
        
        updateSaveButtonState()
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled=false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonState()
        navigationItem.title = textField.text
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }

    
    // MARK: - Navigation
    
    
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        let isPresentingInAddChoreMode = presentingViewController is UINavigationController
        if isPresentingInAddChoreMode {
            dismiss(animated: true, completion: nil)
        }
        else if let owningNavigationController = navigationController{
            owningNavigationController.popViewController(animated: true)
        }
        else {
            fatalError("The CreateChoreViewController is not inside a navigation controller.")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
         
        let dateButton = sender as? UIButton
        if let controller = segue.destination as? CalendarViewController {
            controller.settings = settings
            controller.displayDate=getCorrectDate(date: displayDate ?? Date())
            controller.endRepeatDate=endRepeatDate
            if (dateButton === calendarButton) {
                controller.setScheduleButton=true
                controller.setEndRepeatButton=false
                controller.setTableDate=false
            }
            else if (dateButton === endRepeatButton) {
                controller.setEndRepeatButton=true
                controller.setScheduleButton=false
                controller.setTableDate=false
            }
        }
        
       let button = sender as? UIBarButtonItem
        
        if (button === saveButton) {
            let name = nameTextField.text ?? ""
            let repeatFromDate = pushBackRepeatSwitch.isOn ? nil : displayDate
            let date = notScheduledSwitch.isOn ? nil : displayDate
            chore = Chore(name: name, type: ChoreType.oneTime, date: date, repeatType: RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) ?? RepeatType.none, endRepeatDate: endRepeatDate, repeatFromDate: repeatFromDate, deleteOnCompletion: deleteOnCompletionSwitch.isOn)
        }
        
        if (button === deleteButton) {
            
        }
        
       
        
    }
    
    //MARK: - PickerView methods
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return repeatPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return repeatPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        repeatPickerSelection = row
        if (RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) != RepeatType.none) {
            pushBackRepeatSwitch.isEnabled=true
        }
        else {
            pushBackRepeatSwitch.setOn(false, animated: true)
            pushBackRepeatSwitch.isEnabled=false
        }
    }
    
    @objc func deleteButtonPushed() {
        for index in (0 ... (navigationController?.viewControllers.count)! - 1).reversed(){
                   if let previousController = navigationController?.viewControllers[index] as? DayTableViewController {
                    
                    if let selectedIndexPath = previousController.tableView.indexPathForSelectedRow {
                        print("deleting at button")
                        print(selectedIndexPath.row)
                        previousController.chores.remove(at: selectedIndexPath.row)
                        previousController.tableView.reloadData()
                    }
            }
        }
        
        navigationController?.popViewController(animated: true)
        
    }
    
    @objc func endRepeatStateChanged(switchState: UISwitch) {
        if !switchState.isOn {
            endRepeatDate = nil
             endRepeatButton.setTitle("None", for: .normal)
            endRepeatSwitch.isEnabled=false
        }
        else {
            endRepeatSwitch.isEnabled=true
        }
    }
    
    private func hideScheduleItems() {
        if notScheduledSwitch.isOn {
            displayDate = nil
            calendarButton.setTitle("None", for: .normal)
            
            repeatPicker.isHidden=true
            endRepeatSwitch.isHidden=true
            endRepeatButton.isHidden=true
            repeatLabel.isHidden=true
            endRepeatLabel.isHidden=true
            pushBackLabel.isHidden=true
            pushBackRepeatSwitch.isHidden=true
        }
        else {
            repeatPicker.isHidden=false
            endRepeatSwitch.isHidden=false
            endRepeatButton.isHidden=false
            repeatLabel.isHidden=false
            endRepeatLabel.isHidden=false
            pushBackLabel.isHidden=false
            pushBackRepeatSwitch.isHidden=false
        }
    }
    @objc func notScheduledStateChanged(switchState: UISwitch) {
       hideScheduleItems()
    }

}
