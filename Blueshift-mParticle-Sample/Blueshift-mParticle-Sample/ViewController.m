//
//  ViewController.m
//  Blueshift-mParticle-Sample
//
//  Created by Rahul Raveendran on 01/05/20.
//  Copyright © 2020 Blueshift Labs Inc. All rights reserved.
//

#import "ViewController.h"
#import <MPKitBlueshift.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [MPKitBlueshift registerForInAppMessage:NSStringFromClass([ViewController class])];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [MPKitBlueshift unregisterForInAppMessage];
}

@end
