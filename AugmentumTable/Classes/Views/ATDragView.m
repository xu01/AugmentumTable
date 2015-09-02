//
//  ATDragView.m
//  AugmentumTable
//
//  Created by xu lingyi on 8/29/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATDragView.h"
#import "ATMainViewController.h"

NSValue *CGRectValue(CGRect rect){
    return [NSValue valueWithCGRect:rect];
}
CGRect CGRectFromValue(NSValue *value){
    return [value CGRectValue];
}

@implementation ATDragView
{
    CGPoint         _startCenter;
    NSInteger       _currentGoodFrameIndex;
}

- (instancetype)initWithFrame:(CGRect)frame
                withTableInfo:(NSDictionary *)tableInfo
            withTableViewCell:(ATLeftTableViewCell *)cell
              withAllowFrames:(NSArray *)allowFramesArray
                 withDelegate:(id<ATDragViewDelegate>)delegate {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        _tableInfo = [NSDictionary dictionaryWithDictionary:tableInfo];
        _cell = cell;
        _allowFramesArray = [NSArray arrayWithArray:allowFramesArray];
        _delegate = delegate;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        [_imageView setAutoresizingMask:(UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight)];
        [_imageView setImage:[UIImage imageNamed:_tableInfo[@"image_default"]]];
        BFDragGestureRecognizer *dragRecognizer = [[BFDragGestureRecognizer alloc] init];
        [dragRecognizer addTarget:self action:@selector(dragRecognized:)];
        [self addGestureRecognizer:dragRecognizer];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_imageView];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}


- (void)dragRecognized:(BFDragGestureRecognizer *)recognizer {
    UIView *view = recognizer.view;
    ATMainViewController *root = (ATMainViewController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // When the gesture starts, remember the current position.
        if ([view.superview.superview isKindOfClass:[ATLeftTableViewCell class]]) {
            [view.superview insertSubview:[_cell addDragView:(view.tag-1000) withDelegate:_delegate] belowSubview:view];
        }
        
        [root.view addSubview:view];
        CGPoint center = [recognizer locationInView:root.view];
        view.center = center;
        //[[UIApplication sharedApplication].delegate.window.rootViewController.view addSubview:view];
        //CGPoint center = CGPointMake(100,100);
        //view.center = center;
        
        //CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        //CGPoint center = recognizer.frame.origin;
        //NSLog(@"x:%f-y:%f",translation.x, translation.y);
        //view.center = center;
        
        view.layer.borderColor = [[UIColor redColor] CGColor];
        view.layer.borderWidth = 1.0;
        _startCenter = view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        // During the gesture, we just add the gesture's translation to the saved original position.
        // The translation will account for the changes in contentOffset caused by auto-scrolling.
        SEL dragViewDidMoveDragging = @selector(dragViewDidMoveDragging:);
        
        if(_delegate && [(NSObject *)_delegate respondsToSelector:dragViewDidMoveDragging]){
            [_delegate dragViewDidMoveDragging:self];
        }
        
        CGPoint translation = [recognizer translationInView:self];
        CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        view.center = center;
        
        NSInteger frameIndex = [self goodFrameIndex];
        if (frameIndex >= 0) {
            _currentGoodFrameIndex = frameIndex;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        view.layer.borderWidth = 0.0;
        
        //CGPoint selfOrigin = [view convertPoint:view.frame.origin toView:rootView];
        if (view.center.x < kLeftViewWidth || view.center.y < (kNavigationHeight+kSubTitleHeight)) {
            [view removeFromSuperview];
        }
        
        SEL dragViewDidEndDragging = @selector(dragViewDidEndDragging:);
        
        if(_delegate && [(NSObject *)_delegate respondsToSelector:dragViewDidEndDragging]){
            [_delegate dragViewDidEndDragging:self];
        }
        //NSLog(@"good:%d", _currentGoodFrameIndex);
        view.frame = [[_allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue];
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}

- (NSInteger)goodFrameIndex {
    
    NSInteger index = -1;
    //CGPoint touchInSuperview = [self convertPoint:point toView:[self superview]];
    CGPoint center = self.center;
    
    for (int i=0; i<[_allowFramesArray count]; i++) {
        CGRect goodFrame = [[_allowFramesArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(goodFrame, center)) {
            //左上自动对齐
            if ((self.frame.origin.x-goodFrame.origin.x) <= (kGridWidth/2) && 0 <= (self.frame.origin.x-goodFrame.origin.x)
                && (self.frame.origin.y-goodFrame.origin.y) <= (kGridWidth/2) && 0 <= (self.frame.origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //右上自动对齐
            else if ((goodFrame.origin.x-self.frame.origin.x) <= (kGridWidth/2) && 0 <= (goodFrame.origin.x-self.frame.origin.x)
                     && (self.frame.origin.y-goodFrame.origin.y) <= (kGridWidth/2) && 0 <= (self.frame.origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //左下自动对齐
            else if ((self.frame.origin.x-goodFrame.origin.x) <= (kGridWidth/2) && 0 <= (self.frame.origin.x-goodFrame.origin.x)
                     && (goodFrame.origin.y-self.frame.origin.y) <= (kGridWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
                index = i;
                break;
            }
            //右下自动对齐
            else if ((goodFrame.origin.x-self.frame.origin.x) <= (kGridWidth/2) && 0 <= (goodFrame.origin.x-self.frame.origin.x)
                     && (goodFrame.origin.y-self.frame.origin.y) <= (kGridWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
                index = i;
                break;
            }
        }
    }
    return index;
}

@end
