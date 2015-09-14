//
//  ATDragView.m
//  AugmentumTable
//
//  Created by xu lingyi on 8/29/15.
//  Copyright (c) 2015 xu01. All rights reserved.
//

#import "ATDragView.h"
#import "ATMainViewController.h"

NSValue *CGRectValue(CGRect rect) {
    return [NSValue valueWithCGRect:rect];
}
CGRect CGRectFromValue(NSValue *value) {
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
withOriginDirectionAllowFrames:(NSArray *)allowOriginalDirectionFramesArray
withRotateDirectionFramesArray:(NSArray *)allowRotateDirectionFramesArray
                 withDelegate:(id<ATDragViewDelegate>)delegate {
    
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _currentGoodFrameIndex = -1;
        _tableInfo = [NSDictionary dictionaryWithDictionary:tableInfo];
        _cell = cell;
        _allowOriginalDirectionFramesArray = [NSArray arrayWithArray:allowOriginalDirectionFramesArray];
        _allowRotateDirectionFramesArray = [NSArray arrayWithArray:allowRotateDirectionFramesArray];
        _delegate = delegate;
        _isOriginalDirection = YES;
        _isEditing = NO;
        _isAtErrorPosition = NO;
        _isFirstMove = YES;
        
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeCenter;
        [_imageView setImage:[UIImage imageNamed:_tableInfo[@"image_default"]]];
        BFDragGestureRecognizer *dragRecognizer = [[BFDragGestureRecognizer alloc] init];
        dragRecognizer.minimumPressDuration = 0.5;
        [dragRecognizer addTarget:self action:@selector(dragRecognized:)];
        [self addGestureRecognizer:dragRecognizer];
        [self addSubview:_imageView];
        
        _labTableName = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        _labTableName.textAlignment = NSTextAlignmentCenter;
        _labTableName.textColor = [UIColor whiteColor];
        _labTableName.font = [UIFont systemFontOfSize:12.0];
        [self addSubview:_labTableName];
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
    NSArray *allowFramesArray = [self getCurrentAllowFrames];
    CGFloat zoomScale = [ATGlobal shareGlobal].scrollViewZoomScale;
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        // When the gesture starts, remember the current position.
        if (_isFirstMove) {
            [view.superview insertSubview:[_cell addDragView:(self.tableDataId) withDelegate:_delegate] belowSubview:view];
            CGRect rc = [root.view convertRect:view.frame fromView:view.superview];
            [root.view addSubview:view];
            view.frame = rc;
        }
        
        [self.superview bringSubviewToFront:self];
        
        if ([[ATGlobal shareGlobal] checkRectIntersectById:_tableId ByRect:view.frame]) {
            self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_wrong"]];
        } else {
            self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
        }
        
        _startCenter = view.center;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self.superview.superview];
        CGPoint center;
        if (_isFirstMove) {
            center = CGPointMake(_startCenter.x + translation.x, _startCenter.y + translation.y);
        } else {
            center = CGPointMake(_startCenter.x + translation.x/zoomScale, _startCenter.y + translation.y/zoomScale);
        }
        
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
            
           
            UIImage *suggestImage;
            if ([[ATGlobal shareGlobal] checkRectIntersectById:_tableId ByRect:[[allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue]]) {
                suggestImage = [UIImage imageNamed:@"table_bg_red"];
                self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_wrong"]];
            } else {
                suggestImage = [UIImage imageNamed:@"table_bg_green"];
                self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
            }
            UIImageView *suggestView = [[UIImageView alloc] initWithFrame:[[allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue]];
            suggestView.image = [suggestImage stretchableImageWithLeftCapWidth:1.0 topCapHeight:1.0];
            _suggestView = suggestView;
        }
        
        SEL dragViewDidMoveDragging = @selector(dragViewDidMoveDragging:);
        
        if(_delegate && [(NSObject *)_delegate respondsToSelector:dragViewDidMoveDragging]){
            [_delegate dragViewDidMoveDragging:self];
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
                //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_red"]];
                _isAtErrorPosition = YES;
            } else {
                self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
                self.backgroundColor = [UIColor clearColor];
                _isAtErrorPosition = NO;
            }
            
            [[ATGlobal shareGlobal] saveTableDataWithId:_tableId withFrame:[allowFramesArray objectAtIndex:_currentGoodFrameIndex]];
            
            if (_isEditing) {
                //self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"table_bg_green"]];
                self.layer.borderWidth = 1.0;
                self.layer.borderColor = [[UIColor colorWithHexString:@"#79C23B"] CGColor];
            }
        }
        
        _isFirstMove = NO;
    } else if (recognizer.state == UIGestureRecognizerStateFailed) {
        
    }
}

- (NSInteger)goodFrameIndexNeedTrans:(BOOL)trans {
    NSInteger index = -1;
    CGPoint center;
    CGPoint origin;
    CGPoint offset = [ATGlobal shareGlobal].scrollViewOffset;
    NSArray *allowFramesArray = [self getCurrentAllowFrames];
    if (trans) {
        CGFloat zoomScale = [ATGlobal shareGlobal].scrollViewZoomScale;
        center = CGPointMake((self.center.x-kLeftViewWidth+offset.x)/zoomScale, (self.center.y-kNavigationHeight-kSubTitleHeight+offset.y)/zoomScale);
        origin = CGPointMake((self.frame.origin.x-kLeftViewWidth+offset.x)/zoomScale, (self.frame.origin.y-kNavigationHeight-kSubTitleHeight+offset.y)/zoomScale);
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

- (NSArray *)getCurrentAllowFrames {
    if (_isOriginalDirection) {
        return [NSArray arrayWithArray:_allowOriginalDirectionFramesArray];
    } else {
        return [NSArray arrayWithArray:_allowRotateDirectionFramesArray];
    }
}

/* 需优化 */
- (void)rotateLeft {
    CGPoint originCenter = self.center;
    if (_isOriginalDirection) {
        _isOriginalDirection = NO;
    } else {
        _isOriginalDirection = YES;
    }
    
    CGAffineTransform transform = self.transform;
    CGAffineTransform labTableNameTransform = _labTableName.transform;
    transform = CGAffineTransformRotate(transform, M_PI/2);
    self.transform = transform;
    //取int来比较
    if ((int)self.frame.size.width > (int)self.frame.size.height) {
        self.center = CGPointMake(originCenter.x-self.frame.size.height/2-self.frame.size.width/2, originCenter.y-self.frame.size.height/2);
    } else if ((int)self.frame.size.width < (int)self.frame.size.height) {
        self.center = CGPointMake(originCenter.x+self.frame.size.height/2+self.frame.size.width/2, originCenter.y+self.frame.size.height/4);
    } else {
        self.center = originCenter;
    }
    
    labTableNameTransform = CGAffineTransformRotate(labTableNameTransform, -M_PI/2);
    _labTableName.transform = labTableNameTransform;
    
    NSArray *allowFramesArray = [self getCurrentAllowFrames];
    
    NSInteger frameIndex = [self goodFrameIndexNeedTrans:NO];
    if (frameIndex >= 0) {
        _currentGoodFrameIndex = frameIndex;
    }
    self.frame = [[allowFramesArray objectAtIndex:_currentGoodFrameIndex] CGRectValue];
    if ([[ATGlobal shareGlobal] checkRectIntersectById:_tableId ByRect:self.frame]) {
        self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_wrong"]];
    } else {
        self.imageView.image = [UIImage imageNamed:_tableInfo[@"image_done"]];
        self.backgroundColor = [UIColor clearColor];
    }
    
    [[ATGlobal shareGlobal] saveTableDataWithId:_tableId withFrame:[allowFramesArray objectAtIndex:_currentGoodFrameIndex]];
    
    [self.superview bringSubviewToFront:self];
}

- (void)rotateRight {
    [self rotateLeft];
}

@end
