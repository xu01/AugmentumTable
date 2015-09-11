//
//  ATLeftTableViewCell.h
//  AugmentumTable
//
//  Created by xu lingyi on 8/27/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLeftTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *labTableType;
@property (strong, nonatomic) NSMutableArray *tableItems;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withDragViewDelegate:(id)drageViewDelegate;

- (void)buildTablesWithParent;

- (UIView *)addDragView:(int)i withDelegate:(id)delegate;

@end

