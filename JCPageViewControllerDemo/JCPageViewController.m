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
    [self.selectedViewController beginAppearanceTransition:YES animated:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.selectedViewController endAppearanceTransition];
    self.pageViewDidViewAppeared = YES;
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.selectedViewController beginAppearanceTransition:NO animated:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.selectedViewController endAppearanceTransition];
    self.pageViewDidViewAppeared = NO;
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
        NSDictionary <NSNumber *,UIViewController *> *viewControllerMap = self.viewControllerMap.copy;
        [viewControllerMap enumerateKeysAndObjectsUsingBlock:^(NSNumber * _Nonnull key, UIViewController * _Nonnull obj, BOOL * _Nonnull stop) {
            if (!obj.jc_pageScrollViewControllerReuseIdentifier.length) {
                [self.viewControllerMap removeObjectForKey:key];//移除没有重用标志的所有ViewController
            }
        }];
    }
    
    [self mapController:selectedViewController];
    if (reloadData) {
        if (self.isPageViewDidViewAppeared) {
            [selectedViewController beginAppearanceTransition:YES animated:YES];
            [_selectedViewController beginAppearanceTransition:NO animated:YES];
        }
        [_selectedViewController willMoveToParentViewController:nil];
        [self addChildViewController:selectedViewController];
        self.scrollView.selectedView = selectedViewController.view;
        if (self.isPageViewDidViewAppeared) {
            [_selectedViewController endAppearanceTransition];
        }
        [_selectedViewController removeFromParentViewController];
    }
    
    _selectedViewController = selectedViewController;
    
    if (reloadData) {
        [selectedViewController didMoveToParentViewController:self];
        if (self.isPageViewDidViewAppeared) {
            //        [lastViewContorller endAppearanceTransition];//这个要提到removeFromParentViewController之前，保证之前的ViewController可以取到ParentViewController
            [selectedViewController endAppearanceTransition]; //系统的是下一个的DidAppear先回调，再调用上一个的DidDisappear，这里我改成了先调上一个的DidDisapear,再调当前的DidAppear
        }
        
    }
}

- (BOOL)isScrollEnabled{
    return self.scrollView.isScrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled{
    self.scrollView.scrollEnabled = scrollEnabled;
}

- (JCPageScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[JCPageScrollView alloc] init];
        
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
            //提供一个外部回调
            if (weakSelf.controllerWillTransitionBlock) {
                weakSelf.controllerWillTransitionBlock(weakSelf, fromController, toController);
            }
        }];
        
        [_scrollView setTransitionViewDidChangeBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView) {
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            [toController beginAppearanceTransition:YES animated:YES];
            [fromController beginAppearanceTransition:NO animated:YES];
            [fromController endAppearanceTransition];
            //提供一个外部回调
            if (weakSelf.controllerWillTransitionBlock) {
                weakSelf.controllerWillTransitionBlock(weakSelf, weakSelf.selectedViewController, toController);
            }
        }];
        
        [_scrollView setViewDidTransitionBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull fromView, __kindof UIView * _Nonnull toView) {
            
            UIViewController *fromController = [weakSelf controllerForView:fromView];
            UIViewController *toController = [weakSelf controllerForView:toView];
            

            [fromController endAppearanceTransition];
            [fromController willMoveToParentViewController:nil];
            [weakSelf addChildViewController:toController];
            [fromController removeFromParentViewController];
            [weakSelf setSelectedViewController:toController reloadData:NO];
            [toController didMoveToParentViewController:weakSelf];
//            [toController endAppearanceTransition];//这个不需要了，因为在滚动停止时才需要调用此方法，但是上一个缺需要在此时调用此方法来触发viewDidDisappear方法
//            [fromController endAppearanceTransition];//这个移动到上面，因为他已经在上面removeFromParentViewController了，所以放到下面的话，已经拿不到ParentViweController了
            
            //真的发生了切换的回调
            if (weakSelf.controllerDidTransitionBlock) {
                weakSelf.controllerDidTransitionBlock(weakSelf, fromController, toController);
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
            }else{
                //重新调用当前VC的viewWillAppear和viewDidAppear等
                [toController beginAppearanceTransition:YES animated:YES];
                [fromController beginAppearanceTransition:NO animated:YES];
                [fromController endAppearanceTransition];
                [toController endAppearanceTransition]; //系统的是下一个的DidAppear先回调，再调用上一个的DidDisappear，这里我改成了先调上一个的DidDisapear,再调当前的DidAppear
            }
            
            //真的发生了切换的回调
            if (weakSelf.controllerDidEndScrollTransitionBlock) {
                weakSelf.controllerDidEndScrollTransitionBlock(weakSelf, fromController, toController);
            }
        }];
        
        //要移除掉该View对应的Controller
        [_scrollView setViewDidRemoveFromSuperViewBlock:^(__kindof JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            [weakSelf removeViewControllerForView:selectedView];
        }];
        
        [_scrollView setCanScrollBlock:^BOOL(__kindof JCPageScrollView * _Nonnull thePageScrollView) {
            if(weakSelf.canScrollBlock){
                return weakSelf.canScrollBlock(weakSelf);
            }
            return YES;
        }];

        
    }
    return _scrollView;
}
- (void)setNavigationOrientationType:(JCPageViewControllerNavigationOrientation)navigationOrientationType{
    self.scrollView.navigationOrientationType = (JCPageScrollViewNavigationOrientation)navigationOrientationType;
}
- (JCPageViewControllerNavigationOrientation)navigationOrientationType{
    return (JCPageViewControllerNavigationOrientation)self.scrollView.navigationOrientationType;
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

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return [self.selectedViewController supportedInterfaceOrientations];
}

- (BOOL)shouldAutorotate{
    if (self.scrollView.isDecelerating || self.scrollView.isDragging || self.scrollView.isTracking) {
        return NO;
    }
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

- (void)setJc_pageScrollViewControllerReuseIdentifier:(NSString *)jc_pageScrollViewControllerReuseIdentifier{
    self.view.jc_pageScrollViewReuseIdentifier = jc_pageScrollViewControllerReuseIdentifier;
}

- (NSString *)jc_pageScrollViewControllerReuseIdentifier{
    return self.view.jc_pageScrollViewReuseIdentifier;
}
@end


