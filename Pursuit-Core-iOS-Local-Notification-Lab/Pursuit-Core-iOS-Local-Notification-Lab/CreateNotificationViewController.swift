//
//  CreateNotificationViewController.swift
//  LocalNotifications
//
//  Created by Bienbenido Angeles on 2/21/20.
//  Copyright © 2020 Bienbenido Angeles. All rights reserved.
//

import UIKit

extension TimeInterval {
    func timeToDate () -> String {
        let date = Date(timeIntervalSinceNow: self)
        
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "MM/dd/yyyy HH:mm"
        return dateFormat.string(from: date)
    }
}

protocol CreateNotificationControllerDelegate: AnyObject {
    func didCreateNotification(_ createNotificationController: CreateNotificationViewController)
}

class CreateNotificationViewController: UIViewController {
    
    @IBOutlet weak var userInput: UITextField!
    
    @IBOutlet weak var date: UIDatePicker!

    weak var delegate: CreateNotificationControllerDelegate?

    private var timeInterval: TimeInterval = Date().timeIntervalSinceNow + 5 //current time plus 5 seconds

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func createLocalNotifications(){
        //step 1:
        let content = UNMutableNotificationContent()
        content.title = userInput.text ?? "No title"
        content.body = "Set to fire at \(timeInterval.timeToDate())"
        content.sound = .default //only works in the background and the app is not on silent
        
        //identifier:
        let identifier = UUID().uuidString // unique string
        
        if let imageURL = Bundle.main.url(forResource: "swift-logo", withExtension: ".png"){
            
            do {
                //attachment:
                let attachment = try UNNotificationAttachment(identifier: identifier, url: imageURL, options: nil)
                content.attachments = [attachment]
            } catch {
                print("error", error)
            }
            
        } else {
            print("Image resource not found")
        }
        
        //create trigger
        //3 possible triggers
        // time interval, calender, and location
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        //create a request
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        //add request to the unnotification center
        UNUserNotificationCenter.current().add(request) { (error) in
            if let error = error {
                print("Error adding request", error)
            } else {
                print("request was successfully added")
            }
        }

    }
    
    @IBAction func dateChanged(_ sender: UIDatePicker) {
        guard sender.date > Date() else {
                   return
               }
               //timeIntervalSinceNow creates a time stamp of the exact date
               timeInterval = sender.date.timeIntervalSinceNow
    }
    
    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        createLocalNotifications()
        delegate?.didCreateNotification(self)
        dismiss(animated: true, completion: nil)
    }
    
}
