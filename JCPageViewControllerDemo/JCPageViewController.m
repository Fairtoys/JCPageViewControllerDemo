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

@property (nonatomic, assign, getter = isPageViewDidViewAppeared) BOOL pageViewDidViewAppeared;

@property (nonatomic, assign, getter = isNeedInvokeSelectVCAppearenceMethods) BOOL needInvokeSelectVCAppearenceMethods;
@end

@implementation JCPageViewController

- (void)setCanLoadBeforeAndAfterViewController{
    [self.scrollView setCanLoadBeforeAndAfterView];
}

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
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (self.isNeedInvokeSelectVCAppearenceMethods) {
        [self.selectedViewController beginAppearanceTransition:YES animated:animated];
    }
    
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.isNeedInvokeSelectVCAppearenceMethods) {
        [self.selectedViewController endAppearanceTransition];
    }
    self.needInvokeSelectVCAppearenceMethods = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.selectedViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.selectedViewController endAppearanceTransition];
}

- (UIViewController *)dequeueReusableViewControllerWithIdentifier:(NSString *)identifier{
    UIView *view = [self.scrollView dequeueReusableViewWithIdentifier:identifier];
    return [self controllerForView:view];
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController{

    [self setSelectedViewController:selectedViewController reloadData:YES];
    
}

- (void)setSelectedViewController:(__kindof UIViewController *)selectedViewController reloadData:(BOOL)reloadData{
    
    if (reloadData) {
         [self.viewControllerMap removeAllObjects];//移除所有的ViewController
    }
    
    UIViewController *lastViewContorller = _selectedViewController;
    [self mapController:selectedViewController];
    if (reloadData) {
        [selectedViewController beginAppearanceTransition:YES animated:YES];
        [lastViewContorller beginAppearanceTransition:NO animated:YES];
        [_selectedViewController willMoveToParentViewController:nil];
        [self addChildViewController:selectedViewController];
        self.scrollView.selectedView = selectedViewController.view;
        [_selectedViewController removeFromParentViewController];
        
        self.needInvokeSelectVCAppearenceMethods = NO;
    }
    

    _selectedViewController = selectedViewController;
    
    if (reloadData) {
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
            [weakSelf setSelectedViewController:toController reloadData:NO];
            [toController didMoveToParentViewController:weakSelf];
//            [toController endAppearanceTransition];//这个不需要了，因为在滚动停止时才需要调用此方法，但是上一个缺需要在此时调用此方法来触发viewDidDisappear方法
            [fromController endAppearanceTransition];
            
            //提供一个外部回调
            if (weakSelf.controllerWillTransitionBlock) {
                weakSelf.controllerWillTransitionBlock(weakSelf, fromController, toController);
            }
            
        }];
        
        [_scrollView setScrollDidEndBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView, BOOL isTransitionComplete) {
            if (!fromView) {//没有fromView，说明没有发生切换动作，故直接返回
                return ;
            }
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            if (isTransitionComplete) {
                //这里发生了切换，只需要调用完成方法来调用viewDidAppear
                [toController endAppearanceTransition];
                
                //真的发生了切换的回调
                if (weakSelf.controllerDidTransitionBlock) {
                    weakSelf.controllerDidTransitionBlock(weakSelf, fromController, toController);
                }
            }else{
                //重新调用当前VC的viewWillAppear和viewDidAppear等
                [toController beginAppearanceTransition:YES animated:YES];
                [fromController beginAppearanceTransition:NO animated:YES];
                [fromController endAppearanceTransition];
                [toController endAppearanceTransition]; //系统的是下一个的DidAppear先回调，再调用上一个的DidDisappear，这里我改成了先调上一个的DidDisapear,再调当前的DidAppear
            }
            
        }];
        
        //要移除掉该View对应的Controller
        [_scrollView setViewDidRemoveFromSuperViewBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            [weakSelf removeViewControllerForView:selectedView];
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

- (void)removeViewControllerForView:(UIView *)view{
    [self.viewControllerMap removeObjectForKey:@(view.hash)];
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

@implementation UIViewController (JCPageViewController)
- (JCPageViewController *)jc_thePageViewController{
    UIViewController *parentViewController = self.parentViewController;
    while (parentViewController && ![parentViewController isKindOfClass:[JCPageViewController class]]) {
        parentViewController = parentViewController.parentViewController;
    }
    return (JCPageViewController *)parentViewController;
}
@end


