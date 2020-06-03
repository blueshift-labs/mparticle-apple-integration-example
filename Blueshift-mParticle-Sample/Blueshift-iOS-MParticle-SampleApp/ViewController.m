//
//  ViewController.m
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 13/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import "ViewController.h"
#import "HomeViewController.h"
#import <BlueShiftUserInfo.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController popToRootViewControllerAnimated:NO];
    
    self.navigationItem.title = @"Blueshift MParticle";
    
    if ([[BlueShiftUserInfo sharedInstance] email] && [[BlueShiftUserInfo sharedInstance] email].length > 0) {
        [self pushHomePage];
    }
}


- (IBAction)onLoginButtonPressed:(id)sender {
    if ([self kEmailField]) {
        NSString *email = [self kEmailField].text;
        if (email.length <= 0) {
            [self showAlertMessage: @"Please Enter Valid "];
            return;
        }
        
        MPIdentityApiRequest *identityRequest = [MPIdentityApiRequest requestWithEmptyUser];
        identityRequest.email = email;
        
        [[[MParticle sharedInstance] identity] modify: identityRequest completion: NULL];
        
        [self kEmailField].text= @"";
        [self pushHomePage];
    }
}

- (void)pushHomePage {
    
    HomeViewController *homeViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:NULL] instantiateViewControllerWithIdentifier:@"HomeViewController"];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:homeViewController animated:YES];
}

- (void)showAlertMessage:(NSString *)message {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Warning"
                               message: message
                               preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction * action) {}];

    [alert addAction:defaultAction];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
