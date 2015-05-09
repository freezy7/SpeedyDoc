//
//  ColumnOption.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/9.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#define OPTION_CNAME @"option_cname"
#define OPTION_ENAME @"option_ename"
#define OPTION_STATUS @"option_status"
#define OPTION_INDEX @"option_index"


#import <Foundation/Foundation.h>

@interface ColumnOption : NSObject

/*
 *获取数据库列数据的排列和位置
 */
-(NSArray*)columnOption;

@end
