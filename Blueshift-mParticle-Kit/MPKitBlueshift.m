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

NSString *const MPKitBlueshiftShouldLogMPEvents = @"blueshift_should_log_mp_events";
NSString *const MPKitBlueshiftShouldLogCommerceEvents = @"blueshift_should_log_commerce_events";
NSString *const MPKitBlueshiftShouldLogUserEvents = @"blueshift_should_log_user_events";
NSString *const MPKitBlueshiftShouldLogScreenViewEvents = @"blueshift_should_log_screen_view_events";

NSString *const BSFT_MESSAGE_UUID =@"bsft_message_uuid";

static BlueShiftConfig *blueshiftConfig = nil;
static BOOL shouldLogMPEvents = NO;
static BOOL shouldLogCommerceEvents= NO;
static BOOL shouldLogScreenViewEvents = NO;
static BOOL shouldLogUserEvents = YES;

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

+ (BOOL)isBlueshiftUniversalLinkURL:(NSURL *)URL {
    return [[BlueShift sharedInstance] isBlueshiftUniversalLinkURL:URL];
}

+ (void)handleBlueshiftUniversalLinksForURL:(NSURL *)URL {
    [[[BlueShift sharedInstance] appDelegate] handleBlueshiftUniversalLinksForURL:URL];
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
    shouldLogMPEvents = [self getSettingValueFrom:configuration defaultValue:NO forKey:MPKitBlueshiftShouldLogMPEvents];
    shouldLogCommerceEvents = [self getSettingValueFrom:configuration defaultValue:NO forKey:MPKitBlueshiftShouldLogCommerceEvents];
    shouldLogScreenViewEvents = [self getSettingValueFrom:configuration defaultValue:NO forKey:MPKitBlueshiftShouldLogScreenViewEvents];
    shouldLogUserEvents = [self getSettingValueFrom:configuration defaultValue:YES forKey:MPKitBlueshiftShouldLogUserEvents];

    [self logConfigurationDetailsForEvent:@"MP" status:shouldLogMPEvents key:MPKitBlueshiftShouldLogMPEvents];
    [self logConfigurationDetailsForEvent:@"Commerce" status:shouldLogCommerceEvents key:MPKitBlueshiftShouldLogCommerceEvents];
    [self logConfigurationDetailsForEvent:@"Identify" status:shouldLogUserEvents key:MPKitBlueshiftShouldLogUserEvents];
    [self logConfigurationDetailsForEvent:@"ScreenView" status:shouldLogScreenViewEvents key:MPKitBlueshiftShouldLogScreenViewEvents];
    
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
        
        [BlueShift initWithConfiguration:config];
        
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
    if (shouldLogMPEvents) {
        [[BlueShift sharedInstance] trackEventForEventName: event.name andParameters: event.customAttributes canBatchThisEvent: NO];
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)routeCommerceEvent:(MPCommerceEvent *)commerceEvent {
    MPKitExecStatus *execStatus = [[MPKitExecStatus alloc] initWithSDKCode:@(MPKitInstanceBlueshift) returnCode:MPKitReturnCodeSuccess forwardCount:0];
    if (shouldLogCommerceEvents) {
        if (commerceEvent.action == MPCommerceEventActionPurchase) {
            [[BlueShift sharedInstance] trackEventForEventName: kEventPurchase andParameters: commerceEvent.customAttributes canBatchThisEvent: NO];
        } else {
            NSArray *expandedInstructions = [commerceEvent expandedInstructions];
            
            for (MPCommerceEventInstruction *commerceEventInstruction in expandedInstructions) {
                [self logBaseEvent:commerceEventInstruction.event];
                [execStatus incrementForwardCount];
            }
        }
    }
    return execStatus;
}

- (MPKitExecStatus *)logScreen:(MPEvent *)event {
    if (shouldLogScreenViewEvents) {
        NSMutableDictionary *customAttributes = [NSMutableDictionary dictionary];
        [customAttributes setObject:event.name forKey: MPKitBlueshiftScreenViewed];
        
        if (event.customAttributes) {
            [customAttributes addEntriesFromDictionary: event.customAttributes];
        }
        
        [[BlueShift sharedInstance] trackEventForEventName:kEventPageLoad andParameters: customAttributes canBatchThisEvent:NO];
    }
    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)updateUser:(FilteredMParticleUser *)user {
    if (user) {
        BlueShiftUserInfo *userInfo = [BlueShiftUserInfo sharedInstance];
        NSDictionary *userIdentities = [user.userIdentities copy];
        
        if (userIdentities[@(MPUserIdentityCustomerId)] && userIdentities[@(MPUserIdentityCustomerId)] != [NSNull null]) {
            userInfo.retailerCustomerID = (NSString *) userIdentities[@(MPUserIdentityCustomerId)];
        }
        
        if (userIdentities[@(MPUserIdentityEmail)] && userIdentities[@(MPUserIdentityEmail)] != [NSNull null]) {
            userInfo.email = (NSString *) userIdentities[@(MPUserIdentityEmail)];
        }

        [userInfo save];
        
        if (userInfo.email && shouldLogUserEvents) {
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

- (BOOL)getSettingValueFrom:(NSDictionary *)configuration defaultValue:(BOOL)defaultValue forKey:(NSString *) key {
    if (configuration != nil && configuration[key] != nil) {
        @try {
            NSString* value = configuration[key];
            return [value boolValue];
        }@catch (NSException *exception) {
            [self debugLog:exception.description];
        }
    }
    return defaultValue;
}

-(void)debugLog:(NSString *) errorString{
    #ifdef DEBUG
    NSLog(@"[Blueshift MPKIT] - %@", errorString);
    #endif
}

-(void)logConfigurationDetailsForEvent: (NSString*)eventName status: (BOOL)status key: (NSString*)key {
    NSString* disabledString = [NSString stringWithFormat:@"disabled! To Enable, set \"%@=true\" in settings.", key];
    NSString* logDescription = [NSString stringWithFormat: @"Sending \"%@ Events\" directly to Blueshift %@ ",eventName, (status ? @"enabled." : disabledString)];
    [self debugLog:logDescription];
}

@end
