//
//  JCPageScrollView.h
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JCPageScrollView;

typedef  UIView * _Nullable  (^JCPageScrollViewGetViewBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);
typedef void(^JCPageScrollViewAppearanceBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);
typedef void(^JCPageScrollViewViewTransitionBlock)(__kindof JCPageScrollView *thePageScrollView,__kindof UIView *fromView,__kindof UIView *toView);
typedef void(^JCPageScrollViewViewTransitionEndBlock)(__kindof JCPageScrollView *thePageScrollView, __kindof UIView * _Nullable fromView,__kindof UIView *toView, BOOL isTransitionComplete);
typedef BOOL(^JCPageScrollViewCanScrollBlock)(__kindof JCPageScrollView *thePageScrollView);

typedef NS_ENUM(NSUInteger, JCPageScrollViewNavigationOrientation) {
    JCPageScrollViewNavigationOrientationHorizontal = 0,
    JCPageScrollViewNavigationOrientationVertical = 1
};

@interface JCPageScrollView : UIScrollView
//init Default JCPageScrollViewNavigationOrientationVertical
- (instancetype)initWithOrientationType:(JCPageScrollViewNavigationOrientation)orientationType;

- (UIView *)containerViewAtIndex:(NSInteger)index;

@property (nonatomic, strong) UIView *selectedView;//当前显示的视图

@property (nonatomic, assign) JCPageScrollViewNavigationOrientation navigationOrientationType;//方向

@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewBeforeSelectedViewBlock;//获取当前视图之前的视图的回调
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewAfterSelectedViewBlock;//获取当前视图之后的视图的回调

@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewWillTransitionBlock;//视图开始发生切换时的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewDidTransitionBlock;//视图切换后的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock transitionViewDidChangeBlock;//视图切换后的回调

@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionEndBlock scrollDidEndBlock;//滚动停止的回调

@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock viewDidRemoveFromSuperViewBlock;//当视图划走移除之后的回调

@property (nonatomic, copy, nullable) JCPageScrollViewCanScrollBlock canScrollBlock;//是否可以滑动的回调

- (void)setContentOffsetToSelectView;//设置Offset到SelectView的位置

- (void)setCanLoadBeforeAndAfterView;//将needLoadBefore 和needLoadAfter字段都设为YES，方便下次加载新View,并清清掉beforeView和afterView

#pragma mark - 重用机制

- (nullable __kindof UIView *)dequeueReusableViewWithIdentifier:(NSString *)identifier;//从缓存中取出一个ViewController

@end

@interface UIView (JCPageScrollView)

@property (nonatomic, strong) NSString *jc_pageScrollViewReuseIdentifier;

@end


NS_ASSUME_NONNULL_END
