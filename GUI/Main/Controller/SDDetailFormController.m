//
//  SDDetailFormController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/6/27.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SDDetailFormController.h"

@interface SDDetailFormController ()

@property (weak,nonatomic) IBOutlet UIView* header;

@end

@implementation SDDetailFormController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDismiss)];
    [_header addGestureRecognizer:tap];
    _header.userInteractionEnabled = YES;
}

-(void)tapDismiss
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SDHeaderAnimatedDelegate

-(UIView*) headerView
{
    return self.header;
}

-(UIView*) headerCopy:(UIView *)subView
{
    UIView* header = [[UIView alloc] initWithFrame:self.header.frame];
    
    header.backgroundColor = [UIColor colorWithRed:176/255.0 green:238/255.0 blue:229/255.0 alpha:1];
    
    return header;
}
@end
