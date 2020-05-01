//
//  MPKItBlueshift.m
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//
#import "MPKitBlueshift.h"

NSString *const BlueshiftEventApiKey = @"eventApiKey";
NSString *const MPKitBlueshiftUserAttributesDOB = @"date_of_birth";
NSString *const MPKitBlueshiftUserAttributesJoinedAt = @"joined_at";
NSString *const MPKitBlueshiftUserAttributesEducation = @"education";
NSString *const MPKitBlueshiftScreenViewed = @"screen_viewed";
NSString *const MPKitBlueshiftUserAttributesAge = @"age";
NSString *const MPKitBlueshiftUserAttributesAddress = @"address";
NSString *const MPKitBlueshiftUserAttributesMobile = @"mobile";
NSString *const MPKitBlueshiftUserAttributesCity = @"city";
NSString *const MPKitBlueshiftUserAttributesState = @"state";
NSString *const MPKitBlueshiftUserAttributesZipCode = @"zip_code";
NSString *const MPKitBlueshiftUserAttributesCountry = @"country";

NSString *const BSFT_MESSAGE_UUID =@"bsft_message_uuid";

static BlueShiftConfig *blueshiftConfig = nil;

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

+ (void)handleBlueshiftLink:(NSURL *)URL handler:(void (^)(NSURL *))handler {
    [[BlueShift sharedInstance] handleBlueshiftLink: URL handler:^(NSURL *URL) {
        handler(URL);
    }];
}

+ (void)setBlueshiftConfig:(BlueShiftConfig *)config {
    blueshiftConfig = config;
}

+ (BlueShiftConfig *)blueshiftConfig {
    return blueshiftConfig;
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    if ([configuration objectForKey: BlueshiftEventApiKey] == nil) {
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
       if (![BlueShift sharedInstance]) {
           return;
        }
        
        BlueShiftConfig *config = [MPKitBlueshift blueshiftConfig] ? [MPKitBlueshift blueshiftConfig] : [BlueShiftConfig config];
        [config setApiKey: [_configuration objectForKey: BlueshiftEventApiKey]];
        [config setApplicationLaunchOptions: self.launchOptions];
        
        [BlueShift initWithConfiguration:blueshiftConfig];
        
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
    if ([self willHandlePushMessage: userInfo]) {
        [[BlueShift sharedInstance].appDelegate handleRemoteNotification: userInfo];
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo {
    if ([self willHandlePushMessage: userInfo]) {
        [[BlueShift sharedInstance].appDelegate handleActionWithIdentifier:identifier forRemoteNotification:userInfo completionHandler:^{}];
    }
    
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
    [[BlueShift sharedInstance] trackEventForEventName: event.name andParameters: event.customAttributes canBatchThisEvent: NO];
    
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
    NSMutableDictionary *customAttributes = [NSMutableDictionary dictionary];
    [customAttributes setObject:event.name forKey: MPKitBlueshiftScreenViewed];
        
    if (event.customAttributes) {
        [customAttributes addEntriesFromDictionary: event.customAttributes];
    }
    
    [[BlueShift sharedInstance] trackEventForEventName:kEventPageLoad andParameters: customAttributes canBatchThisEvent:NO];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)updateUser:(FilteredMParticleUser *)user {
    if (user) {
        BlueShiftUserInfo *userInfo = [BlueShiftUserInfo sharedInstance];
        NSDictionary *userAttributes = [user.userAttributes copy];
        NSDictionary *userIdentities = [user.userIdentities copy];
        
        
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
        
        if ([userAttributes objectForKey: MPKitBlueshiftUserAttributesDOB] && [userAttributes objectForKey: MPKitBlueshiftUserAttributesDOB] != [NSNull null]) {
             NSTimeInterval dateOfBirthTimeStamp = [[userAttributes objectForKey: MPKitBlueshiftUserAttributesDOB] doubleValue];
            userInfo.dateOfBirth = [NSDate dateWithTimeIntervalSinceReferenceDate:dateOfBirthTimeStamp];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeGender] && [userAttributes objectForKey: mParticleUserAttributeGender] != [NSNull null]) {
            userInfo.gender = (NSString *)[userAttributes objectForKey: mParticleUserAttributeGender];
        }
        
        if ([userAttributes objectForKey: MPKitBlueshiftUserAttributesJoinedAt] && [userAttributes objectForKey: MPKitBlueshiftUserAttributesJoinedAt] != [NSNull null]) {
            NSTimeInterval joinedAtTimeStamp = [[userAttributes objectForKey: MPKitBlueshiftUserAttributesJoinedAt] doubleValue];
            userInfo.dateOfBirth = [NSDate dateWithTimeIntervalSinceReferenceDate:joinedAtTimeStamp];
        }
        
        if (userIdentities[@(MPUserIdentityFacebook)] && userIdentities[@(MPUserIdentityFacebook)] != [NSNull null]) {
            userInfo.facebookID = (NSString *) userIdentities[@(MPUserIdentityFacebook)];
        }
        
        if ([userAttributes objectForKey: MPKitBlueshiftUserAttributesEducation] && [userAttributes objectForKey: MPKitBlueshiftUserAttributesEducation] != [NSNull null]) {
            userInfo.education = (NSString *)[userAttributes objectForKey: MPKitBlueshiftUserAttributesEducation];
        }
        
        NSMutableDictionary *additionalInformation = [NSMutableDictionary dictionary];
        if ([userAttributes objectForKey: mParticleUserAttributeAge] && [userAttributes objectForKey: mParticleUserAttributeAge] != [NSNull null]) {
            [additionalInformation setObject: [userAttributes objectForKey: mParticleUserAttributeAge] forKey: MPKitBlueshiftUserAttributesAge];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeAddress] && [userAttributes objectForKey:mParticleUserAttributeAddress] != [NSNull null]) {
            [additionalInformation setObject:[userAttributes objectForKey:mParticleUserAttributeAddress] forKey: MPKitBlueshiftUserAttributesAddress];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeMobileNumber] && [userAttributes objectForKey: mParticleUserAttributeMobileNumber] != [NSNull null]) {
            [additionalInformation setObject:[userAttributes objectForKey: mParticleUserAttributeMobileNumber] forKey: MPKitBlueshiftUserAttributesMobile];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeCity] && [userAttributes objectForKey: mParticleUserAttributeCity] != [NSNull null]) {
            [additionalInformation setObject: [userAttributes objectForKey: mParticleUserAttributeCity] forKey: MPKitBlueshiftUserAttributesCity];
        }
    
        if ([userAttributes objectForKey: mParticleUserAttributeState] && [userAttributes objectForKey: mParticleUserAttributeState] != [NSNull null]) {
            [additionalInformation setObject: [userAttributes objectForKey: mParticleUserAttributeState] forKey: MPKitBlueshiftUserAttributesState];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeZip] && [userAttributes objectForKey: mParticleUserAttributeZip] != [NSNull null]) {
            [additionalInformation setObject: [userAttributes objectForKey: mParticleUserAttributeZip] forKey: MPKitBlueshiftUserAttributesZipCode];
        }
        
        if ([userAttributes objectForKey: mParticleUserAttributeCountry] && [userAttributes objectForKey: mParticleUserAttributeCountry] != [NSNull null]) {
            [additionalInformation setObject: [userAttributes objectForKey: mParticleUserAttributeCountry] forKey: MPKitBlueshiftUserAttributesCountry];
        }
        
        if (additionalInformation) {
            userInfo.additionalUserInfo = additionalInformation;
        }
        
        
        [userInfo save];

        if (userInfo.email) {
            [[BlueShift sharedInstance] identifyUserWithEmail:userInfo.email andDetails:@{} canBatchThisEvent:NO];
        }
    }
    
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (BOOL)willHandlePushMessage:(NSDictionary *)userinfo {
    BlueShiftConfig *config = [BlueShiftConfig config];
    if (config && !config.enablePushNotification) {
        return NO;
    }
    
    return userinfo && [userinfo objectForKey: BSFT_MESSAGE_UUID];
}

@end
