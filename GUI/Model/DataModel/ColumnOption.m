//
//  ColumnOption.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/9.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "ColumnOption.h"

@implementation ColumnOption

-(id) init
{
    self = [super init];
    if (self) {
    
    }
    return self;
}

-(NSArray*)columnOption
{
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    
    NSArray* cNmae = [self cName];
    NSArray* eName = [self eName];
    
    for (int i = 0; i<cNmae.count; i++) {
        // 生成包含中文字名显示，和英文字段的字典，以及选中的status
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjects:@[[cNmae objectAtIndex:i],[eName objectAtIndex:i],@"-1"] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_STATUS]];
        
        [arr addObject:dic];
    }
    
    return arr;
}

-(NSArray*)cName
{
    NSArray* arr = [NSArray arrayWithObjects:@"姓名",@"性别",@"年龄",@"日期",@"手机号", nil];
    return arr;
}

-(NSArray*)eName
{
    NSArray* arr = [NSArray arrayWithObjects:@"name",@"gender",@"age",@"date",@"mobile", nil];
    return arr;
}

@end
