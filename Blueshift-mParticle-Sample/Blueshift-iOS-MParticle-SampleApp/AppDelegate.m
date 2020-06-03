//
//  AppDelegate.m
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 13/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//


#import "AppDelegate.h"
#import <mParticle-Apple-SDK/mParticle.h>
#import <MPKitBlueshift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    BlueShiftConfig *config = [BlueShiftConfig config];
    [config setEnablePushNotification: YES];
    [config setEnableInAppNotification: YES];
    [config setUserNotificationDelegate:self];
    [config setInAppManualTriggerEnabled:NO];
    [config setInAppBackgroundFetchEnabled: YES];
    [config setAppGroupID:@"group.blueshift.reads"];
    [config setBlueshiftUniversalLinksDelegate:self];
    [MPKitBlueshift setBlueshiftConfig: config];
        
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"us1-34bc0b3011af0648a89d866dcd924501"
                                                              secret:@"YyPyRd38h1JdSEddjix7qcIJWDnYTTDDLMYL1SZvmn_wZnp77PirMUTK8tFO9x6u"];
        
    [[MParticle sharedInstance] startWithOptions:options];
        
    return YES;
}

- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options {
    NSLog(@"URL triggred");
    
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler {
    if ([userActivity.activityType isEqualToString: NSUserActivityTypeBrowsingWeb]) {
        NSURL *url = userActivity.webpageURL;
        [MPKitBlueshift handleBlueshiftUniversalLinksForURL:url];
    }
    return true;
}

//callback to indicate the start of processing of url
-(void)didStartLinkProcessing {
    //Show activity indicator
}

//Universal link will be received here on successful processing
-(void)didCompleteLinkProcessing:(NSURL *)url {
    //handle success by navigating to the respective screen and hide activity indicator
    [self showAlert:url];
}

//Error will be received here with unprocessed url on unsuccessful processing
-(void)didFailLinkProcessingWithError:(NSError *)error url:(NSURL *)url {
    //Handle failure and hide activity indicator
}

-(void)showAlert: (NSURL*)url {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Universal Link" message:url.absoluteString preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:cancel];
    UIAlertAction* open = [UIAlertAction actionWithTitle:@"Open in Safari" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
        });
    }];
    [alertController addAction:open];
    UIViewController *rootviewController = [[[UIApplication sharedApplication] delegate] window].rootViewController;
    [rootviewController presentViewController:alertController animated:YES completion:nil];
}

@end
