//
//  CreateChoreViewController.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit
import os.log



class CreateChoreViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var scheduleButton: UIButton!
    @IBOutlet weak var endRepeatButton: UIButton!
    @IBOutlet weak var endRepeatSwitch: UISwitch!
    @IBOutlet weak var pushBackRepeatSwitch: UISwitch!
    @IBOutlet weak var notScheduledSwitch: UISwitch!
    @IBOutlet weak var deleteOnCompletionSwitch: UISwitch!
    @IBOutlet weak var toDoSegment: UISegmentedControl!
    
    var historyPickerView: UIPickerView!
    var repeatPicker: UIPickerView!
    var customRepeatPicker: UIPickerView!
    
    @IBOutlet weak var repeatScheduleButton: UIButton!
    
    @IBOutlet weak var customRepeatScheduleButton: UIButton!
    @IBOutlet weak var saveHistorySettingsButton: UIButton!
    @IBOutlet weak var repeatLabel: UILabel!
    @IBOutlet weak var endRepeatLabel: UILabel!
    @IBOutlet weak var pushBackLabel: UILabel!
    @IBOutlet weak var customRepeatLabel: UILabel!
    
    var chore: Chore?
    var nextScheduledDate: Date?
    var displayDateSetFromCalendar = false
    
    var endRepeatDate: Date?
    var endRepeatDateSetFromCalendar = false
    
    var settings = CalendarSettings()
    var applySettings: (() -> Void)?
    
    var repeatPickerData: [String] = [String]()
    var repeatPickerSelection = 0
    var customRepeatPickerSelection0 = 0
    var customRepeatPickerSelection1 = 0
    
    var historyPickerSelection0 = 5
    var historyPickerSelection1 = 2
    
    var customRepeatPickerData0: [String] = [String]()
    var customRepeatPickerData1: [String] = [String]()
    
    
    
    @IBAction func pushBackRepeatSwitchAction(_ sender: Any) {
    }
    
    @IBAction func deleteOnCompletionSwitchAction(_ sender: Any) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        customRepeatPickerData1 = TimeUnit.allCases.map {$0.rawValue}
        repeatPickerData = RepeatType.allCases.map {$0.rawValue}
        if let chore = chore {
            historyPickerSelection0 = chore.historyRetentionNumber-1
            historyPickerSelection1 = customRepeatPickerData1.firstIndex(of: chore.historyRetentionUnit.rawValue)!
            
            repeatPickerSelection = repeatPickerData.firstIndex(of: chore.repeatType.rawValue)!
            
            if (chore.repeatType == RepeatType.custom && chore.customRepeatNumber != nil && chore.customRepeatUnit != nil) {
                customRepeatPickerSelection0 = chore.customRepeatNumber!-1
                customRepeatPickerSelection1 = customRepeatPickerData1.firstIndex(of: chore.customRepeatUnit!.rawValue)!
            }
        }
        repeatScheduleButton.setTitle(repeatPickerData[repeatPickerSelection], for: .normal)
        updateCustomRepeatButtonMessage()
        updateRepeatOptionsVisibility()
        
        if (chore != nil) && !displayDateSetFromCalendar {
            scheduleButton.setTitle(dateFormatter.string(for: chore?.date) ?? "None", for: .normal)
        }
        else if (nextScheduledDate != nil) {
             scheduleButton.setTitle(dateFormatter.string(for: nextScheduledDate), for: .normal)
        }
        else {
            scheduleButton.setTitle("None", for: .normal)
        }
        
        if (chore != nil) && !endRepeatDateSetFromCalendar {
            if (chore?.endRepeatDate != nil) {
                endRepeatButton.setTitle(dateFormatter.string(for: chore?.endRepeatDate) ?? "None", for: .normal)
                endRepeatDate = getCorrectDate(date: (chore?.endRepeatDate)!)
            }
            else {
                endRepeatButton.setTitle("None", for: .normal)
            }
        }
        else {
             endRepeatButton.setTitle(dateFormatter.string(for: endRepeatDate) ?? "None", for: .normal)
        }
        if (nextScheduledDate != nil) {
            notScheduledSwitch.setOn(false, animated: true)
            updateSegmentVisibility()
            hideScheduleItems()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        nameTextField.delegate = self
        
        
        endRepeatSwitch.setOn(false, animated: true)
        
        pushBackRepeatSwitch.setOn(false, animated: true)
        
       
        notScheduledSwitch.setOn(false, animated: true)
        
        deleteOnCompletionSwitch.setOn(false, animated: true)
       
        if let chore = chore {
            navigationItem.title = chore.name
            nameTextField.text = chore.name
            nextScheduledDate=chore.date ?? getCorrectDate(date: Date())
           
            if (chore.repeatType != RepeatType.none) {
                pushBackRepeatSwitch.setOn(chore.pushBackRepeat, animated: true)
            }
            
            if chore.endRepeatDate != nil {
                endRepeatSwitch.setOn(true, animated: true)
                endRepeatSwitch.isHidden=false
            }
            
            if chore.date == nil {
                notScheduledSwitch.setOn(true, animated: true)
                hideScheduleItems()
            }
            
            deleteOnCompletionSwitch.setOn(chore.deleteOnCompletion, animated: true)
            
            if (chore.toDo) {
                toDoSegment.selectedSegmentIndex = 0
            }
            else {
                toDoSegment.selectedSegmentIndex = 1
            }
        }
       
        
        updateSegmentVisibility()
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
            if (dateButton === scheduleButton) {
                if (nextScheduledDate != nil) {
                    controller.highlightedDate=getCorrectDate(date: nextScheduledDate!)
                }
                controller.setScheduleButton=true
            }
            else if (dateButton === endRepeatButton) {
                if (endRepeatDate != nil) {
                    controller.highlightedDate=getCorrectDate(date: endRepeatDate!)
                }
                controller.setEndRepeatButton=true
            }
        }
        
        let button = sender as? UIBarButtonItem
        
        if (button === saveButton) {
            let name = nameTextField.text ?? ""
            let pushBackRepeat = pushBackRepeatSwitch.isOn
            let nextScheduledDateValue = notScheduledSwitch.isOn ? nil : nextScheduledDate
            let repeatType = RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) ?? RepeatType.none
            
            let customRepeatNumber = (RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) == RepeatType.custom) ? customRepeatPickerSelection0+1 : nil
            
            let customRepeatUnit = (RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) == RepeatType.custom) ? TimeUnit(rawValue: customRepeatPickerData1[customRepeatPickerSelection1]) : nil
            
            let toDo = toDoSegment.titleForSegment(at: toDoSegment.selectedSegmentIndex) == "To Do" ? true : false
            
            let historyRetentionNumber = historyPickerSelection0+1
            let historyRetentionUnit = TimeUnit(rawValue: customRepeatPickerData1[historyPickerSelection1]) ?? TimeUnit.days
            
             
            chore = Chore(name: name, type: ChoreType.oneTime, date: nextScheduledDateValue, repeatType: repeatType, endRepeatDate: endRepeatDate, nextRepeatedDate: nil, deleteOnCompletion: deleteOnCompletionSwitch.isOn, customRepeatNumber: customRepeatNumber, customRepeatUnit: customRepeatUnit, toDo: toDo, historyRetentionNumber: historyRetentionNumber, historyRetentionUnit: historyRetentionUnit, pushBackRepeat: pushBackRepeat)
        }
        
    }
    
    //MARK: - PickerView methods
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if (pickerView === repeatPicker) {
            return 1
        }
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (pickerView === repeatPicker) {
            return repeatPickerData.count
        }
        if (component == 1) {
            return customRepeatPickerData1.count
        }
        return 1000
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if (pickerView === repeatPicker) {
            return repeatPickerData[row]
        }
        if (component == 1) {
            return customRepeatPickerData1[row]
        }
        return String(row+1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        
        if (pickerView === repeatPicker) {
            repeatPickerSelection = row
        }
        
        else if (pickerView === customRepeatPicker) {
            if (component == 0) {
                customRepeatPickerSelection0 = row
            }
            else if (component == 1) {
                customRepeatPickerSelection1 = row
            }
            
        }
        
        else if (pickerView === historyPickerView) {
            if (component == 0) {
                historyPickerSelection0 = row
            }
            else if (component == 1) {
                historyPickerSelection1 = row
            }
            
        }
    }
    
    
    //MARK: Actions
    
    @IBAction func showRepeatOptions(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        if #available(iOS 13, *) {
            alert.isModalInPresentation = true
        } else {
            alert.isModalInPopover = true
        }
        
        repeatPicker = UIPickerView(frame: CGRect(x: 5, y: 10, width: 250, height: 130))
        
        alert.view.addSubview(repeatPicker)
        repeatPicker.dataSource = self
        repeatPicker.delegate = self
        
        if let chore = chore {
            repeatPicker.selectRow(repeatPickerData.firstIndex(of: chore.repeatType.rawValue) ?? 0, inComponent: 0, animated: true)
            repeatPickerSelection = repeatPickerData.firstIndex(of: chore.repeatType.rawValue) ?? 0
        }
        else {
            repeatPicker.selectRow(repeatPickerSelection, inComponent: 0, animated: true)
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
            self.repeatScheduleButton.setTitle(self.repeatPickerData[self.repeatPickerSelection], for: .normal)
            self.updateRepeatOptionsVisibility()
        
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    @IBAction func showCustomRepeatOptions(_ sender: Any) {
        let alert = UIAlertController(title: "", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        if #available(iOS 13, *) {
            alert.isModalInPresentation = true
        } else {
            alert.isModalInPopover = true
        }
        
        customRepeatPicker = UIPickerView(frame: CGRect(x: 5, y: 10, width: 250, height: 130))
        
        alert.view.addSubview(customRepeatPicker)
        customRepeatPicker.dataSource = self
        customRepeatPicker.delegate = self
        
        customRepeatPicker.selectRow(customRepeatPickerSelection0, inComponent: 0, animated: true)
        customRepeatPicker.selectRow(customRepeatPickerSelection1, inComponent: 1, animated: true)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
            
            self.updateCustomRepeatButtonMessage()
        
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    @IBAction func endRepeatSwitchAction(_ sender: Any) {
        if !endRepeatSwitch.isOn {
            endRepeatDate = nil
             endRepeatButton.setTitle("None", for: .normal)
            endRepeatSwitch.isHidden=true
        }
        else {
            endRepeatSwitch.isHidden=false
        }
    }
    
    @IBAction func notScheduledSwitchAction(_ sender: Any) {
        hideScheduleItems()
         updateSegmentVisibility()
    }
    
    @IBAction func showHistorySettings(_ sender: Any) {
        let alert = UIAlertController(title: "History retention period", message: "\n\n\n\n\n\n", preferredStyle: .alert)
        if #available(iOS 13, *) {
            alert.isModalInPresentation = true
        } else {
            alert.isModalInPopover = true
        }
               
        historyPickerView = UIPickerView(frame: CGRect(x: 5, y: 10, width: 250, height: 130))
               
        alert.view.addSubview(historyPickerView)
        historyPickerView.dataSource = self
        historyPickerView.delegate = self
        
        historyPickerView.selectRow(historyPickerSelection0, inComponent: 0, animated: true)
        historyPickerView.selectRow(historyPickerSelection1, inComponent: 1, animated: true)
               
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (UIAlertAction) in
               
        }))
        self.present(alert,animated: true, completion: nil )
    }
    
    //MARK: Private Methods
    
    private func updateSaveButtonState() {
        let text = nameTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    private func updateSegmentVisibility() {
        if (notScheduledSwitch.isOn) {
            toDoSegment.isHidden = false
        }
        else {
            toDoSegment.isHidden = true
        }
    }
    
    private func updateCustomRepeatButtonMessage() {
        let message = String(customRepeatPickerSelection0+1) + " " + customRepeatPickerData1[customRepeatPickerSelection1]
        customRepeatScheduleButton.setTitle(message, for: .normal)
    }
    
    private func updateRepeatOptionsVisibility() {
        if (RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) != RepeatType.none) {
            endRepeatLabel.isHidden=false
            endRepeatButton.isHidden=false
            endRepeatSwitch.isHidden = endRepeatDate != nil ? false : true
            pushBackLabel.isHidden=false
            pushBackRepeatSwitch.isHidden=false
        }
        else {
            endRepeatLabel.isHidden=true
            endRepeatButton.isHidden=true
            endRepeatSwitch.isHidden=true
            pushBackLabel.isHidden=true
            pushBackRepeatSwitch.isHidden=true
        }
        
        if (RepeatType(rawValue: repeatPickerData[repeatPickerSelection]) == RepeatType.custom) {
            customRepeatLabel.isHidden=false
            customRepeatScheduleButton.isHidden=false
        }
        else {
            customRepeatLabel.isHidden=true
            customRepeatScheduleButton.isHidden=true
        }
    }
    
    private func hideScheduleItems() {
        if notScheduledSwitch.isOn {
            nextScheduledDate = nil
            scheduleButton.setTitle("None", for: .normal)
            repeatScheduleButton.isHidden=true
            
            endRepeatSwitch.isHidden=true
            endRepeatButton.isHidden=true
            repeatLabel.isHidden=true
            endRepeatLabel.isHidden=true
            pushBackLabel.isHidden=true
            pushBackRepeatSwitch.isHidden=true
        }
        else {
            repeatScheduleButton.isHidden=false
            repeatLabel.isHidden=false
            
           updateRepeatOptionsVisibility()
        }
    }
    
}
