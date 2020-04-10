//
//  MPKItBlueshift.m
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//
#import "MPKitBlueshift.h"

static NSString *const apiKey = @"apiKey";
static NSString *const appGroup = @"appGroup";
static NSString *const enablePushNotifcation = @"enablePushNotification";
static NSString *const enableInAppNotification = @"enableInApp";
static NSString *const enableManualTrigger = @"enableManualTrigger";
static NSString *const enableBackgroundFetch = @"enableBackgroundFetch";
static NSString *const inAppTimeInterval = @"inAppTimeInterval";

__weak static id<BlueShiftInAppNotificationDelegate> inAppMessageControllerDelegate = nil;
__weak static id<BlueShiftPushDelegate> pushNotificationControllerDelegate = nil;
__weak static NSDictionary *blueshiftConfiguration = nil;


@implementation MPKitBlueshift

+ (NSNumber *)kitCode {
    return @1144;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Blueshift" className:@"MPKitBlueshift"];
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

+ (void)registerForInAppMessage:(NSString *)displayPage {
    [[BlueShift sharedInstance] registerForInAppMessage:displayPage];
}

+ (void)unregisterForInAppMessage {
    [[BlueShift sharedInstance] unregisterForInAppMessage];
}

+ (void)fetchInAppNotificationFromAPI:(void (^_Nonnull)(void))success failure:(void (^)(NSError*))failure {
    [[BlueShift sharedInstance] fetchInAppNotificationFromAPI:^(void) {
        success();
        } failure:^(NSError *error){
            failure(error);
    }];
}

+ (void)displayInAppNotification {
    [[BlueShift sharedInstance] displayInAppNotification];
}

+ (void)setupDeepLinks:(NSURL *)URL handler:(void (^)(NSURL *))handler {
    [[BlueShift sharedInstance] setupDeepLinks:URL handler:^(NSURL *URL) {
        handler(URL);
    }];
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    if (!configuration[apiKey]) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }
    
    NSLog(@"%@", configuration);

    _configuration = configuration;

   if ([BlueShift sharedInstance]) {
        [self start];
    } else {
        _started = NO;
    }

    return [self execStatus:MPKitReturnCodeSuccess];;
}

- (void)start {
    static dispatch_once_t kitPredicate;

    dispatch_once(&kitPredicate, ^{
        self->_started = YES;

       if ([BlueShift sharedInstance]) {
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (id const)providerKitInstance {
    return [self started] ? [BlueShift sharedInstance] : nil;
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

-(MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

-(MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [[BlueShift sharedInstance].appDelegate handleRemoteNotification: userInfo];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

-(MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    
    [[BlueShift sharedInstance].appDelegate handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:^{}];
    
   return [self execStatus:MPKitReturnCodeSuccess];
}

+ (void)initializeBlueshiftConfig:(NSDictionary *)configDictionary {
    blueshiftConfiguration = configDictionary;
}

- (BlueShiftConfig *)fetchBlueshiftConfig:(NSDictionary *)configDictionary{
    BlueShiftConfig *config = [BlueShiftConfig config];
    
    if ([configDictionary objectForKey: apiKey] && [configDictionary objectForKey: apiKey] != [NSNull null]) {
        [config setApiKey: [configDictionary objectForKey: apiKey]];
    }
    
   // [config setApplicationLaunchOptions: self.launchOptions];
    
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
    
    if ([MPKitBlueshift pushNotificationControllerDelegate]) {
        [config setBlueShiftPushDelegate:[MPKitBlueshift pushNotificationControllerDelegate]];
    }
    
    if ([MPKitBlueshift inAppMessageControllerDelegate]) {
        [config setInAppNotificationDelegate: [MPKitBlueshift inAppMessageControllerDelegate]];
    }
    
    return config;
}

@end
