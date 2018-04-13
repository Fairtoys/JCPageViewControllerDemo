//
//  JCPageViewControllerIndexEx.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageViewControllerIndexEx.h"
#import <objc/runtime.h>

@interface JCPageViewControllerIndexEx ()

@end

@implementation JCPageViewControllerIndexEx

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        __weak typeof(self) weakSelf = self;
        [self setControllerBeforeSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
            NSInteger maxCount = 0;
            if (weakSelf.viewControllerCountBlock) {
                maxCount = weakSelf.viewControllerCountBlock(weakSelf);
            }
            if (maxCount <= 0) {
                return nil;
            }
            
            
            NSInteger index = selectedViewController.selectedIndexForPage - 1;
            
            
            if (index < 0) {
                if (!weakSelf.isCanLoop) {
                    return nil;
                }else{
                    index = maxCount - 1;
                }
            }
            
            if (weakSelf.viewControllerAtIndexBlock) {
                UIViewController *theViewController = weakSelf.viewControllerAtIndexBlock(weakSelf, index);
                
                if (!theViewController) {
                    return nil;
                }
                
                theViewController.selectedIndexForPage = index;
                return theViewController;
            }
            
            return nil;
        }];
        
        [self setControllerAfterSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
            NSInteger maxCount = 0;
            if (weakSelf.viewControllerCountBlock) {
                maxCount = self.viewControllerCountBlock(weakSelf);
            }
            
            if (maxCount <= 0) {
                return nil;
            }
            
            NSInteger index = selectedViewController.selectedIndexForPage + 1;
            
            if (index > maxCount - 1) {
                if (!weakSelf.isCanLoop) {
                    return nil;
                }else{
                    index = 0;
                }
            }
            
            if (weakSelf.viewControllerAtIndexBlock) {
                UIViewController *theViewController = weakSelf.viewControllerAtIndexBlock(weakSelf, index);
                if (!theViewController) {
                    return nil;
                }
                theViewController.selectedIndexForPage = index;
                return theViewController;
            }
            
            return nil;
        }];
        
        [self setControllerWillTransitionBlock:^(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull fromViewController, __kindof UIViewController * _Nonnull toViewController) {
            //判断是否需要加载新数据
            
            if (JCPageViewControllerIndexExStatusNormal != weakSelf.loadingStatus) {
                return;
            }
            
            if (weakSelf.needLoadMoreBlock) {
                NSInteger count = 0;
                if (weakSelf.viewControllerCountBlock) {
                    count = weakSelf.viewControllerCountBlock(weakSelf);
                }
                BOOL needLoadMore = weakSelf.needLoadMoreBlock(weakSelf, weakSelf.selectedViewController.selectedIndexForPage, count);
                
                if (needLoadMore) {
                    weakSelf.loadingStatus = JCPageViewControllerIndexExStatusLoadingMore;
                    if (weakSelf.loadMoreBlock) {
                        weakSelf.loadMoreBlock(weakSelf, weakSelf.selectedViewController.selectedIndexForPage, count);
                    }
                }
            }
        }];
    }
    return self;
}


- (NSInteger)selectedIndex{
    return self.selectedViewController.selectedIndexForPage;
}

- (void)setSelectedIndex:(NSInteger)selectedIndex{
    NSInteger min = 0;
    NSInteger max = 0;
    if (self.viewControllerCountBlock) {
        max = self.viewControllerCountBlock(self);
    }
    if (selectedIndex < min || selectedIndex >= max) {
        return;
    }
    
    UIViewController *viewController = nil;
    if (self.viewControllerAtIndexBlock) {
        viewController = self.viewControllerAtIndexBlock(self, selectedIndex);
    }
    
    if (!viewController) {
        return;
    }
    
    viewController.selectedIndexForPage = selectedIndex;
    
    self.selectedViewController = viewController;
}


- (void)endRefreshing{
    self.loadingStatus = JCPageViewControllerIndexExStatusNormal;
}

- (void)reloadSelectedViewController{
    if (!self.selectedViewController) {
        return;
    }
    [self setCanLoadBeforeAndAfterViewController];
}

@end


@implementation UIViewController (JCPageViewControllerIndexExItemVC)

- (void)setSelectedIndexForPage:(NSInteger)selectedIndexForPage{
       objc_setAssociatedObject(self, @selector(selectedIndexForPage), @(selectedIndexForPage), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)selectedIndexForPage{
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}


@end
