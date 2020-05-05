//
//  Notifications.swift
//  EasyNews
//
//  Created by Michael Bergamo on 5/4/20.
//  Copyright © 2020 Michael Bergamo. All rights reserved.
//

import Foundation

func NotificationGroupUpdated() -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_GroupUpdated")
}

func NotificationGroupAdded() -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_GroupAdded")
}

func NotificationArticleUpdated(groupName: String) -> NSNotification.Name {
    return NSNotification.Name("Notification_ArticleUpdated_FromGroup_\(groupName)")
}

func NotificationArticleAdded(groupName: String) -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_ArticleAdded_ToGroup_\(groupName)")
}
