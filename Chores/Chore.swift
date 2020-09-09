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
    }
    
    init(name: String, type: ChoreType, date: Date?, repeatType: RepeatType, endRepeatDate: Date?) {
        self.name=name
        self.type=type
        self.date=date
        self.repeatType=repeatType
        self.endRepeatDate=endRepeatDate
    }
    
    //MARK: NSCoding
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(type.rawValue, forKey: PropertyKey.type)
        aCoder.encode(date, forKey: PropertyKey.date)
        aCoder.encode(repeatType.rawValue, forKey: PropertyKey.repeatType)
        aCoder.encode(endRepeatDate, forKey: PropertyKey.endRepeatDate)
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
        
        self.init(name: name, type: type, date: date, repeatType: repeatType ?? RepeatType.none, endRepeatDate: endRepeatDate)
    }
}
