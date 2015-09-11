//
//  ATDragView.h
//  AugmentumTable
//
//  Created by xu lingyi on 8/29/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ATLeftTableViewCell.h"

// CGRect to NSValue
NSValue *CGRectValue(CGRect rect);
// NSValue to CGRect
CGRect CGRectFromValue(NSValue *value);

@protocol ATDragViewDelegate;

@interface ATDragView : UIView

@property (strong, nonatomic) NSDictionary *tableInfo;
@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) ATLeftTableViewCell *cell;
@property (assign, nonatomic) id<ATDragViewDelegate> delegate;
@property (strong, nonatomic) NSArray *allowOriginalDirectionFramesArray;
@property (strong, nonatomic) NSArray *allowRotateDirectionFramesArray;

@property (strong, nonatomic) UILabel *labTableName;                //桌子名称

@property (assign, nonatomic) int tableDataId;                      //桌子数据编号
@property (assign, nonatomic) int tableId;                          //桌子编号

@property (assign, nonatomic) BOOL isOriginalDirection;             //当前是否是竖着的
@property (assign, nonatomic) BOOL isEditing;                       //是否处于编辑状态
@property (assign, nonatomic) BOOL isAtErrorPosition;               //是否处于错误的位置
@property (assign, nonatomic) BOOL isMoving;                        //是否正在移动

@property (strong, nonatomic) UIImageView *suggestView;             //移动提示框

- (instancetype)initWithFrame:(CGRect)frame
                withTableInfo:(NSDictionary *)tableInfo
            withTableViewCell:(ATLeftTableViewCell *)cell
withOriginDirectionAllowFrames:(NSArray *)allowOriginalDirectionFramesArray
withRotateDirectionFramesArray:(NSArray *)allowRotateDirectionFramesArray
                 withDelegate:(id<ATDragViewDelegate>)delegate;

- (void)rotateLeft;
- (void)rotateRight;

@end

@protocol ATDragViewDelegate <NSObject>

/* 移动开始 */
- (void)dragViewDidStartDragging:(ATDragView *)dragView;
/* 移动之中 */
- (void)dragViewDidMoveDragging:(ATDragView *)dragView;
/* 移动结束 */
- (void)dragViewDidEndDragging:(ATDragView *)dragView;

@end