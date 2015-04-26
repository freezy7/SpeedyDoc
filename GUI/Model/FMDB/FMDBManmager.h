//
//  FMDBManmager.h
//  0702 FMBD
//
//  Created by R-style Man on 14-7-3.
//  Copyright (c) 2014年 DC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMDB.h"
@class FormModel;
@interface FMDBManmager : NSObject

@property (retain,nonatomic) FMDatabase* FMbookDB;
+(FMDBManmager*) sharedManager;
-(BOOL) creatDatabase:(NSString*) dbNmae;
-(BOOL) addDataItem:(FormModel*) form;
-(BOOL) removeDataItemByIndex:(NSInteger) index;
-(NSArray*) queryForm;
-(BOOL) updateBookItem:(NSInteger) index byItem:(FormModel*) form;

@end
