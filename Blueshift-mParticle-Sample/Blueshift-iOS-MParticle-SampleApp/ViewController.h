//
//  ViewController.h
//  Blueshift-iOS-MParticle-SampleApp
//
//  Created by Noufal on 13/04/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <mParticle-Apple-SDK/mParticle.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *kEmailField;
- (IBAction)onLoginButtonPressed:(id)sender;

@end

