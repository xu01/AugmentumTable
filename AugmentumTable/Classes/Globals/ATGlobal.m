//
//  ATGlobal.m
//  AugmentumTable
//
//  Created by xu lingyi on 9/6/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATGlobal.h"

static ATGlobal *kGlobalInstance = nil;

@implementation ATGlobal

+ (ATGlobal *)shareGlobal {
    if (kGlobalInstance == nil) {
        kGlobalInstance = [[ATGlobal alloc] init];
    }
    return kGlobalInstance;
}

@end
