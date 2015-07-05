//
//  SpeedyDocCell.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SpeedyDocCell.h"

@implementation SpeedyDocCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(IBAction)editBtnPressed:(id)sender
{
    [_delegate speedyDocCellEditBtnAtIndex:_indexPath];
}

-(IBAction)headerBtnClicked:(id)sender
{
    [_delegate speedyDocCellHeaderBtnClickAtIndex:_indexPath];
}

@end
