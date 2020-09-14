//
//  Chore.swift
//  Chores
//
//  Created by Lauren Marie Naylor on 8/29/20.
//  Copyright © 2020 Lauren Marie Naylor. All rights reserved.
//

import UIKit
import os.log

class Chore: NSObject, NSCoding {
    
    //MARK: Properties
    
    var name: String
    var type: ChoreType
    var date: Date?
    var repeatType: RepeatType
    var endRepeatDate: Date?
    var completedDates: [Date]
    var repeatFromDate: Date?
    var deleteOnCompletion: Bool
    var customRepeatNumber: Int?
    var customRepeatUnit: CustomRepeatUnit?
    var toDo: Bool
    
    //MARK: Archiving Paths
    
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("chores")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let type = "type"
        static let date = "date"
        static let repeatType = "repeatType"
        static let endRepeatDate = "endRepeatDate"
        static let completedDates = "completedDates"
        static let repeatFromDate = "repeatFromDate"
        static let deleteOnCompletion = "deleteOnCompletion"
        static let customRepeatNumber = "customRepeatNumber"
        static let customRepeatUnit = "customRepeatUnit"
        static let toDo = "toDo"
    }
    
    init(name: String, type: ChoreType, date: Date?, repeatType: RepeatType, endRepeatDate: Date?, repeatFromDate: Date?, deleteOnCompletion: Bool, customRepeatNumber: Int?, customRepeatUnit: CustomRepeatUnit?, toDo: Bool) {
        self.name=name
        self.type=type
        self.date=date
        self.repeatType=repeatType
        self.endRepeatDate=endRepeatDate
        self.completedDates = [Date]()
        self.repeatFromDate = repeatFromDate
        self.deleteOnCompletion=deleteOnCompletion
        self.customRepeatNumber=customRepeatNumber
        self.customRepeatUnit = customRepeatUnit
        self.toDo = toDo
    }
    
    init(name: String, type: ChoreType, date: Date?, repeatType: RepeatType, endRepeatDate: Date?, completedDates: [Date], repeatFromDate: Date?, deleteOnCompletion: Bool, customRepeatNumber: Int?, customRepeatUnit: CustomRepeatUnit?, toDo: Bool) {
        self.name=name
        self.type=type
        self.date=date
        self.repeatType=repeatType
        self.endRepeatDate=endRepeatDate
        self.completedDates = completedDates
        self.repeatFromDate = repeatFromDate
        self.deleteOnCompletion=deleteOnCompletion
        self.customRepeatNumber=customRepeatNumber
        self.customRepeatUnit = customRepeatUnit
        self.toDo = toDo
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(type.rawValue, forKey: PropertyKey.type)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(repeatType.rawValue, forKey: PropertyKey.repeatType)
        aCoder.encode(endRepeatDate, forKey: PropertyKey.endRepeatDate)
        aCoder.encode(completedDates, forKey: PropertyKey.completedDates)
        aCoder.encode(repeatFromDate, forKey: PropertyKey.repeatFromDate)
        aCoder.encode(deleteOnCompletion, forKey: PropertyKey.deleteOnCompletion)
        aCoder.encode(customRepeatNumber, forKey: PropertyKey.customRepeatNumber)
        aCoder.encode(customRepeatUnit, forKey: PropertyKey.customRepeatUnit)
        aCoder.encode(toDo, forKey: PropertyKey.toDo)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Chore object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        guard let type = ChoreType(rawValue: aDecoder.decodeObject(forKey: PropertyKey.type) as! String) else {
            os_log("Unable to decode the type for a Chore object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let date = aDecoder.decodeObject(forKey: PropertyKey.date) as? Date

        
        let repeatType = RepeatType(rawValue: aDecoder.decodeObject(forKey: PropertyKey.repeatType) as? String ?? RepeatType.none.rawValue)
        
        /*
        guard let repeatType = RepeatType(rawValue: aDecoder.decodeObject(forKey: PropertyKey.repeatType) as! String) else {
            os_log("Unable to decode the repeatType for a Chore object.", log: OSLog.default, type: .debug)
            return nil
        }*/
        
        let endRepeatDate = aDecoder.decodeObject(forKey: PropertyKey.endRepeatDate) as? Date
        
        let completedDates = aDecoder.decodeObject(forKey: PropertyKey.completedDates) as? [Date] ?? [Date]()
        
        let repeatFromDate = aDecoder.decodeObject(forKey: PropertyKey.repeatFromDate) as? Date
        
        let deleteOnCompletion = aDecoder.decodeBool(forKey: PropertyKey.deleteOnCompletion) as Bool
        
        var customRepeatNumber: Int?
        if let customRepeatNumberString = aDecoder.decodeObject(forKey: PropertyKey.customRepeatNumber) as? String {
            customRepeatNumber = Int(customRepeatNumberString)
        }
        
 
        
        
        let customRepeatUnitString = aDecoder.decodeObject(forKey: PropertyKey.customRepeatUnit) as? String ?? ""
        let customRepeatUnit = customRepeatUnitString.isEmpty ? nil :  CustomRepeatUnit(rawValue: customRepeatUnitString)
        
        let toDo = aDecoder.decodeBool(forKey: PropertyKey.toDo) as Bool
        
        self.init(name: name, type: type, date: date, repeatType: repeatType ?? RepeatType.none, endRepeatDate: endRepeatDate, completedDates: completedDates, repeatFromDate: repeatFromDate, deleteOnCompletion: deleteOnCompletion, customRepeatNumber: customRepeatNumber, customRepeatUnit: customRepeatUnit, toDo: toDo)
    }
}
