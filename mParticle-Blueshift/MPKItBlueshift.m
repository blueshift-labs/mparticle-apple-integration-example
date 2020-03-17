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

@end
