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
@property (strong, nonatomic) NSArray *allowFramesArray;

- (instancetype)initWithFrame:(CGRect)frame
                withTableInfo:(NSDictionary *)tableInfo
            withTableViewCell:(ATLeftTableViewCell *)cell
              withAllowFrames:(NSArray *)allowFramesArray
                 withDelegate:(id<ATDragViewDelegate>)delegate;

@end

@protocol ATDragViewDelegate <NSObject>

/* 移动开始 */
- (void)dragViewDidStartDragging:(ATDragView *)dragView;
/* 移动之中 */
- (void)dragViewDidMoveDragging:(ATDragView *)dragView;
/* 移动结束 */
- (void)dragViewDidEndDragging:(ATDragView *)dragView;

@end