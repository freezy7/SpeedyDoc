//
//  FormPatternViewController.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "XLFormViewController.h"

@interface FormPatternViewController : XLFormViewController

///模板所在数据库的名字
@property(strong,nonatomic) NSString* model;
///数据存储对应的数据库表名
@property(strong,nonatomic) NSString* table;

@end
