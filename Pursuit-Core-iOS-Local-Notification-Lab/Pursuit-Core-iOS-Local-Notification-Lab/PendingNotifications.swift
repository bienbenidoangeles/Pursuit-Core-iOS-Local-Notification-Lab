//
//  PendingNotification.swift
//  LocalNotifications
//
//  Created by Bienbenido Angeles on 2/21/20.
//  Copyright © 2020 Bienbenido Angeles. All rights reserved.
//

import Foundation
import UserNotifications

class PendingNotification {
    public func  getPendingNotifications(completion: @escaping ([UNNotificationRequest])->()){
        UNUserNotificationCenter.current().getPendingNotificationRequests { (requests) in
            print("there are \(requests.count) pending requests.")
            completion(requests)
        }
    }
}
