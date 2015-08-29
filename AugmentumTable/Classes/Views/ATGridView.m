//
//  ATGridView.m
//  AugmentumTable
//
//  Created by xu lingyi on 8/29/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATGridView.h"

@implementation ATGridView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithHexString:@"#F0F0F0"];
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    int width = rect.size.width ;
    int height = rect.size.height ;
    
    int i = 0 ;
    
    [[UIColor colorWithHexString:@"#DDDDDD"] setStroke];
    
    UIBezierPath *drawingPath = [UIBezierPath bezierPath];
    
    for( i = 0 ; i <= width ; i=i+20 ) {
        [drawingPath moveToPoint:CGPointMake(i, 0)];
        [drawingPath addLineToPoint:CGPointMake(i, height)];
    } // the horizontal lines
    for( i = 0 ; i <= height ; i=i+20 ) {
        [drawingPath moveToPoint:CGPointMake(0,i)];
        [drawingPath addLineToPoint:CGPointMake(width, i)];
    } // actually draw the grid
    [drawingPath stroke];
}

@end
