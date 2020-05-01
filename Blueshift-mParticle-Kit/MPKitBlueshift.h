//
//  MPKItBlueshift.h
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import <Foundation/Foundation.h>
#if defined(__has_include) && __has_include(<mParticle_Apple_SDK/mParticle.h>)
#import <mParticle_Apple_SDK/mParticle.h>
#else
#import "mParticle.h"
#endif

#if defined(__has_include) && __has_include(<BlueShift-iOS-SDK/BlueShift.h>)
    #import <BlueShift-iOS-SDK/BlueShift.h>
#else
    #import "BlueShift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MPKitBlueshift : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;

+ (void)setBlueshiftConfig:(BlueShiftConfig *)config;
+ (void)registerForInAppMessage:(NSString *)displayPage;
+ (void)unregisterForInAppMessage;
+ (void)fetchInAppNotificationFromAPI:(void (^_Nonnull)(void))success failure:(void (^)(NSError*))failure;
+ (void)displayInAppNotification;
+ (void)handleBlueshiftLink:(NSURL *)URL handler:(void (^)(NSURL *))handler;

@end

NS_ASSUME_NONNULL_END
