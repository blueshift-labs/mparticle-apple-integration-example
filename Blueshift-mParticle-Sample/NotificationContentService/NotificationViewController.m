//
//  NotificationViewController.m
//  NotificationContentService
//
//  Created by Noufal on 18/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
    
    self.appGroupID = @"group.blueshift.reads";
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveNotification:(UNNotification *)notification {
    if([self isBlueShiftCarouselPushNotification:notification]) {
        [self showCarouselForNotfication:notification];
    } else {
        // Perform your codes here
    }
}

- (void)didReceiveNotificationResponse:(UNNotificationResponse *)response completionHandler:(void (^)(UNNotificationContentExtensionResponseOption))completion {
    //Place following codes after your code lines
    if([self isBlueShiftCarouselActions:response]) {
        [self setCarouselActionsForResponse:response completionHandler:^(UNNotificationContentExtensionResponseOption option) {
            completion(option);
        }];
    } else {
        
    }
}

@end
