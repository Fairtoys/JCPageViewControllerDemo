//
//  JCPageViewController.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/11.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageViewController.h"
#import <Masonry.h>
#import "JCPageScrollView.h"
#import <objc/runtime.h>

@interface JCPageViewController ()
@property (nonatomic, strong) JCPageScrollView *scrollView;

@property (nonatomic, strong) NSMutableDictionary <NSNumber *, UIViewController *> * viewControllerMap;

@end

@implementation JCPageViewController

- (NSMutableDictionary<NSNumber *,UIViewController *> *)viewControllerMap{
    if (!_viewControllerMap) {
        _viewControllerMap = [NSMutableDictionary dictionary];
    }
    return _viewControllerMap;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    if ([self.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    UIGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGes:)];
    [self.view addGestureRecognizer:gesture];
}

//- (void)viewWillAppear:(BOOL)animated{
//    [super viewWillAppear:animated];
//    [self.selectedViewController beginAppearanceTransition:YES animated:animated];
//}
//- (void)viewDidAppear:(BOOL)animated{
//    [super viewDidAppear:animated];
//    [self.selectedViewController endAppearanceTransition];
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//    [super viewWillDisappear:animated];
//    [self.selectedViewController beginAppearanceTransition:NO animated:animated];
//}
//
//- (void)viewDidDisappear:(BOOL)animated{
//    [super viewDidDisappear:animated];
//    [self.selectedViewController endAppearanceTransition];
//}

- (void)onPanGes:(UIPanGestureRecognizer *)sender{
    NSLog(@"onPanGes");
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController{

    [self setSelectedViewController:selectedViewController beginAppearenceTransitions:YES];
    
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController beginAppearenceTransitions:(BOOL)beginAppearenceTransitions{
    UIViewController *lastViewContorller = _selectedViewController;
    [self mapController:selectedViewController];
    if (beginAppearenceTransitions) {
        [lastViewContorller beginAppearanceTransition:NO animated:YES];
        [selectedViewController beginAppearanceTransition:YES animated:YES];
        [_selectedViewController willMoveToParentViewController:nil];
        [self addChildViewController:selectedViewController];
        self.scrollView.selectedView = selectedViewController.view;
        //    [_selectedViewController.view removeFromSuperview];
        [_selectedViewController removeFromParentViewController];
    }
    

    _selectedViewController = selectedViewController;
    
    if (beginAppearenceTransitions) {
        [selectedViewController didMoveToParentViewController:self];
        [lastViewContorller endAppearanceTransition];
        [selectedViewController endAppearanceTransition]; //系统的是下一个的DidAppear先回调，再调用上一个的DidDisappear，这里我改成了先调上一个的DidDisapear,再调当前的DidAppear
    }
}

- (JCPageScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[JCPageScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(onScrollViewPan:)];
        __weak typeof(self) weakSelf = self;
        [_scrollView setViewAfterSelectedViewBlock:^UIView * _Nullable(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            
            if (weakSelf.controllerAfterSelectedViewControllerBlock) {
                UIViewController *selectedController = [weakSelf controllerForView:selectedView];
                UIViewController *controller = weakSelf.controllerAfterSelectedViewControllerBlock(weakSelf, selectedController);
                [weakSelf mapController:controller];
                return controller.view;
            }

            return nil;
        }];
        
        [_scrollView setViewBeforeSelectedViewBlock:^UIView * _Nullable(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            if (weakSelf.controllerBeforeSelectedViewControllerBlock) {
                UIViewController *selectedController = [weakSelf controllerForView:selectedView];
                UIViewController *controller = weakSelf.controllerBeforeSelectedViewControllerBlock(weakSelf, selectedController);
                [weakSelf mapController:controller];
                return controller.view;
            }
            
            return nil;
            
        }];
//        [_scrollView setSelectedViewDidApearBlock:^(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
//            NSLog(@"viewDid appear%@", @(selectedView.tag));
//            UIViewController *controller = [weakSelf controllerForView:selectedView];
//            [weakSelf addChildViewController:controller];
//            [controller didMoveToParentViewController:weakSelf];
//
//        }];
//        [_scrollView setSelectedViewDidDisapearBlock:^(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
//            NSLog(@"viewDid disappear%@", @(selectedView.tag));
//            UIViewController *controller = [weakSelf controllerForView:selectedView];
//            [controller willMoveToParentViewController:nil];
//            [controller removeFromParentViewController];
//        }];
        
        [_scrollView setViewWillTransitionBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView) {
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            [toController beginAppearanceTransition:YES animated:YES];
            [fromController beginAppearanceTransition:NO animated:YES];
        }];
        
        [_scrollView setViewDidTransitionBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView) {
           
  
            
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            

            [fromController willMoveToParentViewController:nil];
            [weakSelf addChildViewController:toController];
            [fromController removeFromParentViewController];
            [weakSelf setSelectedViewController:toController beginAppearenceTransitions:NO];
            [toController didMoveToParentViewController:weakSelf];
//            [toController endAppearanceTransition];
            [fromController endAppearanceTransition];
            
            
        }];
        
        [_scrollView setScrollDidEndBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView, BOOL isTransitionComplete) {
            if (!fromView) {
                return ;
            }
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            if (isTransitionComplete) {
                [toController endAppearanceTransition];
            }else{
                [toController beginAppearanceTransition:YES animated:YES];
                [fromController beginAppearanceTransition:NO animated:YES];
                [fromController endAppearanceTransition];
                [toController endAppearanceTransition]; //系统的是下一个的DidAppear先回调，再调用上一个的DidDisappear，这里我改成了先调上一个的DidDisapear,再调当前的DidAppear
            }
            
        }];
        
    }
    return _scrollView;
}

- (UIViewController *)controllerForView:(UIView *)view{
    if (!view) {
        return nil;
    }
    return self.viewControllerMap[@(view.hash)];
}
- (void)mapController:(UIViewController *)controller forView:(UIView *)view{
    if (!view) {
        return;
    }
    self.viewControllerMap[@(view.hash)] = controller;
}

- (void)mapController:(UIViewController *)controller{
    [self mapController:controller forView:controller.view];
}

- (void)onScrollViewPan:(UIPanGestureRecognizer *)panGes{
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        self.scrollView.contentOffset = CGPointMake(0, size.height);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
    
    [self.selectedViewController viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    return [self.selectedViewController shouldAutorotate];
}

- (BOOL)shouldAutomaticallyForwardAppearanceMethods{
    return NO;
}


@end


