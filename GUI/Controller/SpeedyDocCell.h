//
//  SpeedyDocCell.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SpeedyDocCellDelegate <NSObject>

-(void)speedyDocCellEditBtnAtIndex:(NSIndexPath*) indexPath;

@end

@interface SpeedyDocCell : UITableViewCell

@property (strong,nonatomic) IBOutlet UILabel* name;
@property (strong,nonatomic) IBOutlet UILabel* ctime;
@property (strong,nonatomic) IBOutlet UIButton* detailBtn;

@property (assign,nonatomic) id<SpeedyDocCellDelegate> delegate;
@property (strong,nonatomic) NSIndexPath* indexPath;

@end
