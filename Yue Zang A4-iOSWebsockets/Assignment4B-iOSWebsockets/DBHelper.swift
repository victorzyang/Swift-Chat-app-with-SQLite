//
//  DBHelper.swift
//  Assignment4B-iOSWebsockets
//
//  Created by Victor Yang on 2022-04-15.
//  Copyright © 2022 COMP2601. All rights reserved.
//

import Foundation
import SQLite3

class DBHelper{
    var db : OpaquePointer?
    var path : String = "chatHistoryDb.sqlite" //path of the SQLite database
    init(){
        self.db = createDB()
        self.createTable()
    }
    
    //function for creating the database
    func createDB() -> OpaquePointer? {
        let filePath = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathExtension(path)
        
        var db : OpaquePointer? = nil
        
        if sqlite3_open(filePath.path, &db) != SQLITE_OK {
            print("There is error in creating DB")
            return nil
        }else {
            print("Database has been created with path \(path)")
            return db
        }
    }
    
    //function for creating the table in the database
    func createTable()  {
        let query = "CREATE TABLE IF NOT EXISTS chatHistory(messageId INTEGER PRIMARY KEY AUTOINCREMENT, user TEXT, message TEXT, datetime TEXT)"
        var createTable : OpaquePointer? = nil
        
        if sqlite3_prepare_v2(self.db, query, -1, &createTable, nil) == SQLITE_OK {
            if sqlite3_step(createTable) == SQLITE_DONE { //table has been created
                print("Table creation success")
            } else {
                print("Table creation fail")
            }
        } else {
            print("Prepration fail")
        }
    }
    
    //function for inserting a new game into the database table 'games'
    func insert(user: String, message: String, datetime: String){
        let query = "INSERT INTO chatHistory (messageId, user, message, datetime) VALUES (?, ?, ?, ?)"
        
        var statement : OpaquePointer? = nil
        
        var isEmpty = false
        if read().isEmpty{
            isEmpty = true
        }
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            if isEmpty {
                sqlite3_bind_int(statement, 1, 1)
            }
            
            sqlite3_bind_text(statement, 2, (user as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 3, (message as NSString).utf8String, -1, nil)
            sqlite3_bind_text(statement, 4, (datetime as NSString).utf8String, -1, nil)
            
            if sqlite3_step(statement) == SQLITE_DONE {
                print("Data inserted success")
            }else {
                print("Data is not inserted in table")
            }
        } else {
            print("Query is not as per requirement")
        }
    }
    
    //function for querying all data in the database
    func read() -> [Message]{
        var list = [Message]()
        
        let query = "SELECT * FROM chatHistory;"
        var statement : OpaquePointer? = nil
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) == SQLITE_OK{
            while sqlite3_step(statement) == SQLITE_ROW { //while we are still checking a row in the table
                let messageId = Int(sqlite3_column_int(statement, 0))
                let user = String(describing: String(cString: sqlite3_column_text(statement, 1)))
                let message = String(describing: String(cString: sqlite3_column_text(statement, 2)))
                let datetime = String(describing: String(cString: sqlite3_column_text(statement, 3)))
                
                let model = Message()
                model.message_id = messageId
                model.user = user
                model.message = message
                model.datetime = datetime
                
                list.append(model)
            }
        }
        
        return list
    }
    
}
