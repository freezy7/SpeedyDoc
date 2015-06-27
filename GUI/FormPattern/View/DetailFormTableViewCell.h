//
//  DetailFormTableViewCell.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/16.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailFormTableViewCell : UITableViewCell
{
    
}

@property (strong,nonatomic) IBOutlet UIView* bgView;

@property (strong,nonatomic) NSArray* modelArray;

@property (strong,nonatomic) NSDictionary* data;

@end
