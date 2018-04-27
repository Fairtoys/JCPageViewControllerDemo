//
//  JCPageScrollView.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageScrollView.h"
#import <Masonry.h>
#import <objc/runtime.h>

@interface JCPageScrollViewOrientation : NSObject

- (instancetype)initWithScrollView:(JCPageScrollView *)scrollView;

@property (nonatomic, weak) JCPageScrollView *scrollView;
- (JCPageScrollViewNavigationOrientation)orientationType;
- (void)setAlwaysBounce;
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx;
- (CGSize)contentSize;
- (CGPoint)contentOffsetForSelectedView;
- (BOOL)isShouldLoadBeforeView;
- (UIEdgeInsets)contentInsetForNoBeforeView;
- (BOOL)isShouldLoadAfterView;
- (UIEdgeInsets)contentInsetForNoAfterView;
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView;
- (BOOL)isShouldSetBeforeViewToSelectedView;
- (BOOL)isShouldSetAfterViewToSelectedView;
- (void)willChangeToSize:(CGSize)size;
@end


@implementation JCPageScrollViewOrientation

- (instancetype)initWithScrollView:(JCPageScrollView *)scrollView{
    if (self = [super init]) {
        self.scrollView = scrollView;
    }
    return self;
}

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationHorizontal;
}
- (void)setAlwaysBounce{
    
}
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    
}
- (CGPoint)contentOffsetForSelectedView{
    return CGPointZero;
}
- (BOOL)isShouldLoadBeforeView{
    return NO;
}
- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsZero;
}
- (BOOL)isShouldLoadAfterView{
    return NO;
}
- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsZero;
}
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsZero;
}
- (BOOL)isShouldSetBeforeViewToSelectedView{
    return NO;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return NO;
}
- (CGSize)contentSize{
    return CGSizeZero;
}
- (void)willChangeToSize:(CGSize)size{
    
}

@end

@interface JCPageScrollViewOrientationVertical : JCPageScrollViewOrientation

@end



@interface JCPageScrollViewOrientationHorizontal : JCPageScrollViewOrientation

@end



@interface JCPageScrollView () <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray <UIView *> *containerViews;//有三个视图容器，初始化ScrollView时就创建好

@property (nonatomic, readonly) UIView *selectedViewContainerView;//当中的View的ContainerView

@property (nonatomic, readonly) UIView *beforeViewContainerView;//最前面的容器

@property (nonatomic, readonly) UIView *afterViewContainerView;//最后面的容器

@property (nonatomic, weak) id<UIScrollViewDelegate> theDelegate;

@property (nonatomic, assign, getter = isNeedLoadAfterView) BOOL needLoadAfterView;//用来限制是否需要加载下一个View

@property (nonatomic, assign, getter = isNeedLoadBeforeView) BOOL needLoadBeforeView;//用来限制是否需要加载上一个View

@property (nonatomic, strong, nullable) UIView *beforeView;
@property (nonatomic, strong, nullable) UIView *afterView;

@property (nonatomic, assign) BOOL setuped;//用来判断是否初始化过ScrollView的offset了，只有创建ScrollView的时候才有用，一次性属性

@property (nonatomic, weak, nullable) UIView *transitioningView;//当前正在切换的视图

@property (nonatomic, assign, getter = isTransitionComplete) BOOL transitionComplete;//当前切换是否完成了，给Controller使用的，controller需要重新调用划走的VC的appearmethods

#pragma mark 方向类
@property (nonatomic, strong) JCPageScrollViewOrientation *orientation;

#pragma mark 重用

@property (nonatomic, strong) NSMutableDictionary <NSString *, NSMutableSet <UIView *> *> * reusableViews;

@property (nonatomic, assign, getter = isLayoutContainerViewsOnly) BOOL layoutContainerViewsOnly;

@end

@implementation JCPageScrollView

- (instancetype)init{
    return [self initWithOrientationType:JCPageScrollViewNavigationOrientationVertical];
}

- (instancetype)initWithOrientationType:(JCPageScrollViewNavigationOrientation)orientationType{
    if (self = [super init]) {
        self.navigationOrientationType = orientationType;
    }
    return self;
}

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
- (void)dealloc
{
    _theDelegate = nil;
    [super setDelegate:nil];
}

- (void)setupContainerViews{
    self.pagingEnabled = YES;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    [self _resetData];
    [super setDelegate:self];
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addSubview:obj];
    }];
}

- (void)layoutSubviews{
    [self.containerViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self setContainerViewsFrame:obj idx:idx];
    }];
    CGSize lastContentSize = self.contentSize;
    CGSize contentSize = [self theContentSize];
    if (!CGSizeEqualToSize(lastContentSize, contentSize)) {
        self.layoutContainerViewsOnly = YES;
    }
    self.contentSize = contentSize;
    
    if (!self.setuped) {
        self.setuped = YES;
        self.contentOffset = [self contentOffsetForSelectedView];
    }
}

- (void)setCanLoadBeforeAndAfterView{
    
    if (!_beforeView) {
        _needLoadBeforeView = YES;
    }
    if (!_afterView) {
        _needLoadAfterView = YES;
    }
    self.contentInset = UIEdgeInsetsZero;
}

- (void)setNavigationOrientationType:(JCPageScrollViewNavigationOrientation)navigationOrientationType{
    switch (navigationOrientationType) {
        case JCPageScrollViewNavigationOrientationVertical:
            self.orientation = [[JCPageScrollViewOrientationVertical alloc] initWithScrollView:self];
            break;
        default:
            self.orientation = [[JCPageScrollViewOrientationHorizontal alloc] initWithScrollView:self];
            break;
    }
}

- (JCPageScrollViewNavigationOrientation)navigationOrientationType{
    return self.orientation.orientationType;
}

- (void)setOrientation:(JCPageScrollViewOrientation *)orientation{
    if (_orientation == orientation) {
        return ;
    }
    _orientation = orientation;
    
    self.setuped = NO;//在layout的时候重新设置contentOffset
    [_orientation setAlwaysBounce];
    [self _setContentInsetByBeforeAndAfterView];
    [self setNeedsLayout];
}

- (NSArray <UIView *> *)containerViews{
    if (!_containerViews) {
        _containerViews = @[[[UIView alloc] init],[[UIView alloc] init],[[UIView alloc] init]];
    }
    return _containerViews;
}


- (UIView *)beforeViewContainerView{
    return self.containerViews.firstObject;
}
static const NSInteger kSelectedIdx = 1;
- (UIView *)selectedViewContainerView{
    return [self containerViewAtIndex:kSelectedIdx];
}

- (UIView *)afterViewContainerView{
    return self.containerViews.lastObject;
}

- (UIView *)containerViewAtIndex:(NSInteger)index{
    return self.containerViews[index];
}

- (NSMutableDictionary<NSString *,NSMutableSet<UIView *> *> *)reusableViews{
    if (!_reusableViews) {
        _reusableViews = [NSMutableDictionary dictionary];
    }
    return _reusableViews;
}

- (UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier{
    NSMutableSet <UIView *> *views = self.reusableViews[identifier];
    if (!views) {
        views = [NSMutableSet set];
        self.reusableViews[identifier] = views;
    }
    
    UIView *view = [views anyObject];
    if (view) {
        [views removeObject:view];
    }
    return view;
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
    [self setSelectedView:selectedView resetData:YES];
}

- (void)setSelectedView:(UIView *)selectedView resetData:(BOOL)resetData{
    [_selectedView removeFromSuperview];
    _selectedView = selectedView;
    [self.selectedViewContainerView addSubview:selectedView];
    [selectedView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.selectedViewContainerView);
    }];
    
    if (self.setuped) {
        self.contentOffset = [self contentOffsetForSelectedView];
        self.contentInset = UIEdgeInsetsZero;
    }
    
    if (resetData) {
        [self _resetData];
    }
}

- (void)setTransitioningViewAndCallback:(UIView *)transitioningView{
    if (_transitioningView == transitioningView) {
        return ;
    }
    UIView *lastTransitionView = _transitioningView;
    _transitioningView = transitioningView;
    if (self.transitionViewDidChangeBlock) {
        self.transitionViewDidChangeBlock(self, lastTransitionView, transitioningView);
    }
    
}

- (void)_resetData{
    self.needLoadAfterView = YES;
    self.needLoadBeforeView = YES;
    self.transitionComplete = YES;
    self.transitioningView = nil;
    [self _cacheOrRemoveView:_beforeView];
    self.beforeView = nil;
    [self _cacheOrRemoveView:_afterView];
    self.afterView = nil;
}

- (void)_setContentInsetByBeforeAndAfterView{
    
    if (!_beforeView && !_afterView) {
        self.contentInset = [self contentInsetForNoBeforeAndAfterView];
        return;
    }
    
    if (!_beforeView) {
        self.contentInset = [self contentInsetForNoBeforeView];
        return;
    }
    
    if (!_afterView) {
        self.contentInset = [self contentInsetForNoAfterView];
        return;
    }
    
    self.contentInset = UIEdgeInsetsZero;
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
    self.contentOffset = [self contentOffsetForSelectedView];
}

#pragma mark - ScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    if (self.isLayoutContainerViewsOnly) {
        self.layoutContainerViewsOnly = NO;
        return;
    }
    
    if (self.isTransitioningOrientation) {
        return;
    }
    
    if ([self isShouldLoadAfterView]){//加载下一个视图
        if (self.isNeedLoadAfterView) {
            self.needLoadAfterView = NO;
            if (self.viewAfterSelectedViewBlock) {
                self.afterView = self.viewAfterSelectedViewBlock(self, self.selectedView);
            }
            [self _setContentInsetByBeforeAndAfterView];
        }
        
        if (self.afterView) {
            if (self.isTransitionComplete) {//调用一次就不调了
                self.transitionComplete = NO;
                self.transitioningView = self.afterView;
                if (self.viewWillTransitionBlock) {
                    self.viewWillTransitionBlock(self, self.selectedView, self.afterView);
                }
                return ;
            }
            
            [self setTransitioningViewAndCallback:self.afterView];
        }
    }else if ([self isShouldLoadBeforeView]){//加载上一个视图
        
        if (self.isNeedLoadBeforeView) {
            self.needLoadBeforeView = NO;
            if (self.viewBeforeSelectedViewBlock) {
                self.beforeView = self.viewBeforeSelectedViewBlock(self, self.selectedView);
            }
            [self _setContentInsetByBeforeAndAfterView];
        }
        if (self.beforeView) {
            if (self.isTransitionComplete) {//调用一次就不调了
                self.transitionComplete = NO;
                self.transitioningView = self.beforeView;
                if (self.viewWillTransitionBlock) {
                    self.viewWillTransitionBlock(self, self.selectedView, self.beforeView);
                }
                return ;
            }
            
            [self setTransitioningViewAndCallback:self.beforeView];
        }
        
    }
    if ([self isShouldSetAfterViewToSelectedView]){//上滑出了下一个
        self.needLoadAfterView = YES;
        self.needLoadBeforeView = NO;//因为上一个还在视图中，所以不需要加载新的视图
        self.transitionComplete = YES;
        [_afterView removeFromSuperview];
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];
        
        [self _cacheOrRemoveView:_beforeView];//判断是否需要缓存，不需要则直接移除
        
        _beforeView = nil;
        self.beforeView = self.selectedView;
        _selectedView = nil;
        [self setSelectedView:self.afterView resetData:NO];
        
        if (self.viewDidTransitionBlock) {
            self.viewDidTransitionBlock(self, self.beforeView, self.selectedView);
        }
        _afterView = nil;
    }
    if ([self isShouldSetBeforeViewToSelectedView]) {//下拉出上一个
        self.needLoadBeforeView = YES;
        self.needLoadAfterView = NO;//因为上一个还在视图中，所以不需要加载新的视图
        self.transitionComplete = YES;
        [_beforeView removeFromSuperview];
        [_selectedView removeFromSuperview];
        [_afterView removeFromSuperview];
        
        [self _cacheOrRemoveView:_afterView];//判断是否需要缓存，不需要则直接移除
        
        _afterView = nil;
        self.afterView = self.selectedView;
        _selectedView = nil;
        [self setSelectedView:self.beforeView resetData:NO];
        
        if (self.viewDidTransitionBlock) {
            self.viewDidTransitionBlock(self, self.afterView, self.selectedView);
        }
        _beforeView = nil;
    }
    
    if ([self.theDelegate respondsToSelector:_cmd]) {
        [self.theDelegate scrollViewDidScroll:scrollView];
    }
}

- (BOOL)_cacheViewIfNeedForReuse:(UIView *)view{
    if (!view) {
        return NO;
    }
    NSString *identifier = view.jc_pageScrollViewReuseIdentifier;
    if (!identifier.length) {
        return NO;
    }
    NSMutableSet <UIView *>* views = self.reusableViews[identifier];
    
    if (!views) {
        views = [NSMutableSet set];
        self.reusableViews[identifier] = views;
    }
    
    [views addObject:view];
    return YES;
}

- (void)_cacheOrRemoveView:(UIView *)view{
    BOOL needCache = [self _cacheViewIfNeedForReuse:view];
    if (!needCache) {
        //AfterView不需要了，移除
        if (self.viewDidRemoveFromSuperViewBlock) {
            self.viewDidRemoveFromSuperViewBlock(self, view);
        }
    }
}

#pragma mark - orientation methods start
- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    [self.orientation setContainerViewsFrame:obj idx:idx];
}
- (CGPoint)contentOffsetForSelectedView{
    return [self.orientation contentOffsetForSelectedView];
}
- (BOOL)isShouldLoadBeforeView{
    return [self.orientation isShouldLoadBeforeView];
}
- (UIEdgeInsets)contentInsetForNoBeforeView{
    return [self.orientation contentInsetForNoBeforeView];
}
- (BOOL)isShouldLoadAfterView{
    return [self.orientation isShouldLoadAfterView];
}
- (UIEdgeInsets)contentInsetForNoAfterView{
    return [self.orientation contentInsetForNoAfterView];
}

- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return [self.orientation contentInsetForNoBeforeAndAfterView];
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return [self.orientation isShouldSetBeforeViewToSelectedView];
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return [self.orientation isShouldSetAfterViewToSelectedView];
}
- (CGSize)theContentSize{
    return [self.orientation contentSize];
}
- (void)willChangeToSize:(CGSize)size{
    [self.orientation willChangeToSize:size];
}

#pragma mark - orientation methods end

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if (self.scrollDidEndBlock) {
        self.scrollDidEndBlock(self, self.transitioningView, self.selectedView, self.isTransitionComplete);
    }
    self.transitionComplete = YES;
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

@implementation JCPageScrollViewOrientationVertical

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationVertical;
}

- (void)setAlwaysBounce{
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.alwaysBounceHorizontal = NO;
}

- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    obj.frame = CGRectMake(0, CGRectGetHeight(self.scrollView.frame) * idx, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
}

- (CGPoint)contentOffsetForSelectedView{
    return CGPointMake(0, CGRectGetHeight(self.scrollView.frame));
}

- (BOOL)isShouldLoadBeforeView{
    return self.scrollView.contentOffset.y < CGRectGetHeight(self.scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsMake(-CGRectGetHeight(self.scrollView.frame), 0, 0, 0);
}

- (BOOL)isShouldLoadAfterView{
    return self.scrollView.contentOffset.y > CGRectGetHeight(self.scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsMake(0, 0,  -CGRectGetHeight(self.scrollView.frame), 0);
}

- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsMake(-CGRectGetHeight(self.scrollView.frame), 0,  -CGRectGetHeight(self.scrollView.frame), 0);
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return self.scrollView.contentOffset.y <= 0;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return self.scrollView.contentOffset.y >= CGRectGetHeight(self.scrollView.frame) * 2;
}
- (CGSize)contentSize{
    return CGSizeMake(CGRectGetWidth(self.scrollView.frame), CGRectGetMaxY(self.scrollView.containerViews.lastObject.frame));
}
- (void)willChangeToSize:(CGSize)size{
    self.scrollView.contentOffset = CGPointMake(0, CGRectGetHeight(self.scrollView.frame));
}

@end

@implementation JCPageScrollViewOrientationHorizontal

- (JCPageScrollViewNavigationOrientation)orientationType{
    return JCPageScrollViewNavigationOrientationHorizontal;
}

- (void)setAlwaysBounce{
    self.scrollView.alwaysBounceVertical = NO;
    self.scrollView.alwaysBounceHorizontal = YES;
}

- (void)setContainerViewsFrame:(UIView *)obj idx:(NSUInteger)idx{
    obj.frame = CGRectMake(CGRectGetWidth(self.scrollView.frame) * idx, 0, CGRectGetWidth(self.scrollView.frame), CGRectGetHeight(self.scrollView.frame));
}

- (CGPoint)contentOffsetForSelectedView{
    return CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
}

- (BOOL)isShouldLoadBeforeView{
    return self.scrollView.contentOffset.x < CGRectGetWidth(self.scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoBeforeView{
    return UIEdgeInsetsMake(0, -CGRectGetWidth(self.scrollView.frame), 0, 0);
}

- (BOOL)isShouldLoadAfterView{
    return self.scrollView.contentOffset.x > CGRectGetWidth(self.scrollView.frame);
}

- (UIEdgeInsets)contentInsetForNoAfterView{
    return UIEdgeInsetsMake(0, 0, 0, -CGRectGetWidth(self.scrollView.frame));
}
- (UIEdgeInsets)contentInsetForNoBeforeAndAfterView{
    return UIEdgeInsetsMake(0, -CGRectGetWidth(self.scrollView.frame), 0, -CGRectGetWidth(self.scrollView.frame));
}

- (BOOL)isShouldSetBeforeViewToSelectedView{
    return self.scrollView.contentOffset.x <= 0;
}
- (BOOL)isShouldSetAfterViewToSelectedView{
    return self.scrollView.contentOffset.x >= CGRectGetWidth(self.scrollView.frame) * 2;
}
- (CGSize)contentSize{
    return CGSizeMake(CGRectGetMaxX(self.scrollView.containerViews.lastObject.frame), CGRectGetHeight(self.scrollView.frame));
}

- (void)willChangeToSize:(CGSize)size{
    self.scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.scrollView.frame), 0);
}

@end



@implementation UIView (JCPageScrollView)
- (void)setJc_pageScrollViewReuseIdentifier:(NSString *)jc_pageScrollViewReuseIdentifier{
    objc_setAssociatedObject(self, @selector(jc_pageScrollViewReuseIdentifier), jc_pageScrollViewReuseIdentifier, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)jc_pageScrollViewReuseIdentifier{
    return objc_getAssociatedObject(self, _cmd);
}

@end


