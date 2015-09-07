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
    
    BOOL            _isFirstMove;
}

- (instancetype)initWithFrame:(CGRect)frame
                withTableInfo:(NSDictionary *)tableInfo
            withTableViewCell:(ATLeftTableViewCell *)cell
      withVerticalAllowFrames:(NSArray *)allowVerticalFramesArray
    withHorizontalFramesArray:(NSArray *)allowHorizontalFramesArray
                 withDelegate:(id<ATDragViewDelegate>)delegate {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _currentGoodFrameIndex = -1;
        _tableInfo = [NSDictionary dictionaryWithDictionary:tableInfo];
        _cell = cell;
        _allowVerticalFramesArray = [NSArray arrayWithArray:allowVerticalFramesArray];
        _allowHorizontalFramesArray = [NSArray arrayWithArray:allowHorizontalFramesArray];
        _delegate = delegate;
        _isVertical = YES;
        
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
    NSArray *allowFramesArray;
    if (_isVertical) {
        allowFramesArray = [NSArray arrayWithArray:_allowVerticalFramesArray];
    } else {
        allowFramesArray = [NSArray arrayWithArray:_allowHorizontalFramesArray];
    }
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // When the gesture starts, remember the current position.
        if ([view.superview.superview isKindOfClass:[ATLeftTableViewCell class]]) {
            [view.superview insertSubview:[_cell addDragView:(self.tableNum) withDelegate:_delegate] belowSubview:view];
        }
        
        _isFirstMove = NO;
        if ([view isDescendantOfView:_cell]) {
            CGRect rc = [root.view convertRect:view.frame fromView:view.superview];
            [root.view addSubview:view];
            view.frame = rc;
            _isFirstMove = YES;
        }
        [self.superview bringSubviewToFront:self];
        
        view.layer.borderColor = [[UIColor redColor] CGColor];
        view.layer.borderWidth = 1.0;
        _startCenter = view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        SEL dragViewDidMoveDragging = @selector(dragViewDidMoveDragging:);
        
        if(_delegate && [(NSObject *)_delegate respondsToSelector:dragViewDidMoveDragging]){
            [_delegate dragViewDidMoveDragging:self];
        }
        
        CGPoint translation = [recognizer translationInView:self.superview.superview];
        CGPoint center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        view.center = center;
        NSInteger frameIndex;
        if (_isFirstMove) {
            if (view.center.x < kLeftViewWidth || view.center.y < (kNavigationHeight+kSubTitleHeight)) {
                frameIndex = -1;
            } else {
                frameIndex = [self goodFrameIndexNeedTrans:YES];
            }
        } else {
            frameIndex = [self goodFrameIndexNeedTrans:NO];
        }
        if (frameIndex >= 0) {
            _currentGoodFrameIndex = frameIndex;
        }
    } else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        view.layer.borderWidth = 0.0;
        
        if (_isFirstMove && _currentGoodFrameIndex < 0) {
            [[ATGlobal shareGlobal] removeTableById:self.tableId];
            [view removeFromSuperview];
            return;
        }
        
        SEL dragViewDidEndDragging = @selector(dragViewDidEndDragging:);
        
        if(_delegate && [(NSObject *)_delegate respondsToSelector:dragViewDidEndDragging]){
            [_delegate dragViewDidEndDragging:self];
        }
        
        if (_currentGoodFrameIndex >= 0) {
            view.frame = [[allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue];
            if ([[ATGlobal shareGlobal] checkRectIntersectById:_tableId ByRect:view.frame]) {
                self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_wrong"]];
            } else {
                self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
            }
            
            [[ATGlobal shareGlobal] saveTableDataWithId:_tableId withFrame:[allowFramesArray objectAtIndex:_currentGoodFrameIndex]];
            
        }
        
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}

- (NSInteger)goodFrameIndexNeedTrans:(BOOL)trans {
    NSInteger index = -1;
    CGPoint center;
    CGPoint origin;
    CGPoint offset = [ATGlobal shareGlobal].scrollViewOffset;
    NSArray *allowFramesArray;
    if (_isVertical) {
        allowFramesArray = [NSArray arrayWithArray:_allowVerticalFramesArray];
    } else {
        allowFramesArray = [NSArray arrayWithArray:_allowHorizontalFramesArray];
    }
    if (trans) {
        center = CGPointMake(self.center.x-kLeftViewWidth+offset.x, self.center.y-kNavigationHeight-kSubTitleHeight+offset.y);
        origin = CGPointMake(self.frame.origin.x-kLeftViewWidth+offset.x, self.frame.origin.y-kNavigationHeight-kSubTitleHeight+offset.y);
    } else {
        center = self.center;
        origin = self.frame.origin;
    }
    for (int i=0; i<[allowFramesArray count]; i++) {
        CGRect goodFrame = [[allowFramesArray objectAtIndex:i] CGRectValue];
        if (CGRectContainsPoint(goodFrame, center)) {
            //左上自动对齐
            if ((origin.x-goodFrame.origin.x) <= (kGridWidth/2) && 0 <= (origin.x-goodFrame.origin.x)
                && (origin.y-goodFrame.origin.y) <= (kGridWidth/2) && 0 <= (origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //右上自动对齐
            else if ((goodFrame.origin.x-origin.x) <= (kGridWidth/2) && 0 <= (goodFrame.origin.x-origin.x)
                     && (origin.y-goodFrame.origin.y) <= (kGridWidth/2) && 0 <= (origin.y-goodFrame.origin.y)) {
                index = i;
                break;
            }
            //左下自动对齐
            else if ((origin.x-goodFrame.origin.x) <= (kGridWidth/2) && 0 <= (origin.x-goodFrame.origin.x)
                     && (goodFrame.origin.y-self.frame.origin.y) <= (kGridWidth/2) && 0 <= (goodFrame.origin.y-self.frame.origin.y)) {
                index = i;
                break;
            }
            //右下自动对齐
            else if ((goodFrame.origin.x-origin.x) <= (kGridWidth/2) && 0 <= (goodFrame.origin.x-origin.x)
                     && (goodFrame.origin.y-origin.y) <= (kGridWidth/2) && 0 <= (goodFrame.origin.y-origin.y)) {
                index = i;
                break;
            }
        }
    }
    return index;
}

- (void)rotateLeft {
    CGPoint originCenter = self.center;
    NSLog(@"x:%f - y:%f", originCenter.x, originCenter.y);
    if (_isVertical) {
        _isVertical = NO;
    } else {
        _isVertical = YES;
    }
    
    CGAffineTransform transform = self.transform;
    transform = CGAffineTransformMakeRotation(M_PI/2);
    //self.layer.anchorPoint = CGPointMake(0.0, self.frame.size.height);
    //self.transform = CGAffineTransformIdentity;
    self.transform = transform;
    
    if (self.frame.size.width > self.frame.size.height) {
        self.center = CGPointMake(originCenter.x-self.frame.size.height/2-self.frame.size.width/2, originCenter.y-self.frame.size.height/2);
    } else if (self.frame.size.width < self.frame.size.height) {
        self.center = CGPointMake(originCenter.x+self.frame.size.height/2+self.frame.size.width/2, originCenter.y+self.frame.size.height);
    } else {
        self.center = originCenter;
    }
    
    NSArray *allowFramesArray;
    if (_isVertical) {
        allowFramesArray = [NSArray arrayWithArray:_allowVerticalFramesArray];
    } else {
        allowFramesArray = [NSArray arrayWithArray:_allowHorizontalFramesArray];
    }
    
    NSInteger frameIndex = [self goodFrameIndexNeedTrans:NO];
    if (frameIndex >= 0) {
        _currentGoodFrameIndex = frameIndex;
    }
    self.frame = [[allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue];
    if ([[ATGlobal shareGlobal] checkRectIntersectById:_tableId ByRect:self.frame]) {
        self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_wrong"]];
    } else {
        self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
    }
    
    [[ATGlobal shareGlobal] saveTableDataWithId:_tableId withFrame:[allowFramesArray objectAtIndex:_currentGoodFrameIndex]];
}

- (void)rotateRight {
    self.transform = CGAffineTransformIdentity;
}

@end
