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

///单例
+(FMDBManmager*) sharedManager;
///生成数据库
-(id)initWithDatabase:(NSString*) dbName;

///创建表
-(BOOL) creatTable:(NSString*) tableName;
///根据字段创建表
-(BOOL) creatTable:(NSString*) tableName withColumnArray:(NSArray*) array;

///插入数据
-(BOOL) addDataItem:(FormModel*) form;
///向指定数据表中插入一条数据
-(BOOL)insertIntoTable:(NSString*) tableName data:(NSDictionary*) data;


///根据index(id)删除一条数据
-(BOOL) removeDataFromTable:(NSString*) tableName ItemByIndex:(NSString*) index;

///查询list数据
-(NSArray*) queryListFromTable:(NSString*)tableName;
///查询记录行数
-(NSInteger) queryCountFromTable:(NSString*) tableName;
///查询记录中的最大id
-(NSInteger) queryMaxAutoIncrementIDFromTable:(NSString*) tableName;

///更新单条数据
-(BOOL) updateTable:(NSString*) tableName byData:(NSDictionary*) data;

@end
