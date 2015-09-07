//
//  ATGlobal.h
//  AugmentumTable
//
//  Created by xu lingyi on 9/6/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

//单例，存储例如scrollview的偏移量等
#import <Foundation/Foundation.h>
#import "ATDragView.h"

@interface ATGlobal : NSObject

@property (nonatomic, assign) CGPoint scrollViewOffset;     //scrollview 偏移量

@property (nonatomic, strong) NSMutableDictionary *tableData;    //已拖动的table 数据

+ (ATGlobal *)shareGlobal;

- (int)getTableId; //获取table Id

- (void)saveTableDataWithId:(int)tableId withFrame:(NSValue *)rectValue;
- (CGRect)getTableRectDataById:(int)tableId;
- (BOOL)checkRectIntersectById:(int)tableId ByRect:(CGRect)rect;
- (void)removeTableById:(int)tableId;

@end
