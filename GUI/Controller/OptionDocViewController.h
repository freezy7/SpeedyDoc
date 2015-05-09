//
//  OptionDocViewController.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/9.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionDocDelegate <NSObject>

-(void)callBackColumnOption:(NSDictionary*)option index:(NSInteger) index;

@end

@interface OptionDocViewController : UIViewController

@property (assign,nonatomic) NSInteger fromIndex;
@property (strong,nonatomic) id<OptionDocDelegate> delegate;


///删除对应添加字段列表的数据
-(void) deleteSelectedOptionByFromIndex:(NSInteger) index;


@end
