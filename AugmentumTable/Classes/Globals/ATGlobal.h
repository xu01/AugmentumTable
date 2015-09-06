//
//  ATGlobal.h
//  AugmentumTable
//
//  Created by xu lingyi on 9/6/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

//单例，存储例如scrollview的偏移量等
#import <Foundation/Foundation.h>

@interface ATGlobal : NSObject

@property (nonatomic, assign) CGPoint scrollViewOffset;

+ (ATGlobal *)shareGlobal;

@end
