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
        
        /*UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake((110.0-[_tableItems[i][@"cols"] intValue]*kGridWidth)/2, (110.0-[_tableItems[i][@"rows"] intValue]*kGridWidth)/2, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth)];
        [itemView addSubview:dragView];
        BFDragGestureRecognizer *dragRecognizer = [[BFDragGestureRecognizer alloc] init];
        [dragRecognizer addTarget:self action:@selector(dragRecognized:)];
        [dragView addGestureRecognizer:dragRecognizer];
        UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth)];
        tableImage.contentMode = UIViewContentModeScaleAspectFit;
        tableImage.image = [UIImage imageNamed:_tableItems[i][@"image_default"]];
        [dragView addSubview:tableImage];*/
        
        [itemView addSubview:[self addDragView:i]];
        
        UILabel *tableName = [[UILabel alloc] initWithFrame:CGRectMake(7.5, 110, 110, 25)];
        tableName.text = _tableItems[i][@"name"];
        tableName.textAlignment = NSTextAlignmentCenter;
        tableName.font = [UIFont systemFontOfSize:15.0];
        [itemView addSubview:tableName];
        
        [self addSubview:itemView];
    }
}

- (UIView *)addDragView:(int)i {
    NSMutableArray *aFrames = [NSMutableArray array];
    for (int row=0; row<(kGridRows-([_tableItems[i][@"rows"] intValue]-1)); row++) {
        for (int col=0; col<(kGridColumns-([_tableItems[i][@"cols"] intValue]-1)); col++) {
            CGRect bFrame = CGRectMake(row*kGridWidth, col*kGridWidth, kGridWidth*[_tableItems[i][@"cols"] intValue], kGridWidth*[_tableItems[i][@"rows"] intValue]);
            
            [aFrames addObject:CGRectValue(bFrame)];
        }
    }
    
    CGRect frame = CGRectMake((110.0-[_tableItems[i][@"cols"] intValue]*kGridWidth)/2, (110.0-[_tableItems[i][@"rows"] intValue]*kGridWidth)/2, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth);
    
    ATDragView *dragView = [[ATDragView alloc] initWithFrame:frame withTableInfo:_tableItems[i] withTableViewCell:self withAllowFrames:aFrames withDelegate:nil];
    dragView.tag = i+1000;
    /*UIView *dragView = [[UIView alloc] initWithFrame:CGRectMake((110.0-[_tableItems[i][@"cols"] intValue]*kGridWidth)/2, (110.0-[_tableItems[i][@"rows"] intValue]*kGridWidth)/2, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth)];
    dragView.tag = i+1000;
    BFDragGestureRecognizer *dragRecognizer = [[BFDragGestureRecognizer alloc] init];
    [dragRecognizer addTarget:self action:@selector(dragRecognized:)];
    [dragView addGestureRecognizer:dragRecognizer];
    UIImageView *tableImage = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, [_tableItems[i][@"cols"] intValue]*kGridWidth, [_tableItems[i][@"rows"] intValue]*kGridWidth)];
    tableImage.contentMode = UIViewContentModeScaleAspectFit;
    tableImage.image = [UIImage imageNamed:_tableItems[i][@"image_default"]];
    [dragView addSubview:tableImage];*/
    
    return dragView;
}

- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // When the gesture starts, remember the current position.
        if ([view.superview.superview isKindOfClass:[ATLeftTableViewCell class]]) {
            [view.superview insertSubview:[self addDragView:(view.tag-1000)] belowSubview:view];
        }
        
        [[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:view];
        CGPoint translation = [recognizer translationInView:[UIApplication sharedApplication].delegate.window.rootViewController.view];
        //CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        CGPoint center = recognizer.frame.origin;
        NSLog(@"x:%f-y:%f",translation.x, translation.y);
        view.center = center;
        
        view.layer.borderColor = [[UIColor redColor] CGColor];
        view.layer.borderWidth = 1.0;
        _startCenter = view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // During the gesture, we just add the gesture's translation to the saved original position.
        // The translation will account for the changes in contentOffset caused by auto-scrolling.
        CGPoint translation = [recognizer translationInView:self];
        CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        view.center = center;
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        view.layer.borderWidth = 0.0;
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}


@end
