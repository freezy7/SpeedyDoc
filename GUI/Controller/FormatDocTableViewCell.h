//
//  FormatDocTableViewCell.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/6.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FormatDocTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel* title;
@property (nonatomic,strong) IBOutlet UILabel* type;//示例或者简介，预留字段根据type判断
@property (nonatomic,strong) IBOutlet UIImageView* arrowView;
@property (nonatomic,strong) IBOutlet UIImageView* verticalLine;

@end
