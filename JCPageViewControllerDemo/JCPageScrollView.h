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

@interface JCPageScrollView : UIScrollView

- (UIView *)containerViewAtIndex:(NSInteger)index;

@property (nonatomic, strong) UIView *selectedView;//当前显示的视图

@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewBeforeSelectedViewBlock;//获取当前视图之前的视图的回调
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewAfterSelectedViewBlock;//获取当前视图之后的视图的回调

@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewWillTransitionBlock;//视图开始发生切换时的回调
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewDidTransitionBlock;//视图切换后的回调

@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionEndBlock scrollDidEndBlock;//滚动停止的回调

@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock viewDidRemoveFromSuperViewBlock;//当视图划走移除之后的回调

- (void)setContentOffsetToSelectView;//设置Offset到SelectView的位置
@end




NS_ASSUME_NONNULL_END
