//
//  ItemViewController.m
//  JCPageViewControllerDemo
//
//  Created by huajiao on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "ItemViewController.h"
#import "JCPageViewController.h"
#import "OverlayViewController.h"


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
- (IBAction)onClickBtn:(id)sender {
    ItemViewController *vc = [[ItemViewController alloc] init];
    vc.view.tag = 0;
    vc.label.text = [NSString stringWithFormat:@"%@", @(vc.view.tag)];
    [self.jc_thePageViewController setSelectedViewController:vc];
}
- (IBAction)onClickCloseBtn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}
- (IBAction)onClickChangeScrollOrientationBtn:(id)sender {
    self.jc_thePageViewController.navigationOrientationType = (JCPageViewControllerNavigationOrientationHorizontal == self.jc_thePageViewController.navigationOrientationType ? JCPageViewControllerNavigationOrientationVertical : JCPageViewControllerNavigationOrientationHorizontal);
}
- (IBAction)onClickEnableScrollBtn:(id)sender {
    self.jc_thePageViewController.scrollEnabled = !self.jc_thePageViewController.scrollEnabled;
//    [self.jc_thePageViewController setCanScrollBlock:^BOOL(__kindof JCPageViewController * _Nonnull thePageViewController) {
//        return NO;
//    }];
    
}
- (IBAction)onClickOverlayBtn:(id)sender {
    OverlayViewController *vc = [[OverlayViewController alloc] init];
    [self presentViewController:vc animated:YES completion:NULL];
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

- (void)dealloc{
    NSLog(@"self %@, tag:%@  %@", self, @(self.view.tag), NSStringFromSelector(_cmd));
}

@end
