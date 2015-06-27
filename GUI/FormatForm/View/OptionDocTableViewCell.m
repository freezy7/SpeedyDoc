//
//  OptionDocTableViewCell.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "OptionDocTableViewCell.h"

@implementation OptionDocTableViewCell

- (void)awakeFromNib {
    // Initialization code
}


-(IBAction)optionBtnClicked:(id)sender
{
    [_delgate optionDocCellClickedAtIndex:_indexPath];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
