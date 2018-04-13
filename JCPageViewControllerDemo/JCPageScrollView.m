//
//  JCPageScrollView.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageScrollView.h"
#import <Masonry.h>

@interface JCPageScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray <UIView *> *containerViews;

@property (nonatomic, readonly) UIView *selectedViewContainerView;

@property (nonatomic, readonly) UIView *beforeViewContainerView;

@property (nonatomic, readonly) UIView *afterViewContainerView;

@property (nonatomic, weak) id<UIScrollViewDelegate> theDelegate;

@property (nonatomic, assign, getter = isNeedLoadAfterView) BOOL needLoadAfterView;

@property (nonatomic, assign, getter = isNeedLoadBeforeView) BOOL needLoadBeforeView;

@property (nonatomic, strong) UIView *beforeView;
@property (nonatomic, strong) UIView *afterView;

@property (nonatomic, assign) BOOL setuped;

@property (nonatomic, assign, getter = isEnableViewWillTransitionBlock) BOOL enableViewWillTransitionBlock;

@property (nonatomic, weak, nullable) UIView *transitioningView;

@property (nonatomic, assign, getter = isTransitionComplete) BOOL transitionComplete;

@end

@implementation JCPageScrollView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContainerViews];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupContainerViews];
    }
    return self;
}

- (void)setDelegate:(id<UIScrollViewDelegate>)delegate{
    self.theDelegate = delegate;
}

- (void)setupContainerViews{
    self.needLoadAfterView = YES;
    self.needLoadBeforeView = YES;
    self.enableViewWillTransitionBlock = YES;
    [super setDelegate:self];
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    }];
}

- (void)layoutSubviews{
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(0, CGRectGetHeight(self.frame) * idx, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }];
    self.contentSize = CGSizeMake(CGRectGetWidth(self.frame), CGRectGetMaxY(self.containerViews.lastObject.frame));
    if (!self.setuped) {
        self.setuped = YES;
        self.contentOffset = CGPointMake(0, CGRectGetHeight(self.frame));
    }
}

- (NSArray <UIView *> *)containerViews{
    if (!_containerViews) {
        _containerViews = @[[[UIView alloc] init],[[UIView alloc] init],[[UIView alloc] init]].mutableCopy;
        NSArray <UIColor *> *colors = @[[UIColor greenColor], [UIColor redColor], [UIColor yellowColor]];
        [_containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColor = colors[idx];
        }];
    }
    return _containerViews;
}


- (UIView *)beforeViewContainerView{
    return self.containerViews.firstObject;
}

- (UIView *)selectedViewContainerView{
    return self.containerViews[1];
}

- (UIView *)afterViewContainerView{
    return self.containerViews.lastObject;
}

- (UIView *)containerViewAtIndex:(NSInteger)index{
    return self.containerViews[index];
}

- (void)setBeforeView:(UIView *)beforeView{
    [_beforeView removeFromSuperview];
    _beforeView = beforeView;
    [self.beforeViewContainerView addSubview:beforeView];
    [beforeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.beforeViewContainerView);
    }];
}

- (void)setSelectedView:(UIView *)selectedView{
    [_selectedView removeFromSuperview];
    _selectedView = selectedView;
    [self.selectedViewContainerView addSubview:selectedView];
    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.selectedViewContainerView);
    }];
    
    if (self.setuped) {
        self.contentOffset = CGPointMake(0, CGRectGetHeight(self.frame));
        self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
}

- (void)setAfterView:(UIView *)afterView{
    [_afterView removeFromSuperview];
    _afterView = afterView;
    [self.afterViewContainerView addSubview:afterView];
    [afterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.afterViewContainerView);
    }];
}

- (void)setContentOffsetToSelectView{
    self.contentOffset = CGPointMake(0, CGRectGetHeight(self.frame));
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
//    NSLog(@"scrollView did scroll:%@, frame :%@", NSStringFromCGPoint(scrollView.contentOffset), NSStringFromCGRect(scrollView.frame));
    //    scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(scrollView.frame));
    
    if (scrollView.contentOffset.y > CGRectGetHeight(scrollView.frame)) {//加载下一个视图
        
        if (self.isNeedLoadAfterView) {
            self.needLoadAfterView = NO;
            if (self.viewAfterSelectedViewBlock) {
                self.afterView = self.viewAfterSelectedViewBlock(self, self.selectedView);
//                NSLog(@"加载下一个%@", self.afterView);
                //FIXME: 如果没有afterView，不让他滑动太远
                if (!_afterView) {
                    
                    self.contentInset = UIEdgeInsetsMake(0, 0,  -CGRectGetHeight(scrollView.frame), 0);
                }else{
                    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                    
                }
                
            }else{
                
                self.contentInset = UIEdgeInsetsMake(0, 0,  -CGRectGetHeight(scrollView.frame), 0);
            }
            
            //FIXME: 如果没有afterView，不让他滑动太远
        }
        
        if (self.afterView) {
            if (self.isEnableViewWillTransitionBlock) {//调用一次就不调了
                self.enableViewWillTransitionBlock = NO;
                self.transitioningView = self.afterView;
                if (self.viewWillTransitionBlock) {
                    self.viewWillTransitionBlock(self, self.selectedView, self.afterView);
                }
                self.transitionComplete = NO;
            }

        }
    }else if (scrollView.contentOffset.y < CGRectGetHeight(scrollView.frame)){//加载上一个视图
        
        
        
        if (self.isNeedLoadBeforeView) {
            self.needLoadBeforeView = NO;
            if (self.viewBeforeSelectedViewBlock) {
                self.beforeView = self.viewBeforeSelectedViewBlock(self, self.selectedView);
//                NSLog(@"加载上一个:%@", self.beforeView);
                //FIXME: 如果没有beforeView, 不让他滑太远
                if (!_beforeView) {
                    
                    self.contentInset = UIEdgeInsetsMake(-CGRectGetHeight(scrollView.frame), 0, 0, 0);
                }else{
                    
                    self.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }

            }else{
                //FIXME: 如果没有afterView，不让他滑动太远
                
                self.contentInset = UIEdgeInsetsMake(-CGRectGetHeight(scrollView.frame), 0, 0, 0);
            }
        }
        
        if (self.beforeView) {
            if (self.isEnableViewWillTransitionBlock) {//调用一次就不调了
                self.enableViewWillTransitionBlock = NO;
                self.transitioningView = self.beforeView;
                if (self.viewWillTransitionBlock) {
                    self.viewWillTransitionBlock(self, self.selectedView, self.beforeView);
                }
                self.transitionComplete = NO;
            }
        }
        
    }
    
    if (scrollView.contentOffset.y >= CGRectGetHeight(scrollView.frame) * 2) {//上滑出了下一个
        
//        NSLog(@"滑出下一个");
        self.needLoadAfterView = YES;
        self.needLoadBeforeView = NO;//因为上一个还在视图中，所以不需要加载新的视图
        self.enableViewWillTransitionBlock = YES;
        self.transitionComplete = YES;
        [_afterView removeFromSuperview];
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];

        _beforeView = nil;
        self.beforeView = self.selectedView;
        
        _selectedView = nil;
        self.selectedView = self.afterView;

        if (self.viewDidTransitionBlock) {
            self.viewDidTransitionBlock(self, self.beforeView, self.selectedView);
        }
        
        _afterView = nil;
    }
    
    if (scrollView.contentOffset.y <= 0) {//下拉出上一个
//        NSLog(@"下拉上一个");
        self.needLoadBeforeView = YES;
        self.needLoadAfterView = NO;//因为上一个还在视图中，所以不需要加载新的视图
        self.enableViewWillTransitionBlock = YES;
        self.transitionComplete = YES;
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];
        [_afterView removeFromSuperview];
        
        _afterView = nil;
        self.afterView = self.selectedView;
        

        _selectedView = nil;
        self.selectedView = self.beforeView;
        
        if (self.viewDidTransitionBlock) {
            self.viewDidTransitionBlock(self, self.afterView, self.selectedView);
        }
        
        _beforeView = nil;
    }
    
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidScroll:scrollView];
    }
}


- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    if (self.scrollDidEndBlock) {
        self.scrollDidEndBlock(self, self.transitioningView, self.selectedView, self.isTransitionComplete);
    }
    self.transitionComplete = NO;
    self.enableViewWillTransitionBlock = YES;
    self.transitioningView = nil;
    
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

// called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidZoom:scrollView];
    }

}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewWillBeginDragging:scrollView];
    }
}
// called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewWillEndDragging:scrollView withVelocity:velocity targetContentOffset:targetContentOffset];
    }
}


- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}


- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (nullable UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
       return [self.theDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(nullable UIView *)view atScale:(CGFloat)scale{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        return [self.theDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return NO;
}
- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidScrollToTop:scrollView];
    }
}

- (void)scrollViewDidChangeAdjustedContentInset:(UIScrollView *)scrollView{
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidChangeAdjustedContentInset:scrollView];
    }
}



@end


