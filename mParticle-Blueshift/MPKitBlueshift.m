//
//  MPKItBlueshift.m
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//
#import "MPKitBlueshift.h"

static NSString *const eabAPIKey = @"eventApiKey";
NSString *const MPKitBlueshifUserAttributesDOB = @"date_of_birth";
NSString *const MPKitBlueshifUserAttributesJoinedAt = @"joined_at";
NSString *const MPKitBlueshifUserAttributesEducation = @"education";
NSString *const MPKITBlueshiftScreenViewwd = @"screen_viewed";

__weak static BlueShiftConfig *blueshiftConfig = nil;


@implementation MPKitBlueshift

+ (NSNumber *)kitCode {
    return @1144;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Blueshift" className:@"MPKitBlueshift"];
    [MParticle registerExtension:kitRegister];
}

- (id const)providerKitInstance {
    return [self started] ? [BlueShift sharedInstance] : nil;
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBlueshift) returnCode:returnCode];
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

+ (void)setupBlueshiftConfig:(BlueShiftConfig *)config {
    blueshiftConfig = config;
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    if (!configuration[eabAPIKey]) {
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
       if ([BlueShift sharedInstance]) {
            return;
        }
        
        if (blueshiftConfig) {
            [blueshiftConfig setApplicationLaunchOptions: self.launchOptions];
            
            [BlueShift initWithConfiguration:blueshiftConfig];
        }
        
        self->_started = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSDictionary *userInfo = @{mParticleKitInstanceKey:[[self class] kitCode]};
            [[NSNotificationCenter defaultCenter] postNotificationName:mParticleKitDidBecomeActiveNotification
                                                                object:nil
                                                              userInfo:userInfo];
        });
    });
}

- (MPKitExecStatus *)setDeviceToken:(NSData *)deviceToken {
    [[BlueShift sharedInstance].appDelegate registerForRemoteNotification:deviceToken];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)receivedUserNotification:(NSDictionary *)userInfo {
    [[BlueShift sharedInstance].appDelegate handleRemoteNotification: userInfo];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    
    [[BlueShift sharedInstance].appDelegate handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:^{}];
    
   return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIncrementUserAttribute:(FilteredMParticleUser *)user {
    return [self updateUser:user];
}

- (MPKitExecStatus *)onRemoveUserAttribute:(FilteredMParticleUser *)user {
    [BlueShiftUserInfo removeCurrentUserInfo];
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onSetUserAttribute:(FilteredMParticleUser *)user {
    return [self updateUser: user];
}

- (MPKitExecStatus *)onSetUserTag:(FilteredMParticleUser *)user {
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)onIdentifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser: user];
}

- (MPKitExecStatus *)onLoginComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser: user];
}

- (MPKitExecStatus *)onLogoutComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser: user];
}

- (MPKitExecStatus *)onModifyComplete:(FilteredMParticleUser *)user request:(FilteredMPIdentityApiRequest *)request {
    return [self updateUser: user];
}


- (MPKitExecStatus *)logBaseEvent:(MPBaseEvent *)event{
    if ([event isKindOfClass:[MPEvent class]]) {
        return [self routeEvent:(MPEvent *)event];
    } else if ([event isKindOfClass:[MPCommerceEvent class]]) {
       return [self routeCommerceEvent:(MPCommerceEvent *)event];
    } else {
        return [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBlueshift) returnCode:MPKitReturnCodeUnavailable];
    }
}

- (MPKitExecStatus *)routeEvent:(MPEvent *)event {
    if (event && event.customAttributes) {
        [[BlueShift sharedInstance] trackEventForEventName: event.name andParameters: event.customAttributes canBatchThisEvent: NO];
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBlueshift) returnCode:MPKitReturnCodeSuccess forwardCount:0];
    
    if (commerceEvent.action == MPCommerceEventActionPurchase) {
        [[BlueShift sharedInstance] trackEventForEventName: kEventPurchase andParameters: commerceEvent.customAttributes canBatchThisEvent: NO];
    } else {
        NSArray *expandedInstructions = [commerceEvent expandedInstructions];
        
        for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
            [self logBaseEvent:commerceEventInstruction.event];
            [execStatus incrementForwardCount];
        }
    }
    
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (event && event.customAttributes) {
        NSMutableDictionary *customAttributes =[[event customAttributes] copy];
        [customAttributes setObject: event.name forKey: MPKITBlueshiftScreenViewwd];
        
        [[BlueShift sharedInstance] trackEventForEventName:kEventPageLoad andParameters: customAttributes canBatchThisEvent:NO];
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)updateUser:(FilteredMParticleUser *)user {
    if (user) {
        BlueShiftUserInfo *userInfo = [BlueShiftUserInfo sharedInstance];
        NSDictionary *userAttributes = user.userAttributes;
        NSDictionary *userIdentities = user.userIdentities;
        
        
        if (userIdentities[@(MPUserIdentityCustomerId)] && userIdentities[@(MPUserIdentityCustomerId)] != [NSNull null]) {
            userInfo.retailerCustomerID = (NSString *) userIdentities[@(MPUserIdentityCustomerId)];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeFirstName] && [userAttributes objectForKey:mParticleUserAttributeFirstName] != [NSNull null]) {
            userInfo.name = (NSString *)[userAttributes objectForKey: mParticleUserAttributeFirstName];
            userInfo.firstName = (NSString *)[userAttributes objectForKey: mParticleUserAttributeFirstName];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeLastName] && [userAttributes objectForKey: mParticleUserAttributeLastName] != [NSNull null]) {
            userInfo.lastName = (NSString *)[userAttributes objectForKey: mParticleUserAttributeLastName];
        }
        
        if (userIdentities[@(MPUserIdentityEmail)] && userIdentities[@(MPUserIdentityEmail)] != [NSNull null]) {
            userInfo.email = (NSString *) userIdentities[@(MPUserIdentityEmail)];
        }
        
        if ([userAttributes objectForKey: MPKitBlueshifUserAttributesDOB] && [userAttributes objectForKey: MPKitBlueshifUserAttributesDOB] != [NSNull null]) {
             NSTimeInterval dateOfBirthTimeStamp = [[userAttributes objectForKey: MPKitBlueshifUserAttributesDOB] doubleValue];
            userInfo.dateOfBirth = [NSDate dateWithTimeIntervalSinceReferenceDate:dateOfBirthTimeStamp];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeGender] && [userAttributes objectForKey: mParticleUserAttributeGender] != [NSNull null]) {
            userInfo.gender = (NSString *)[userAttributes objectForKey: mParticleUserAttributeGender];
        }
        
        if ([userAttributes objectForKey: MPKitBlueshifUserAttributesJoinedAt] && [userAttributes objectForKey: MPKitBlueshifUserAttributesJoinedAt] != [NSNull null]) {
            NSTimeInterval joinedAtTimeStamp = [[userAttributes objectForKey: MPKitBlueshifUserAttributesJoinedAt] doubleValue];
            userInfo.dateOfBirth = [NSDate dateWithTimeIntervalSinceReferenceDate:joinedAtTimeStamp];
        }
        
        if (userIdentities[@(MPUserIdentityFacebook)] && userIdentities[@(MPUserIdentityFacebook)] != [NSNull null]) {
            userInfo.facebookID = (NSString *) userIdentities[@(MPUserIdentityFacebook)];
        }
        
        if ([userAttributes objectForKey: MPKitBlueshifUserAttributesEducation] && [userAttributes objectForKey: MPKitBlueshifUserAttributesEducation] != [NSNull null]) {
            userInfo.education = (NSString *)[userAttributes objectForKey: MPKitBlueshifUserAttributesEducation];
        }
        
        //todo add additional dictionary
        
        [userInfo save];
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

@end
