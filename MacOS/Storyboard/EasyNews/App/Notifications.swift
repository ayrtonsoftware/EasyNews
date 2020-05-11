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

func NotificationGroupsAdded() -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_GroupAdded")
}

func NotificationArticleGetHeader(groupName: String) -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_ArticleGetHeader_\(groupName)")
}

func NotificationArticleHeaderAdded(groupName: String) -> NSNotification.Name {
    return NSNotification.Name(rawValue: "Notification_ArticlesUpdated_ToGroup_\(groupName)")
}
