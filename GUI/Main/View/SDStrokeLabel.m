//
//  SDStrokeLabel.m
//  SpeedyDoc
//
//  Created by R_flava_Man on 16/1/29.
//  Copyright © 2016年 R_style Man. All rights reserved.
//

#import "SDStrokeLabel.h"

@interface SDStrokeLabel ()
{
    UIColor *strokeColor_;
    
    CGFloat  strokeWidth_;
}

@end

@implementation SDStrokeLabel

#pragma mark - initlize

- (id)init

{
    if(self= [super init]){
        
        strokeColor_ = [UIColor whiteColor];
        
        strokeWidth_ = 1.0f;
        
    }
    
    return self;
    
}





- (id)initWithFrame:(CGRect)frame

{
    if(self= [super initWithFrame:frame]){
        
        strokeColor_ = [UIColor whiteColor];
        
        strokeWidth_ = 1.0f;
    }
    
    return self;
    
}



- (id)initWithCoder:(NSCoder*)aDecoder

{
    
    if(self= [super initWithCoder:aDecoder]){
        
        strokeColor_= [UIColor whiteColor];
        
        strokeWidth_= 1.0f;
        
    }
    
    return self;
    
}



#pragma mark - stroke

- (void)setStrokeColor:(UIColor*)strokeColor width:(CGFloat)width

{
    
    strokeColor_ = nil;
    
    strokeColor_ = strokeColor;
    
    strokeWidth_ = width;
    
    [self setNeedsDisplay];
    
}



- (void)drawTextInRect:(CGRect)rect
{
    
    CGSize  shadowOffset = self.shadowOffset;
    
    UIColor* textColor = self.textColor;
    
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, strokeWidth_);
    
    CGContextSetLineJoin(context, kCGLineJoinRound);
    
    
    CGContextSetTextDrawingMode(context, kCGTextStroke);
    
    self.textColor = strokeColor_;
    
    [super drawTextInRect:rect];
    
    
    
    CGContextSetTextDrawingMode(context, kCGTextFill);
    
    self.textColor = textColor;
    
    self.shadowOffset = CGSizeMake(0.0f, 0.0f);
    
    [super drawTextInRect:rect];
    
    
    
    self.shadowOffset= shadowOffset;
    
}

@end
