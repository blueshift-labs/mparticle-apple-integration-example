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

#if defined(__has_include) && __has_include(<Appboy-iOS-SDK/AppboyKit.h>)
    #import <BlueShift-iOS-SDK/BlueShift.h>
#elif defined(__has_include) && __has_include(<Appboy_iOS_SDK/AppboyKit.h>)
    #import <BlueShift_iOS_SDK/BlueShift.h>
#else
    #import "BlueShift.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface MPKItBlueshift : NSObject <MPKitProtocol>

@property (nonatomic, strong, nonnull) NSDictionary *configuration;
@property (nonatomic, strong, nullable) NSDictionary *launchOptions;
@property (nonatomic, unsafe_unretained, readonly) BOOL started;

+ (void)setInAppMessageControllerDelegate:(id)delegate;
+ (void)setPushNotificationControllerDelegate:(id)delegate;
- (void)initializeBlueshiftConfig:(NSDictionary *)configDictionary;
- (void)registerForInAppMessage:(NSString *)displayPage;
- (void)unregisterForInAppMessage;
- (void)fetchInAppNotificationFromAPI:(void (^_Nonnull)(void))success failure:(void (^)(NSError*))failure;
- (void)displayInAppNotification;

@end

NS_ASSUME_NONNULL_END
