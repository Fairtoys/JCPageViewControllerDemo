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

@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewBeforeSelectedViewBlock;
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewAfterSelectedViewBlock;

@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock selectedViewDidDisapearBlock;
@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock selectedViewDidApearBlock;


@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewWillTransitionBlock;
@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionBlock viewDidTransitionBlock;

@property (nonatomic, copy, nullable) JCPageScrollViewViewTransitionEndBlock scrollDidEndBlock;

- (void)setContentOffsetToSelectView;
@end




NS_ASSUME_NONNULL_END
