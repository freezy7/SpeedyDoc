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

-(void)speedyDocCellHeaderBtnClickAtIndex:(NSIndexPath*) indexPath;

@end


@interface SpeedyDocCell : UITableViewCell

@property (weak,nonatomic) IBOutlet UILabel* name;
@property (weak,nonatomic) IBOutlet UILabel* ctime;
@property (weak,nonatomic) IBOutlet UIButton* editBtn;

@property (weak,nonatomic) IBOutlet UIView* background;
@property (weak,nonatomic) IBOutlet UIButton* header;

@property (assign,nonatomic) id<SpeedyDocCellDelegate> delegate;
@property (strong,nonatomic) NSIndexPath* indexPath;

@end
