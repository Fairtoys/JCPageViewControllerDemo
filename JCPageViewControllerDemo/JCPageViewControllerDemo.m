//
//  JCPageViewControllerDemo.m
//  JCPageViewControllerDemo
//
//  Created by Cerko on 2018/4/13.
//  Copyright © 2018年 huajiao. All rights reserved.
//

#import "JCPageViewControllerDemo.h"
#import "JCPageScrollView.h"
#import <Masonry.h>

@interface JCPageViewControllerDemo ()
@property (nonatomic, strong) JCPageScrollView *scrollView;
@end

@implementation JCPageViewControllerDemo

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.extendedLayoutIncludesOpaqueBars = YES;
    self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView *theView = [[UIView alloc] init];
    theView.tag = 0;
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(theView.tag % 2 == 0) ? @"live_pk_bg_1" : @"WechatIMG20"]];
    [theView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(theView);
    }];
    imageView.clipsToBounds = YES;
    UILabel *label = [[UILabel alloc] init];
    label.font = [UIFont systemFontOfSize:30];
    label.textColor = [UIColor whiteColor];
    [theView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(theView);
    }];
    
    label.text = [NSString stringWithFormat:@"%@",@(theView.tag)];
    self.scrollView.selectedView = theView;
    
    UIGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPanGes:)];
    [self.view addGestureRecognizer:gesture];
}

- (void)onPanGes:(UIPanGestureRecognizer *)sender{
    NSLog(@"onPanGes");
}



- (JCPageScrollView *)scrollView{
    if (!_scrollView) {
        _scrollView = [[JCPageScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
        [_scrollView.panGestureRecognizer addTarget:self action:@selector(onScrollViewPan:)];
        
        [_scrollView setViewAfterSelectedViewBlock:^UIView * _Nullable(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            if (selectedView.tag + 1 > 20) {
                return nil;
            }
            UIView *theView = [[UIView alloc] init];
            theView.tag = selectedView.tag + 1;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(theView.tag % 2 == 0) ? @"live_pk_bg_1" : @"WechatIMG20"]];
            [theView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(theView);
            }];
            imageView.clipsToBounds = YES;
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor whiteColor];
            
            [theView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(theView);
            }];
            
            label.text = [NSString stringWithFormat:@"%@",@(theView.tag)];
            
            
            return theView;
        }];
        
        [_scrollView setViewBeforeSelectedViewBlock:^UIView * _Nullable(JCPageScrollView * _Nonnull thePageScrollView, __kindof UIView * _Nonnull selectedView) {
            if (selectedView.tag - 1 < 0) {
                return nil;
            }
            UIView *theView = [[UIView alloc] init];
            theView.tag = selectedView.tag - 1;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:(theView.tag % 2 == 0) ? @"live_pk_bg_1" : @"WechatIMG20"]];
            [theView addSubview:imageView];
            [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(theView);
            }];
            imageView.clipsToBounds = YES;
            UILabel *label = [[UILabel alloc] init];
            label.font = [UIFont systemFontOfSize:30];
            label.textColor = [UIColor whiteColor];
            
            [theView addSubview:label];
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(theView);
            }];
            
            label.text = [NSString stringWithFormat:@"%@",@(theView.tag)];
            
            
            return theView;
        }];

    }
    return _scrollView;
}

- (void)onScrollViewPan:(UIPanGestureRecognizer *)panGes{
    
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
        self.scrollView.contentOffset = CGPointMake(0, size.height);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

@end
