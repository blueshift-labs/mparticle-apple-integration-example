//
//  AppDelegate.h
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 13/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import <UserNotifications/UserNotifications.h>
#import <BlueShift.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, UNUserNotificationCenterDelegate, BlueshiftUniversalLinksDelegate>

@property (strong, nonatomic) UIWindow *window;

@end

