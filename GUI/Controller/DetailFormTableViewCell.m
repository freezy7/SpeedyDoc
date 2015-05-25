//
//  DetailFormTableViewCell.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/16.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "DetailFormTableViewCell.h"

@interface CellLabelView : UIView

@property (nonatomic,strong) UILabel* title;

@property (nonatomic,strong) UILabel* detail;

-(id)initWithFrame:(CGRect)frame;

@end

@implementation CellLabelView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

-(void)initialize
{
    _title = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 100, self.frame.size.height-10)];
    _detail = [[UILabel alloc] initWithFrame:CGRectMake(130, 5, self.frame.size.width-140, self.frame.size.height - 10)];
    
    [self addSubview:_title];
    [self addSubview:_detail];
}

@end

@implementation DetailFormTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

-(void)setModelArray:(NSArray *)modelArray
{
    _modelArray = modelArray;
    
    for (int i = 0;i<_modelArray.count;i++) {
        NSDictionary* dic = [_modelArray objectAtIndex:i];
        NSString* cname = [dic objectForKey:OPTION_CNAME];
        CellLabelView* celldetail = [[CellLabelView alloc] initWithFrame:CGRectMake(0, 0 + i*32, self.bgView.frame.size.width, 30)];
        celldetail.title.text = cname;
        
        celldetail.tag = [[dic objectForKey:OPTION_INDEX] integerValue] + 100;
        
        [_bgView addSubview:celldetail];
    }
    
}

-(void)setData:(NSDictionary *)data
{
    for (NSDictionary* dic in _modelArray) {
        NSString* index = [dic objectForKey:OPTION_INDEX];
        NSString* ename = [dic objectForKey:OPTION_ENAME];
        NSString* detailStr = [data objectForKey:ename];
        if ([ename isEqualToString:@"date"]) {
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[detailStr integerValue]];
            NSDateFormatter* format = [[NSDateFormatter alloc] init];
            [format setDateFormat:@"yyyy-MM-dd"];
            detailStr = [format stringFromDate:date];
        }
        CellLabelView* cellView = (CellLabelView*)[_bgView viewWithTag:[index integerValue] +100];
        cellView.detail.text = detailStr;
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
