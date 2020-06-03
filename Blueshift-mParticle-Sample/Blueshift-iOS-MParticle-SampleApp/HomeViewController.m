//
//  HomeViewController.m
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 21/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import "HomeViewController.h"
#import <BlueShiftUserInfo.h>
#import "ViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Home";
    
    [self logScreen];
}

- (IBAction)onLogEventPressed:(id)sender {
    [self logEvent];
}

- (IBAction)onLogECommercePressed:(id)sender {
    [self logECommmerceEvent];
}

- (IBAction)onLogoutPressed:(id)sender {
    [BlueShiftUserInfo removeCurrentUserInfo];
    [self pushLoginPage];
}

- (void)logScreen {
    NSDictionary *screenInfo = @{@"rating":@"5",
                                 @"property_type":@"hotel"};

    [[MParticle sharedInstance] logScreen: NSStringFromClass([HomeViewController class])
                                eventInfo:screenInfo];
}

- (void)logEvent {
    MPEvent *event = [[MPEvent alloc] initWithName:@"MParticle Blueshift Event"
                                              type:MPEventTypeTransaction];
    event.customAttributes = @{@"category":@"Home Screen Event",
                   @"title":@"Paris"};
    [[MParticle sharedInstance] logEvent:event];
}

- (void)logECommmerceEvent {
    MPProduct *product = [[MPProduct alloc] initWithName:@"Double Room - Econ Rate"
                                                     sku:@"econ-1"
                                                quantity:@4
                                                   price:@100.00];

    // 2. Summarize the transaction
    MPTransactionAttributes *attributes = [[MPTransactionAttributes alloc] init];
    attributes.transactionId = @"foo-transaction-id";
    attributes.revenue = @430.00;
    attributes.tax = @30.00;

    // 3. Log the purchase event
    MPCommerceEventAction action = MPCommerceEventActionPurchase;
    MPCommerceEvent *event = [[MPCommerceEvent alloc] initWithAction:action
                                                             product:product];
    event.transactionAttributes = attributes;
    [[MParticle sharedInstance] logEvent:event];
}


- (void)pushLoginPage {
    
    ViewController *homeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"ViewController"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

@end
