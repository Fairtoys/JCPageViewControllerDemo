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

typedef  UIView * _Nullable  (^JCPageScrollViewGetViewBlock)(JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);

typedef void(^JCPageScrollViewAppearanceBlock)(JCPageScrollView *thePageScrollView, __kindof UIView *selectedView);

@interface JCPageScrollView : UIScrollView

- (UIView *)containerViewAtIndex:(NSInteger)index;

@property (nonatomic, strong) UIView *selectedView;

@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewBeforeSelectedViewBlock;
@property (nonatomic, copy, nullable) JCPageScrollViewGetViewBlock viewAfterSelectedViewBlock;

@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock selectedViewDidDisapearBlock;
@property (nonatomic, copy, nullable) JCPageScrollViewAppearanceBlock selectedViewDidApearBlock;

- (void)setContentOffsetToSelectView;
@end

NS_ASSUME_NONNULL_END
