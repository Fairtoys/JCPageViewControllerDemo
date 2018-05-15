//
//  JCPageViewController.h
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JCPageViewController;
@class JCPageScrollView;

typedef  UIViewController * _Nullable  (^JCPageViewControllerControllerGetBlock)(__kindof JCPageViewController *thePageViewController, __kindof UIViewController *selectedViewController);
typedef  void (^JCPageViewControllerTransitionBlock)(__kindof JCPageViewController *thePageViewController, __kindof UIViewController *fromViewController, __kindof UIViewController *toViewController);

typedef BOOL(^JCPageViewControllerCanScrollBlock)(__kindof JCPageViewController *thePageViewController);

typedef NS_ENUM(NSUInteger, JCPageViewControllerNavigationOrientation) {
    JCPageViewControllerNavigationOrientationHorizontal = 0,
    JCPageViewControllerNavigationOrientationVertical = 1
};

@interface JCPageViewController : UIViewController

@property (nonatomic, readonly) JCPageScrollView *scrollView;

@property (nonatomic, assign) JCPageViewControllerNavigationOrientation navigationOrientationType;

@property (nonatomic, strong) __kindof UIViewController *selectedViewController;//当前选中的ViewController

@property (nonatomic, assign, getter = isScrollEnabled) BOOL scrollEnabled;//开启、关闭滑动

@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerBeforeSelectedViewControllerBlock;//获取当前controller之前的Controller的Block
@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerAfterSelectedViewControllerBlock;//获取当前controller之后的Controller的Block

@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerWillTransitionBlock;//Controller将要切换的回调
@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerDidTransitionBlock;//滑动过程中切换了Controller的回调

@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerDidEndScrollTransitionBlock;//滑动停止了的回调

@property (nonatomic, copy, nullable) JCPageViewControllerCanScrollBlock canScrollBlock;//滑动是否可以的回调

- (void)setCanLoadBeforeAndAfterViewController;//可再次加载前一个和后一个,并清掉beforeViewController 和afterViewController

#pragma mark - 重用机制
- (nullable __kindof UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier;//从缓存中取出一个ViewController

@end

@protocol JCPageViewControllerItemVC <NSObject>
@property (nonatomic, readonly, nullable) __kindof JCPageViewController *jc_thePageViewController;//从当前中查找PageViewController
@property (nonatomic, strong) NSString *jc_pageScrollViewControllerReuseIdentifier;
@end

@interface UIViewController (JCPageViewController) <JCPageViewControllerItemVC>


@end


NS_ASSUME_NONNULL_END
