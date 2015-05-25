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
        _singletonManager = [[FMDBManmager alloc] initWithDatabase:@"SpeedyDoc"];
    }
    return _singletonManager;
}

-(id)initWithDatabase:(NSString*) dbName
{
    self = [super init];
    if (self) {
        // Do any additional setup after loading the view.
        NSString* str =[NSHomeDirectory() stringByAppendingString:@"/Documents"];
        NSString* strPath = [NSString stringWithFormat:@"%@/%@.db",str,dbName];
        NSLog(@"path = %@",strPath);
        //NSFileManager* fileManager = [NSFileManager defaultManager];
        //BOOL ret = [fileManager fileExistsAtPath:strPath];
        _FMbookDB = [FMDatabase databaseWithPath:strPath];
    }
    return self;
}

-(BOOL) creatTable:(NSString*) tableName
{
    /*
     第一次启动创建
     * speedydoc
       字段名        类型       主键       自增           默认值    注释
       doc_id       integer primary key autoincrement         文档id
       name         text                                      对外显示名字
       model_name   text                                      模板名字
       table_name   text                                      存储数据表名字
       ctime        integer
     
     * columnoption        app总字段表
       字段名        类型       主键       自增           默认值    注释
       option_id   integer primary key autoincrement         id
       option_ename      text                                      英文名字
       option_cname      text                                      中文名字
       option_status      text                                @"-1" 状态值  
     
     创建时生成表      加后缀参数数字（要根据speedydoc决定）
     * columnmodel     自定义模板字段表
       字段名        类型       主键       自增           默认值    注释
       id          integer primary key autoincrement         id
       option_ename      text                                      英文名字
       option_cname      text                                      中文名字
       option_index       text                                      表中所处位置
       option_type       text                                      表中所处位置
     
     * datatable        生成数据表名
       字段名        类型       主键       自增           默认值    注释
       id   integer primary key autoincrement         id
       .........   text                                      英文名字
       .........   text                                      中文名字
       ctime       integer
     */
    [_FMbookDB open];
    
    NSString* strCreateTable = @"";
    
    if([tableName isEqualToString:@"speedydoc"])
    {
        strCreateTable = @"create table if not exists speedydoc(id integer primary key autoincrement,name text,model_name text,table_name text,ctime text)";
    }
    else if ([tableName isEqualToString:@"columns"])
    {
        strCreateTable = @"create table if not exists columns(id integer primary key autoincrement,option_ename text,option_cname text,option_status text,option_type text)";
    }
    else
    {
    }
    
    BOOL ret = [_FMbookDB executeUpdate:strCreateTable];
    if (ret == YES){
        NSLog(@"table建立成功");
    }else{
        NSLog(@"table建立失败");
    }
    
    [_FMbookDB close];
    return ret;
}

-(BOOL) creatTable:(NSString*) tableName withColumnArray:(NSArray*) array
{
    [_FMbookDB open];
    
    NSString* strCreateTable = [NSString stringWithFormat:@"create table if not exists %@(id integer primary key autoincrement",tableName];
    
    for (NSString* columnStr in array) {
        strCreateTable = [strCreateTable stringByAppendingFormat:@",%@ text",columnStr];
    }
    
    strCreateTable = [strCreateTable stringByAppendingString:@")"];
    
    NSLog(@"%@",strCreateTable);
    
    BOOL ret = [_FMbookDB executeUpdate:strCreateTable];
    if (ret == YES){
        NSLog(@"自定义建立成功");
    }else{
        NSLog(@"自定义建立失败");
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

-(BOOL)insertIntoTable:(NSString*) tableName data:(NSDictionary*) data
{
    [_FMbookDB open];
    
    NSArray* keys = [data allKeys];
    NSArray* values = [data allValues];
    
    NSString* strInsert = [NSString stringWithFormat:@"insert into %@(",tableName];
    for (int i = 0; i<keys.count; i++) {
        NSString* key = [keys objectAtIndex:i];
        if (i==0) {
            strInsert = [strInsert stringByAppendingFormat:@"%@",key];
        }else{
            strInsert = [strInsert stringByAppendingFormat:@",%@",key];
        }
    }
    
    for (int i = 0; i<values.count; i++) {
        NSString* value = [values objectAtIndex:i];
        if (i==0) {
            strInsert = [strInsert stringByAppendingFormat:@")values('%@'",value];
        }else{
            strInsert = [strInsert stringByAppendingFormat:@",'%@'",value];
        }
    }
    
    strInsert = [strInsert stringByAppendingString:@")"];
    
    BOOL ret = [_FMbookDB executeUpdate:strInsert];
    [_FMbookDB close];
    if (ret == YES) {
        NSLog(@"添加成功");
    }
    return ret;

}


-(BOOL) removeDataFromTable:(NSString*) tableName ItemByIndex:(NSString*) index;
{
    [_FMbookDB open];
    NSString* strDelete = [NSString stringWithFormat: @"delete from %@ where id =%@",tableName,index];
    BOOL ret = [_FMbookDB executeUpdate:strDelete];
    [_FMbookDB close];
    if (ret  == YES) {
        NSLog(@"删除成功");
    }
    return ret;
}
/// 查询表中的list 数据
-(NSArray*) queryListFromTable:(NSString*)tableName
{
    [_FMbookDB open];
    NSString* strQuery = [NSString stringWithFormat:@"select * from %@",tableName];
    FMResultSet* set = [_FMbookDB executeQuery:strQuery];
    NSMutableArray* arrayDoc = [[NSMutableArray alloc] init];
    while ([set next] == YES)
    {
        NSDictionary* dic = [set resultDictionary];
        [arrayDoc addObject:dic];
    }
    [_FMbookDB close];
    return arrayDoc;
}
///查询sql语句
-(NSArray*) querySql:(NSString*)sql
{
    [_FMbookDB open];
    FMResultSet* set = [_FMbookDB executeQuery:sql];
    NSMutableArray* arrayDoc = [[NSMutableArray alloc] init];
    while ([set next] == YES)
    {
        NSDictionary* dic = [set resultDictionary];
        [arrayDoc addObject:dic];
    }
    [_FMbookDB close];
    return arrayDoc;
}


/// 查询数据表中 item 数量
-(NSInteger) queryCountFromTable:(NSString*) tableName
{
    [_FMbookDB open];
    NSString* strQuery = [NSString stringWithFormat:@"select count(*) as count from %@;",tableName];
    FMResultSet* set = [_FMbookDB executeQuery:strQuery];
    
    if([set next]){
        int count = [set intForColumn:@"count"];
        [_FMbookDB close];
        return count;
    }else{
        return 0;
    }
}
///查询记录中的最大id
-(NSInteger) queryMaxAutoIncrementIDFromTable:(NSString*) tableName
{
    [_FMbookDB open];
    NSString* strQuery = [NSString stringWithFormat:@"select max(id) as max_id from %@;",tableName];
    FMResultSet* set = [_FMbookDB executeQuery:strQuery];
    
    if([set next]){
        int count = [set intForColumn:@"max_id"];
        [_FMbookDB close];
        return count;
    }else{
        return 0;
    }

}

-(BOOL) updateTable:(NSString*) tableName byData:(NSDictionary*) data
{
    [_FMbookDB open];
    
    NSString* index = [data objectForKey:@"id"];
    
    NSString* name = [data objectForKey:@"option_cname"];
    NSString* type = [data objectForKey:@"option_type"];
    
    
    NSString* sql = [NSString stringWithFormat:@"update %@ set option_cname = '%@',option_type = '%@' where id = %@",tableName,name,type,index];
    
    
    BOOL ret = [_FMbookDB executeUpdate:sql];
    [_FMbookDB close];
    if (ret == YES) {
        NSLog(@"更新成功");
    }
    return ret;
}



@end
