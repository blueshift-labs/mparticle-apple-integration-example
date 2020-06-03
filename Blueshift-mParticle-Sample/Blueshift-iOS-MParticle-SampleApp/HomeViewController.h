//
//  HomeViewController.h
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 21/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mParticle-Apple-SDK/mParticle.h>

NS_ASSUME_NONNULL_BEGIN

@interface HomeViewController : UIViewController
- (IBAction)onLogEventPressed:(id)sender;
- (IBAction)onLogECommercePressed:(id)sender;
- (IBAction)onLogoutPressed:(id)sender;

@end

NS_ASSUME_NONNULL_END
