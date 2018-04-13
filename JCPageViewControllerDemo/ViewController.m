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
    vc.view.tag = 10;
    vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
    [pageViewController setSelectedViewController:vc];
    
    [self presentViewController:pageViewController animated:YES completion:NULL];
    
}



@end
