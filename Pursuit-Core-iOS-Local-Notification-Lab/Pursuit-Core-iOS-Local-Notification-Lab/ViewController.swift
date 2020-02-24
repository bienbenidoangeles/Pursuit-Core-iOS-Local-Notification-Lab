//
//  ViewController.swift
//  LocalNotifications
//
//  Created by Bienbenido Angeles on 2/21/20.
//  Copyright © 2020 Bienbenido Angeles. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsViewController: UIViewController {
    

    @IBOutlet weak var tableView: UITableView!
    
    //data for table view
    private var notifications = [UNNotificationRequest](){
        didSet{
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private let center = UNUserNotificationCenter.current()
    
    private let pendingNotification = PendingNotification()
    
    
    private var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        
        //setting this view controller as the UNNotificationCenterDelegate
        center.delegate = self
        configureRefreshControl()
        checkForNotificationAuthorization()
        loadNotificatons()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let navC = segue.destination as? UINavigationController, let createVC = navC.viewControllers.first as? CreateNotificationViewController else {
            fatalError("failed to downcast")
        }
        createVC.delegate = self
    }
    
    private func configureRefreshControl(){
        refreshControl = UIRefreshControl()
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(loadNotificatons), for: .valueChanged)
    }
    
    @objc
    private func loadNotificatons(){
        pendingNotification.getPendingNotifications { (requests) in
            self.notifications = requests
            
            //stop refresh control from animating
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    private func checkForNotificationAuthorization(){
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus == .authorized{
                print("app is authorized for notifications")
            } else {
                self.requestNotificationPermissions()
            }
        }
    }
    
    private func requestNotificationPermissions(){
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if let error = error{
                print("error requesting notification: \(error)")
                return
            }
            
            if granted {
                print("access was granted")
            } else {
                print("access denied")
            }
        }
    }
}

extension NotificationsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath)
        let notification = notifications[indexPath.row]
        cell.textLabel?.text = notification.content.title
        cell.detailTextLabel?.text = notification.content.body
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // we will delete the pending notification
            removeNotification(atIndexPath: indexPath)
        }
    }
    
    private func removeNotification(atIndexPath indexPath: IndexPath){
        //remove notification from notification center
        let notification = notifications[indexPath.row]
        let identifier = notification.identifier
        center.removePendingNotificationRequests(withIdentifiers: [identifier])
        //remove notification from the array
        notifications.remove(at: indexPath.row)
        //remove notification from the table view
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension NotificationsViewController: UNUserNotificationCenterDelegate{
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
}

extension NotificationsViewController: CreateNotificationControllerDelegate{
    func didCreateNotification(_ createNotificationController: CreateNotificationViewController) {
        loadNotificatons()
    }
}
