//
//  ViewController.swift
//  Assignment4B-iOSWebsockets
//
//  Created by Yue Zhang Winter 2018
//  Modified for 2601 Winter 2019 by Louis D. Nel
//  Copyright © 2018 COMP2601. All rights reserved.
//
/*
 For testing:
 The application will read a URL address e.g.
 http://localhost:3000 or
 http://134.117.26.92:3000
 from the user input text field and connect to that server.
 If none is supplied then the localhost address will be used.
 */
import UIKit
import Starscream
import PopupDialog

class ViewController: UIViewController, UITableViewDataSource, WebSocketDelegate {
    
    let db = DBHelper() //DBHelper instance for inserting and reading database data. Added for thesis
    
    enum ConnectionType {
        case Connect
        case Disconnet
    }
    
    // MARK: Properties
    
    @IBOutlet var userInput: UITextField!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var disconnectButton: UIButton!
    @IBOutlet var sendMessageButton: UIButton!
    @IBOutlet var messageTableView: UITableView!
    
    var socket: WebSocket!
    var messages: [String] = []
    var request = URLRequest(url: URL(string: "http://localhost:3000")!)
    //var request = URLRequest(url: URL(string: "http://134.117.26.92:3000")!)

    override func viewDidLoad() {
        super.viewDidLoad()
 
        request.timeoutInterval = 30
        socket = WebSocket(request: request)
        socket.delegate = self
        disconnectButton.isEnabled = false
        sendMessageButton.isEnabled = false
        messageTableView.dataSource = self
        userInput.text = "http://localhost:3000"
    }
    
    // MARK: Websocket Delegate Methods
    
    func websocketDidConnect(socket: WebSocketClient) {
        print("websocketDidConnect")
        showDialog(type: ConnectionType.Connect)
        toggleButtons()
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("websocketDidDisconnect")
        if let e = error as? WSError {
            showDialog(type: ConnectionType.Disconnet, message: e.message)
        } else if let e = error {
            showDialog(type: ConnectionType.Disconnet, message: e.localizedDescription)
        } else {
            showDialog(type: ConnectionType.Disconnet)
        }
    }
    
    //whenever a message is received, database insert method needs to be called here
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Received message: " + text)
        //I'm not sure how to get the id of a WebSocketClient...
        
        //For now, I'll just call all clients "User"
        if ( !text.contains("Connected to Server") ) {
            messages.append(text)
            updateTableView()
            
            //Get the date of the message (ie. the current date)
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yyyy"
            let datetime = dateFormatter.string(from: date)
            
            self.db.insert(user: "User", message: text, datetime: datetime) //calls the database insertion method in DBHelper()
        }
        
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print("Received data: \(data.count)")
    }
    
    // MARK: Write Text Action
    
    @IBAction func writeText(_ sender: UIButton) {
        if (userInput.text != nil && userInput.text != "") {
            socket.write(string: userInput.text!)
            userInput.text = ""
        }
    }
    
    // MARK: Connect/Disconnent Action
    
    @IBAction func connect(_ sender: UIButton) {
        if (!socket.isConnected) {
            //read chat client server address from user text field
            if (userInput.text != nil && userInput.text != "") {
                let addressString = userInput.text!.trimmingCharacters(in: .whitespacesAndNewlines)
                print("URL address string: \(addressString)" )
                let url = URL(string: addressString)!
                print("url.host: \(url.host!)")
                print("url.port: \(url.port!)")
                request = URLRequest(url: URL(string: addressString)!)
                request.timeoutInterval = 120
                socket.request = request
            }
            socket.connect()
        }
    }
    
    @IBAction func disconnect(_ sender: UIButton) {
        if socket.isConnected {
            socket.disconnect()
            toggleButtons()
        }
    }
    
    // Display database data
    @IBAction func displayData(_ sender: UIButton){
        print("displayData button clicked")
        let list = self.db.read() //this returns a list of all the messages in the database
        var message = "" //this is the variable used to display the list of messages to the UI
        for index in 0..<list.count{ //iterates through list of messages in chat history to append information to display to the message variable
            message += "Id: "
            message += String(list[index].message_id)
            message += "\nUser: "
            message += list[index].user!
            message += "\nMessage: "
            message += list[index].message!
            message += "\nDatetime: "
            message += list[index].datetime!
            message += "\n\n"
        }
        
        showMessage(title: "Database Data", message: message) //calls function to trigger an alert that displays the database data
    }
    
    // MARK: TableView Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell")!
        
        let text = messages[indexPath.row]
        
        cell.textLabel?.text = text
        
        return cell
    }
    
    // MARK: Private method
    
    private func toggleButtons() {
        connectButton.isEnabled = !connectButton.isEnabled
        disconnectButton.isEnabled = !disconnectButton.isEnabled
        sendMessageButton.isEnabled = disconnectButton.isEnabled
    }
    
    private func updateTableView() {
        messageTableView.beginUpdates()
        messageTableView.insertRows(at: [IndexPath(row: messages.count-1, section: 0)], with: .automatic)
        messageTableView.endUpdates()
    }
    
    // MARK: Dialog Methods
    func showDialog(type: ConnectionType, message: String? = nil, animated: Bool = true) {
        var title: String!
        // Prepare the popup
        if (type == ConnectionType.Connect){
            title = "Connected to Server"
        }
        else {
            title = "Disconnect from Server"
        }
        
        // Create the dialog
        let popup = PopupDialog(title: title,
                                message: message,
                                buttonAlignment: .horizontal,
                                transitionStyle: .zoomIn,
                                tapGestureDismissal: true,
                                hideStatusBar: true) {
                                    print("Completed")
        }
        
        // Create first button
        let buttonOne = DefaultButton(title: "OK"){}
        
        // Add buttons to dialog
        popup.addButtons([buttonOne])
        
        // Present dialog
        self.present(popup, animated: animated, completion: nil)
    }
    
    //function for which an alert pops up to display database data
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
                case .default:
                print("default")
                
                case .cancel:
                print("cancel")
                
                case .destructive:
                print("destructive")
                
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
}
