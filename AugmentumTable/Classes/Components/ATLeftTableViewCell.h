//
//  ATLeftTableViewCell.h
//  AugmentumTable
//
//  Created by xu lingyi on 8/27/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ATLeftTableViewCell : UITableViewCell

@property (strong, nonatomic) UILabel *tableType;
@property (strong, nonatomic) NSMutableArray *tableItems;

- (void)buildTables;

@end
