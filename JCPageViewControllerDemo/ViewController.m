//
//  ViewController.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/10.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import "JCPageViewController.h"
#import "JCPageViewControllerDemo.h"
#import "ItemViewController.h"
#import "JCPageViewControllerIndexEx.h"
#import "JCPageScrollView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}
- (IBAction)onClickBtn:(id)sender {
    JCPageViewControllerDemo *controller = [[JCPageViewControllerDemo alloc] init];

    [self presentViewController:controller animated:YES completion:NULL];
    
    
}

- (IBAction)onClickControllerBtn:(id)sender {
    
    JCPageViewController *pageViewController = [[JCPageViewController alloc] init];
    

    [pageViewController setControllerBeforeSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
        NSInteger tag = selectedViewController.view.tag - 1;
        if (tag < 0) {
            return nil;
        }
        ItemViewController *vc = [[ItemViewController alloc] init];
        vc.view.tag = tag;
        vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
        return vc;
    }];
    
    [pageViewController setControllerAfterSelectedViewControllerBlock:^UIViewController * _Nullable(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull selectedViewController) {
        NSInteger tag = selectedViewController.view.tag + 1;
        if (tag > 20) {
            return nil;
        }
        ItemViewController *vc = [[ItemViewController alloc] init];
        vc.view.tag = tag;
        vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
        return vc;
    }];

    
    ItemViewController *vc = [[ItemViewController alloc] init];
    vc.view.tag = 0;
    vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
    [pageViewController setSelectedViewController:vc];
    
    [self presentViewController:pageViewController animated:YES completion:NULL];
    
}

- (IBAction)onClickPageIndex:(id)sender {
    
    JCPageViewControllerIndexEx *pageViewController = [[JCPageViewControllerIndexEx alloc] init];
    
    [pageViewController setViewControllerAtIndexBlock:^__kindof UIViewController * _Nonnull(__kindof JCPageViewController * _Nonnull thePageViewController, NSInteger idx) {
        ItemViewController *vc = [[ItemViewController alloc] init];
        vc.view.tag = idx;
        vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
        return vc;
    }];
    
    [pageViewController setViewControllerCountBlock:^NSInteger(__kindof JCPageViewController * _Nonnull thePageViewController) {
        return 20;
    }];
    
    pageViewController.selectedIndex = 0;
    
    [self presentViewController:pageViewController animated:YES completion:NULL];
    
}

- (IBAction)onClickPageIndexCache:(id)sender {
    
    JCPageViewControllerIndexEx *pageViewController = [[JCPageViewControllerIndexEx alloc] init];
    
    [pageViewController setViewControllerAtIndexBlock:^__kindof UIViewController * _Nonnull(__kindof JCPageViewController * _Nonnull thePageViewController, NSInteger idx) {
        static NSString *identifier = @"identifier";
        ItemViewController *vc = [thePageViewController dequeueReusableViewControllerWithIdentifier:identifier];
        if (!vc) {
            vc = [[ItemViewController alloc] init];
            vc.view.jc_pageScrollViewReuseIdentifier = identifier;
        }
        vc.view.tag = idx;
        vc.imageView.image = [UIImage imageNamed:idx % 2 ? @"live_pk_bg_1": @"WechatIMG20"];
        vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
        return vc;
    }];
    
    [pageViewController setViewControllerCountBlock:^NSInteger(__kindof JCPageViewController * _Nonnull thePageViewController) {
        return 20;
    }];
    [pageViewController setControllerDidTransitionBlock:^(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull fromViewController, __kindof UIViewController * _Nonnull toViewController) {
        NSLog(@"did transition fromViewController%@ tag:%@ toViewController:%@, tag:%@", fromViewController,@(toViewController.view.tag), toViewController, @(toViewController.view.tag));
    }];
    [pageViewController setControllerDidEndScrollTransitionBlock:^(__kindof JCPageViewController * _Nonnull thePageViewController, __kindof UIViewController * _Nonnull fromViewController, __kindof UIViewController * _Nonnull toViewController) {
        NSLog(@"did scroll end transition fromViewController%@ tag:%@ toViewController:%@, tag:%@", fromViewController,@(toViewController.view.tag), toViewController, @(toViewController.view.tag));
        NSLog(@"selected controller %@ tag:%@", thePageViewController.selectedViewController, @(thePageViewController.selectedViewController.view.tag));
    }];
    
    pageViewController.selectedIndex = 10;
    
    [self presentViewController:pageViewController animated:YES completion:NULL];

}



@end
