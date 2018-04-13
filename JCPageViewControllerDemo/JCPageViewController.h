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

@interface JCPageViewController : UIViewController

@property (nonatomic, readonly) JCPageScrollView *scrollView;

@property (nonatomic, strong) __kindof UIViewController *selectedViewController;//当前选中的ViewController

@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerBeforeSelectedViewControllerBlock;//获取当前controller之前的Controller的Block
@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerAfterSelectedViewControllerBlock;//获取当前controller之后的Controller的Block

@property (nonatomic, copy, nullable) JCPageViewControllerTransitionBlock controllerWillTransitionBlock;//Controller将要切换的回调

- (void)setCanLoadBeforeAndAfterViewController;//可再次加载前一个和后一个,并清掉beforeViewController 和afterViewController

@end

@protocol JCPageViewControllerItemVC <NSObject>
@property (nonatomic, readonly, nullable) __kindof JCPageViewController *jc_thePageViewController;//从当前中查找PageViewController
@end

@interface UIViewController (JCPageViewController) <JCPageViewControllerItemVC>


@end


NS_ASSUME_NONNULL_END
