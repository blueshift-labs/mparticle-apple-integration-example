//
//  MPKItBlueshift.m
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//
#import "MPKItBlueshift.h"

static NSString *const apiKey = @"apiKey";
static NSString *const appGroup = @"appGroup";
static NSString *const enablePushNotifcation = @"enablePushNotification";
static NSString *const enableInAppNotification = @"enableInApp";
static NSString *const enableManualTrigger = @"enableManualTrigger";
static NSString *const enableBackgroundFetch = @"enableBackgroundFetch";
static NSString *const inAppTimeInterval = @"inAppTimeInterval";

__weak static id<BlueShiftInAppNotificationDelegate> inAppMessageControllerDelegate = nil;
__weak static id<BlueShiftPushDelegate> pushNotificationControllerDelegate = nil;

@interface MPKItBlueshift() {
    BlueShift *blueshiftInstance;
}

@end

@implementation MPKItBlueshift

+ (NSNumber *)kitCode {
    return @123;
}

- (BlueShift *)appboyInstance {
    return self->blueshiftInstance;
}

- (void)setAppboyInstance:(BlueShift *)instance {
    self->blueshiftInstance = instance;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Blueshift" className:@"MPKItBlueshift"];
    [MParticle registerExtension:kitRegister];
}

+ (void)setInAppMessageControllerDelegate:(id)delegate {
    inAppMessageControllerDelegate = (id<BlueShiftInAppNotificationDelegate>)delegate;
}

+ (id<BlueShiftInAppNotificationDelegate>)inAppMessageControllerDelegate {
    return inAppMessageControllerDelegate;
}

+ (void)setPushNotificationControllerDelegate:(id)delegate {
    pushNotificationControllerDelegate = (id<BlueShiftPushDelegate>)delegate;
}

+ (id<BlueShiftPushDelegate>)pushNotificationControllerDelegate {
    return pushNotificationControllerDelegate;
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    if (!configuration[apiKey]) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }

    _configuration = configuration;
    _started = NO;

    return [self execStatus:MPKitReturnCodeSuccess];;
}

- (id const)providerKitInstance {
    return [self started] ? blueshiftInstance : nil;
}

- (void)start {
    static dispatch_once_t blueshiftPredicate;
    
    dispatch_once(&blueshiftPredicate, ^{
        
        [self initializeBlueshiftConfig: _configuration];
        
        if (!blueshiftInstance ) {
            return;
        }
    });
    
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

-(MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    [self->blueshiftInstance.appDelegate registerForRemoteNotification:deviceToken];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

-(MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [self->blueshiftInstance.appDelegate handleRemoteNotification: userInfo];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

-(MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    
    [self->blueshiftInstance.appDelegate handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:^{}];
    
   return [self execStatus:MPKitReturnCodeSuccess];
}

- (void)initializeBlueshiftConfig:(NSDictionary *)configDictionary{
    BlueShiftConfig *config = [BlueShiftConfig config];
    
    if ([configDictionary objectForKey: apiKey] && [configDictionary objectForKey: apiKey] != [NSNull null]) {
        [config setApiKey: [configDictionary objectForKey: apiKey]];
    }
    
    [config setApplicationLaunchOptions: self.launchOptions];
    
    if ([configDictionary objectForKey: appGroup] && [configDictionary objectForKey: appGroup] != [NSNull null]) {
        [config setAppGroupID:[configDictionary objectForKey: appGroup]];
    }
    
    if ([configDictionary objectForKey: enablePushNotifcation] && [configDictionary objectForKey: enablePushNotifcation] != [NSNull null]) {
        [config setEnablePushNotification: [[configDictionary objectForKey: enablePushNotifcation] boolValue]];
    }
    
    if ([configDictionary objectForKey: enableInAppNotification] && [configDictionary objectForKey: enableInAppNotification] != [NSNull null]) {
        [config setEnableInAppNotification:[[configDictionary objectForKey: enableInAppNotification] boolValue]];
    }
    
    if ([configDictionary objectForKey: enableManualTrigger] && [configDictionary objectForKey: enableManualTrigger] != [NSNull null]) {
        [config setInAppManualTriggerEnabled: [[configDictionary objectForKey: enableManualTrigger] boolValue]];
    }
    
    if ([configDictionary objectForKey: enableBackgroundFetch] && [configDictionary objectForKey: enableBackgroundFetch] != [NSNull null]) {
        [config setInAppBackgroundFetchEnabled:[[configDictionary objectForKey: enableBackgroundFetch] boolValue]];
    }
    
    if ([configDictionary objectForKey: inAppTimeInterval] && [configDictionary objectForKey:inAppTimeInterval] != [NSNull null]) {
        [config setBlueshiftInAppNotificationTimeInterval:[[configDictionary objectForKey: inAppTimeInterval] doubleValue]];
    }
    
    if ([MPKItBlueshift pushNotificationControllerDelegate]) {
        [config setBlueShiftPushDelegate:[MPKItBlueshift pushNotificationControllerDelegate]];
    }
    
    if ([MPKItBlueshift inAppMessageControllerDelegate]) {
        [config setInAppNotificationDelegate: [MPKItBlueshift inAppMessageControllerDelegate]];
    }
    
    [BlueShift initWithConfiguration: config];
}

@end
