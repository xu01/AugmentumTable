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

- (instancetype)init {
    if (self = [super init]) {
        _tableData = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+ (ATGlobal *)shareGlobal {
    if (kGlobalInstance == nil) {
        kGlobalInstance = [[ATGlobal alloc] init];
    }
    return kGlobalInstance;
}

- (int)getTableId {
    NSArray *allTableIds = [_tableData allKeys];
    int max = [[allTableIds valueForKeyPath:@"@max.intValue"] intValue];
    return (max+1);
}

- (void)saveTableDataWithId:(int)tableId withFrame:(NSValue *)rectValue {
    NSString *strTableId = [NSString stringWithFormat:@"%d", tableId];
    _tableData[strTableId] = rectValue;
}

- (CGRect)getTableRectDataById:(int)tableId {
    NSString *strTableId = [NSString stringWithFormat:@"%d", tableId];
    return CGRectFromValue(_tableData[strTableId]);
}

- (BOOL)checkRectIntersectById:(int)tableId ByRect:(CGRect)rect {
    NSArray *allTablesIds = [_tableData allKeys];
    NSArray *allTablesRect = [_tableData allValues];
    for (int i=0; i<allTablesIds.count; i++) {
        if (tableId != [allTablesIds[i] intValue] && !CGRectEqualToRect(CGRectFromValue(allTablesRect[i]), CGRectZero) && CGRectIntersectsRect(CGRectFromValue(allTablesRect[i]), rect)) {
            return YES;
        }
    }
    return NO;
}

- (void)removeTableById:(int)tableId {
    NSString *strTableId = [NSString stringWithFormat:@"%d", tableId];
    [_tableData removeObjectForKey:strTableId];
}

@end
