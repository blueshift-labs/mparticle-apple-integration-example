//
//  NotificationService.m
//  NotificationSer
//
//  Created by Noufal on 18/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import "NotificationService.h"

#import <BlueShift-iOS-Extension-SDK/BlueShiftPushNotification.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
   self.contentHandler = contentHandler;
     self.bestAttemptContent = [request.content mutableCopy];
     [[BlueShiftPushNotification sharedInstance] setApiKey:@"YOUR BLUESHIFT API KEY"];

     // Modify the notification content here...
     if([[BlueShiftPushNotification sharedInstance] isBlueShiftPushNotification:request]) {
         self.bestAttemptContent.attachments = [[BlueShiftPushNotification sharedInstance] integratePushNotificationWithMediaAttachementsForRequest:request andAppGroupID:@"group.blueshift.reads"];
     } else {
         // Your Custom code comes here
     }
     
    self.contentHandler(self.bestAttemptContent);
}

- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
//    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
     if([[BlueShiftPushNotification sharedInstance] hasBlueShiftAttachments]) {
           self.bestAttemptContent.attachments = [BlueShiftPushNotification sharedInstance].attachments;
       }
       self.contentHandler(self.bestAttemptContent);
}

@end
