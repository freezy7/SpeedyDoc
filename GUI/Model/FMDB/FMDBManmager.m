//
//  FMDBManmager.m
//  0702 FMBD
//
//  Created by R-style Man on 14-7-3.
//  Copyright (c) 2014年 DC. All rights reserved.
//

#import "FMDBManmager.h"
#import "FormModel.h"

static FMDBManmager* _singletonManager = nil;
@interface FMDBManmager ()

@end

@implementation FMDBManmager
+(FMDBManmager*) sharedManager
{
    if (_singletonManager  == nil) {
        _singletonManager = [[FMDBManmager alloc] init];
    }
    return _singletonManager;
}
-(BOOL) creatDatabase:(NSString*) dbNmae
{
    // Do any additional setup after loading the view.
    NSString* str =[NSHomeDirectory() stringByAppendingString:@"/Documents"];
    NSString* strPath = [NSString stringWithFormat:@"%@/%@.db",str,dbNmae];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    BOOL ret = [fileManager fileExistsAtPath:strPath];
    if (ret)
    {
        NSLog(@"数据库已存在");
        //return NO;
    }
    _FMbookDB = [FMDatabase databaseWithPath:strPath];
    [_FMbookDB open];
    NSString* strCreateTable = @"create table if not exists bookSheet(id integer primary key autoincrement,name text,email text,number text,integer text,decimal text,password text, phone text,url text,textView text,notes text)";
    ret = [_FMbookDB executeUpdate:strCreateTable];
    if (ret == YES)
    {
        NSLog(@"table建立成功");
    }
    else
    {
        NSLog(@"table建立失败");
    }
    
    [_FMbookDB close];
    return ret;
}

-(BOOL) addDataItem:(FormModel*) form
{
    [_FMbookDB open];
    NSString* strInsert = @"insert into bookSheet(name,email,number,integer,decimal,password,phone,url,textView,notes) values(?,?,?,?,?,?,?,?,?,?)";
    BOOL ret = [_FMbookDB executeUpdate:
                strInsert,
                form.name,
                form.email,
                form.number,
                form.integer,
                form.decimal,
                form.password,
                form.phone,
                form.url,
                form.textView,
                form.notes
                ];
    [_FMbookDB close];
    if (ret == YES) {
        NSLog(@"添加成功");
    }
    return ret;
}
-(BOOL) removeDataItemByIndex:(NSInteger) index
{
    [_FMbookDB open];
    NSString* strDelete = [NSString stringWithFormat: @"delete from bookSheet where index =%ld",index];
    BOOL ret = [_FMbookDB executeUpdate:strDelete];
    [_FMbookDB close];
    if (ret  == YES) {
        NSLog(@"删除成功");
    }
    return ret;
}
-(NSArray*) queryForm
{
    [_FMbookDB open];
    NSString* strQuery = @"select * from bookSheet";
    FMResultSet* set = [_FMbookDB executeQuery:strQuery];
    NSMutableArray* arrayBook = [[NSMutableArray alloc] init];
    while ([set next] == YES)
    {
        NSString* userID = [set stringForColumnIndex:0];
        NSString* name = [set stringForColumnIndex:1];
        NSString* email = [set stringForColumnIndex:2];
        NSString* number = [set stringForColumnIndex:3];
        NSString* integer = [set stringForColumnIndex:4];
        NSString* decimal = [set stringForColumnIndex:5];
        NSString* password = [set stringForColumnIndex:6];
        NSString* phone = [set stringForColumnIndex:7];
        NSString* url = [set stringForColumnIndex:8];
        NSString* textView = [set stringForColumnIndex:9];
        NSString* notes = [set stringForColumnIndex:10];
        
        NSArray* array = [NSArray arrayWithObjects:userID,name,email,number,integer,decimal,password,phone,url,textView,notes, nil];
        [arrayBook addObject:array];
    }
    [_FMbookDB close];
    return arrayBook;
}

-(BOOL) updateBookItem:(NSInteger) index byItem:(FormModel*) form
{
    [_FMbookDB open];
    BOOL rev = [self removeDataItemByIndex:index];
    BOOL add = [self addDataItem:form];
    if (rev && add)
    {
        NSLog(@"更新成功");
    }
    else
    {
        NSLog(@"更新失败");
    }
    [_FMbookDB close];
    return (rev && add);
}



@end
