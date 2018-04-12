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

typedef  UIViewController * _Nullable  (^JCPageViewControllerControllerGetBlock)(JCPageViewController *thePageViewController, UIViewController *selectedViewController);

@interface JCPageViewController : UIViewController

@property (nonatomic, strong) __kindof UIViewController *selectedViewController;

@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerBeforeSelectedViewControllerBlock;
@property (nonatomic, copy) JCPageViewControllerControllerGetBlock controllerAfterSelectedViewControllerBlock;


@end

NS_ASSUME_NONNULL_END
