//
//  OptionDocTableViewCell.h
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol OptionDocCellDelegate <NSObject>

-(void)optionDocCellClickedAtIndex:(NSIndexPath*) indexPath;

@end

@interface OptionDocTableViewCell : UITableViewCell

@property(strong,nonatomic) IBOutlet UILabel* title;
@property(strong,nonatomic) IBOutlet UIButton* option;

@property(strong,nonatomic) NSIndexPath* indexPath;

@property(assign,nonatomic) id<OptionDocCellDelegate> delgate;

@end
