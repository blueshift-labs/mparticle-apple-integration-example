//
//  AppDelegate.m
//  Blueshift-mParticle-Sample
//
//  Created by Rahul Raveendran on 01/05/20.
//  Copyright © 2020 Blueshift Labs Inc. All rights reserved.
//

#import "AppDelegate.h"
#import <mParticle-Apple-SDK/mParticle.h>
#import <MPKitBlueshift.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // initialize Kit
    BlueShiftConfig *config = [BlueShiftConfig config];
    [config setEnableInAppNotification:YES];
    [config setInAppBackgroundFetchEnabled:YES];
    
    [MPKitBlueshift setBlueshiftConfig:config];
    
    // initialize mParticle
    MPIdentityApiRequest *identifyApiReq = [MPIdentityApiRequest requestWithEmptyUser];
    identifyApiReq.email = @"rahul.ios@mp.com";
    
    MParticleOptions *options = [MParticleOptions optionsWithKey:@"REPLACE WITH YOUR MPARTICLE API KEY"
                                                          secret:@"REPLACE WITH YOUR MPARTICLE API SECRET"];
    options.identifyRequest = identifyApiReq;
    
    [[MParticle sharedInstance] startWithOptions:options];
    
    return YES;
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Blueshift_mParticle_Sample"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                    */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

@end
