//
//  Message.swift
//  Assignment4B-iOSWebsockets
//
//  Created by Victor Yang on 2022-04-15.
//  Copyright © 2022 COMP2601. All rights reserved.
//

import Foundation

class Message: Codable{ //the Message class represents a new message that is added to the database
    var message_id : Int = 1
    var user : String?
    var message : String?
    var datetime : String? // I think I'll just have the datetime as a string
}
