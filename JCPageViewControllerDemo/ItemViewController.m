//
//  ItemViewController.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "ItemViewController.h"

@interface ItemViewController ()

@end

@implementation ItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
}

//- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
//    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
//    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
//    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
//    return [super supportedInterfaceOrientations];
//}
//
//- (BOOL)shouldAutorotate{
//    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
//    return [super shouldAutorotate];
//}

@end
