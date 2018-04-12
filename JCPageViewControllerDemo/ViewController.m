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




@end
