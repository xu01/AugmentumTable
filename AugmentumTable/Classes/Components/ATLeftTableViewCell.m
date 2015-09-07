//
//  ATLeftTableViewCell.m
//  AugmentumTable
//
//  Created by xu lingyi on 8/27/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATLeftTableViewCell.h"
#import "ATDragView.h"

@implementation ATLeftTableViewCell
{
    CGPoint _startCenter;
}

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

- (void)buildTablesWithParent:(id)parent {
    for (int i=0; i<_tableItems.count; i++) {
        UIView *itemView = [[UIView alloc] init];
        if (i%2==0) {
            itemView.frame = CGRectMake(0.0, 40.0+135*(i/2), kLeftViewWidth/2, 135);
        } else {
            itemView.frame = CGRectMake(kLeftViewWidth/2, 40.0+135*(i/2), 145, 135);
        }
        
        [itemView addSubview:[self addDragView:i withDelegate:parent]];
        
        UILabel *tableName = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 110, 110, 25)];
        tableName.text = _tableItems[i][@"name"];
        tableName.textAlignment = NSTextAlignmentCenter;
        tableName.font = [UIFont systemFontOfSize:15.0];
        [itemView addSubview:tableName];
        
        [self addSubview:itemView];
    }
}

- (UIView *)addDragView:(int)i withDelegate:(id)delegate {
    NSMutableArray *aFrames = [NSMutableArray array];
    for (int row=0; row<(kGridRows-([_tableItems[i][@"rows"] intValue]-1)); row++) {
        for (int col=0; col<(kGridColumns-([_tableItems[i][@"cols"] intValue]-1)); col++) {
            CGRect bFrame = CGRectMake(row*kGridWidth, col*kGridWidth, kGridWidth*[_tableItems[i][@"cols"] intValue], kGridWidth*[_tableItems[i][@"rows"] intValue]);
            
            [aFrames addObject:CGRectValue(bFrame)];
        }
    }
    
    CGRect frame = CGRectMake((110.0-[_tableItems[i][@"cols"] intValue]*kGridWidth)/2, (110.0-[_tableItems[i][@"rows"] intValue]*kGridWidth)/2, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth);
    
    ATDragView *dragView = [[ATDragView alloc] initWithFrame:frame withTableInfo:_tableItems[i] withTableViewCell:self withAllowFrames:aFrames withDelegate:delegate];
    dragView.tableNum = i;
    dragView.tableId = [[ATGlobal shareGlobal] getTableId];
    
    [[ATGlobal shareGlobal] saveTableDataWithId:dragView.tableId withFrame:CGRectValue(CGRectZero)];
    
    return dragView;
}

@end
