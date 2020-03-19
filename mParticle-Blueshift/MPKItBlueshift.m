//
//  MPKItBlueshift.m
//  Blueshift-mParticle-Kit
//
//  Created by Noufal on 17/03/20.
//  Copyright © 2020 Noufal. All rights reserved.
//

#import "MPKItBlueshift.h"

@implementation MPKItBlueshift

+ (NSNumber *)kitCode {
    return @123;
}

+ (void)load {
    MPKitRegister *kitRegister = [[MPKitRegister alloc] initWithName:@"Blueshift" className:@"MPKItBlueshift"];
    [MParticle registerExtension:kitRegister];
}

- (MPKitExecStatus *)didFinishLaunchingWithConfiguration:(NSDictionary *)configuration {
    NSString *apiKey = configuration[@"<dictionary key to retrieve API Key>"];
    if (!apiKey) {
        return [self execStatus:MPKitReturnCodeRequirementsNotMet];
    }

    _configuration = configuration;

    [self start];

    return [self execStatus:MPKitReturnCodeSuccess];
}

- (MPKitExecStatus *)execStatus:(MPKitReturnCode)returnCode {
    return [[MPKitExecStatus alloc] initWithSDKCode:self.class.kitCode returnCode:returnCode];
}

@end
