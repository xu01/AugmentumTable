//
//  ATLeftTableViewCell.m
//  AugmentumTable
//
//  Created by user on 8/27/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATLeftTableViewCell.h"

@implementation ATLeftTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        /* 桌子分类 */
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, kLeftViewWidth, kLineHeight)];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
        [self addSubview:topLine];
        
        UIView *sView = [[UIView alloc] initWithFrame:CGRectMake(10.0, 12.0, 5.0, 16.0)];
        sView.backgroundColor = [UIColor colorWithHexString:@"#FFBA00"];
        [self addSubview:sView];
        
        _tableType = [[UILabel alloc] initWithFrame:CGRectMake(25.0, 0.0, kLeftViewWidth-50.0, 40.0)];
        _tableType.textAlignment = NSTextAlignmentLeft;
        _tableType.font = [UIFont systemFontOfSize:15.0];
        _tableType.textColor = [UIColor blackColor];
        [self addSubview:_tableType];
        
        UIView *centerLine = [[UIView alloc] initWithFrame:CGRectMake(0.0, 40.0, kLeftViewWidth, kLineHeight)];
        centerLine.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
        [self addSubview:centerLine];
        
        _tableItems = [NSMutableArray array];
    }
    return self;
}

- (void)buildTables {
    for (int i=0; i<_tableItems.count; i++) {
        UIView *itemView = [[UIView alloc] init];
        if (i%2==0) {
            itemView.frame = CGRectMake(0.0, 40.0+135*(i/2), kLeftViewWidth/2, 135);
            itemView.backgroundColor = [UIColor redColor];
        } else {
            itemView.frame = CGRectMake(kLeftViewWidth/2, 40.0+135*(i/2), 145, 135);
            itemView.backgroundColor = [UIColor blueColor];
        }
        [self addSubview:itemView];
    }
}

@end
