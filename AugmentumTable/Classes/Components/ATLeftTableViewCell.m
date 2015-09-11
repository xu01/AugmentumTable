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
        UIView *topLine = [[UIView alloc] init];
        topLine.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
        [self addSubview:topLine];
        
        UIView *iconView = [[UIView alloc] init];
        iconView.backgroundColor = [UIColor colorWithHexString:@"#FFBA00"];
        [self addSubview:iconView];
        
        _labTableType = [[UILabel alloc] init];
        _labTableType.textAlignment = NSTextAlignmentLeft;
        _labTableType.font = [UIFont systemFontOfSize:15.0];
        _labTableType.textColor = [UIColor blackColor];
        [self addSubview:_labTableType];
        
        UIView *centerLine = [[UIView alloc] init];
        centerLine.backgroundColor = [UIColor colorWithHexString:@"#DDDDDD"];
        [self addSubview:centerLine];
        
        WS(ws);
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws.mas_left);
            make.top.equalTo(ws.mas_top);
            make.width.equalTo(ws.mas_width);
            make.height.mas_equalTo(@1.0);
        }];
        
        [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws.mas_left).offset(10.0);
            make.top.equalTo(ws.mas_top).offset(12.0);
            make.width.mas_equalTo(@5.0);
            make.height.mas_equalTo(@16.0);
        }];
        
        [_labTableType mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(iconView.mas_right).offset(15.0);
            make.top.equalTo(ws.mas_top);
            make.width.mas_equalTo(@150.0);
            make.height.mas_equalTo(@40.0);
        }];
        
        [centerLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(ws.mas_left);
            make.top.equalTo(ws.mas_top).offset(40.0);
            make.width.equalTo(ws.mas_width);
            make.height.equalTo(@1.0);
        }];
        
        _tableItems = [NSMutableArray array];
    }
    return self;
}

- (void)buildTablesWithParent:(id)parent {
    WS(ws);
    for (int i=0; i<_tableItems.count; i++) {
        UIView *itemView = [[UIView alloc] init];
        [self addSubview:itemView];
        
        [itemView addSubview:[self addDragView:i withDelegate:parent]];
        
        UILabel *tableName = [[UILabel alloc] init];
        tableName.text = _tableItems[i][@"name"];
        tableName.textAlignment = NSTextAlignmentCenter;
        tableName.font = [UIFont systemFontOfSize:15.0];
        [itemView addSubview:tableName];
        
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(ws.mas_top).offset(40.0+135.0*(i/2));
            if (i%2 == 0) {
                make.left.equalTo(ws.mas_left);
            } else {
                make.left.equalTo(ws.mas_centerX);
            }
            make.width.equalTo(ws.mas_width).dividedBy(0.5);
            make.height.mas_equalTo(@135.0);
        }];
        
        [tableName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(@5.0);
            make.top.equalTo(itemView.mas_top).offset(110.0);
            make.width.mas_equalTo(@110.0);
            make.height.mas_equalTo(@25.0);
        }];
    }
}

- (UIView *)addDragView:(int)i withDelegate:(id)delegate {
    NSMutableArray *vFrames = [NSMutableArray array];
    for (int row=0; row<(kGridRows-([_tableItems[i][@"rows"] intValue]-1)); row++) {
        for (int col=0; col<(kGridColumns-([_tableItems[i][@"cols"] intValue]-1)); col++) {
            CGRect bFrame = CGRectMake(row*kGridWidth, col*kGridWidth, kGridWidth*[_tableItems[i][@"cols"] intValue], kGridWidth*[_tableItems[i][@"rows"] intValue]);
            
            [vFrames addObject:CGRectValue(bFrame)];
        }
    }
    
    NSMutableArray *hFrames = [NSMutableArray array];
    for (int row=0; row<(kGridRows-([_tableItems[i][@"cols"] intValue]-1)); row++) {
        for (int col=0; col<(kGridColumns-([_tableItems[i][@"rows"] intValue]-1)); col++) {
            CGRect bFrame = CGRectMake(row*kGridWidth, col*kGridWidth, kGridWidth*[_tableItems[i][@"rows"] intValue], kGridWidth*[_tableItems[i][@"cols"] intValue]);
            
            [hFrames addObject:CGRectValue(bFrame)];
        }
    }
    
    CGRect frame = CGRectMake((110.0-[_tableItems[i][@"cols"] intValue]*kGridWidth)/2, (110.0-[_tableItems[i][@"rows"] intValue]*kGridWidth)/2, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth);
    
    ATDragView *dragView = [[ATDragView alloc] initWithFrame:frame withTableInfo:_tableItems[i] withTableViewCell:self withVerticalAllowFrames:vFrames withHorizontalFramesArray:hFrames withDelegate:delegate];
    dragView.tableDataId = i;
    dragView.tableId = [[ATGlobal shareGlobal] getTableId];
    
    [[ATGlobal shareGlobal] saveTableDataWithId:dragView.tableId withFrame:CGRectValue(CGRectZero)];
    
    return dragView;
}

@end
