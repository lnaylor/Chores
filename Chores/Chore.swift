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
    var nextRepeatedDate: Date?
    var deleteOnCompletion: Bool
    var customRepeatNumber: Int?
    var customRepeatUnit: TimeUnit?
    var toDo: Bool
    var historyRetentionNumber: Int
    var historyRetentionUnit: TimeUnit
    var pushedBack: Bool
    var pushBackRepeat: Bool
    
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
        static let nextRepeatedDate = "nextRepeatedDate"
        static let deleteOnCompletion = "deleteOnCompletion"
        static let customRepeatNumber = "customRepeatNumber"
        static let customRepeatUnit = "customRepeatUnit"
        static let toDo = "toDo"
        static let historyRetentionNumber = "historyRetentionNumber"
        static let historyRetentionUnit = "historyRetentionUnit"
        static let pushedBack = "pushedBack"
        static let pushBackRepeat = "pushBackRepeat"
    }
    
    init(name: String, type: ChoreType, date: Date?, repeatType: RepeatType, endRepeatDate: Date?, nextRepeatedDate: Date?, deleteOnCompletion: Bool, customRepeatNumber: Int?, customRepeatUnit: TimeUnit?, toDo: Bool, historyRetentionNumber: Int, historyRetentionUnit: TimeUnit, pushedBack: Bool = false, pushBackRepeat: Bool = false) {
        self.name=name
        self.type=type
        self.date=date
        self.repeatType=repeatType
        self.endRepeatDate=endRepeatDate
        self.completedDates = [Date]()
        self.nextRepeatedDate = nextRepeatedDate
        self.deleteOnCompletion=deleteOnCompletion
        self.customRepeatNumber=customRepeatNumber
        self.customRepeatUnit = customRepeatUnit
        self.historyRetentionNumber=historyRetentionNumber
        self.historyRetentionUnit=historyRetentionUnit
        self.toDo = toDo
        self.pushedBack = pushedBack
        self.pushBackRepeat = pushBackRepeat
    }
    
    init(name: String, type: ChoreType, date: Date?, repeatType: RepeatType, endRepeatDate: Date?, completedDates: [Date], nextRepeatedDate: Date?, deleteOnCompletion: Bool, customRepeatNumber: Int?, customRepeatUnit: TimeUnit?, toDo: Bool, historyRetentionNumber: Int, historyRetentionUnit: TimeUnit, pushedBack: Bool = false, pushBackRepeat: Bool = false) {
        self.name=name
        self.type=type
        self.date=date
        self.repeatType=repeatType
        self.endRepeatDate=endRepeatDate
        self.completedDates = completedDates
        self.nextRepeatedDate = nextRepeatedDate
        self.deleteOnCompletion=deleteOnCompletion
        self.customRepeatNumber=customRepeatNumber
        self.customRepeatUnit = customRepeatUnit
        self.historyRetentionNumber=historyRetentionNumber
        self.historyRetentionUnit=historyRetentionUnit
        self.toDo = toDo
        self.pushedBack = pushedBack
        self.pushBackRepeat = pushBackRepeat
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(type.rawValue, forKey: PropertyKey.type)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(repeatType.rawValue, forKey: PropertyKey.repeatType)
        aCoder.encode(endRepeatDate, forKey: PropertyKey.endRepeatDate)
        aCoder.encode(completedDates, forKey: PropertyKey.completedDates)
        aCoder.encode(nextRepeatedDate, forKey: PropertyKey.nextRepeatedDate)
        aCoder.encode(deleteOnCompletion, forKey: PropertyKey.deleteOnCompletion)
        aCoder.encode(customRepeatNumber, forKey: PropertyKey.customRepeatNumber)
        print("SAVING")
        print(customRepeatNumber)
        aCoder.encode(customRepeatUnit?.rawValue, forKey: PropertyKey.customRepeatUnit)
        aCoder.encode(toDo, forKey: PropertyKey.toDo)
        aCoder.encode(historyRetentionNumber, forKey: PropertyKey.historyRetentionNumber)
        aCoder.encode(historyRetentionUnit.rawValue, forKey: PropertyKey.historyRetentionUnit)
        aCoder.encode(pushedBack, forKey: PropertyKey.pushedBack)
        aCoder.encode(pushBackRepeat, forKey: PropertyKey.pushBackRepeat)
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
        
        let endRepeatDate = aDecoder.decodeObject(forKey: PropertyKey.endRepeatDate) as? Date
        
        let completedDates = aDecoder.decodeObject(forKey: PropertyKey.completedDates) as? [Date] ?? [Date]()
        
        let nextRepeatedDate = aDecoder.decodeObject(forKey: PropertyKey.nextRepeatedDate) as? Date
        
        let deleteOnCompletion = aDecoder.decodeBool(forKey: PropertyKey.deleteOnCompletion) as Bool
        
        var customRepeatNumber: Int?
        if let customRepeatNumberString = aDecoder.decodeObject(forKey: PropertyKey.customRepeatNumber) as? Int {
            customRepeatNumber = customRepeatNumberString
        }
        
        
        let customRepeatUnitString = aDecoder.decodeObject(forKey: PropertyKey.customRepeatUnit) as? String ?? ""
        let customRepeatUnit = customRepeatUnitString.isEmpty ? nil :  TimeUnit(rawValue: customRepeatUnitString)
        
        let toDo = aDecoder.decodeBool(forKey: PropertyKey.toDo) as Bool
        
        let historyRetentionNumber = aDecoder.decodeInteger(forKey: PropertyKey.historyRetentionNumber)
        
        let historyRetentionUnit = TimeUnit(rawValue: aDecoder.decodeObject(forKey: PropertyKey.historyRetentionUnit) as? String ?? TimeUnit.days.rawValue) ?? TimeUnit.days
        
        let pushedBack = aDecoder.decodeBool(forKey: PropertyKey.pushedBack) as Bool
        
        let pushBackRepeat = aDecoder.decodeBool(forKey: PropertyKey.pushBackRepeat) as Bool
        
        self.init(name: name, type: type, date: date, repeatType: repeatType ?? RepeatType.none, endRepeatDate: endRepeatDate, completedDates: completedDates, nextRepeatedDate: nextRepeatedDate, deleteOnCompletion: deleteOnCompletion, customRepeatNumber: customRepeatNumber, customRepeatUnit: customRepeatUnit, toDo: toDo, historyRetentionNumber: historyRetentionNumber, historyRetentionUnit: historyRetentionUnit, pushedBack: pushedBack, pushBackRepeat: pushBackRepeat)
    }
}
