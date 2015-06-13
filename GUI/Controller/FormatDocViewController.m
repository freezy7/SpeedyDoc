//
//  FormatDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/6.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "FormatDocViewController.h"
#import "FormatDocTableViewCell.h"
#import "OptionDocViewController.h"
#import "FMDBManmager.h"

@interface FormatDocViewController ()<UITableViewDataSource,UITableViewDelegate,OptionDocDelegate>
{
    NSMutableArray* _formatArray;
    OptionDocViewController* _option;
    FMDBManmager* _fmdb;
    
    NSInteger _insertCount;
}

@property (strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation FormatDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"添加字段";
    
    // 加载数据库
    _fmdb = [FMDBManmager sharedManager];
    
    // 定义navBar 右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    
    _insertCount = 0;
    
    // tableView 初始化数据
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjects:@[@"",@"",[NSString stringWithFormat:@"%ld",_insertCount],@""] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_INDEX,OPTION_TYPE]];
    
    NSMutableDictionary* dicAdd = [NSMutableDictionary dictionaryWithObjects:@[@"",@"",@"",@""] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_INDEX,OPTION_TYPE]];
    
    _formatArray = [[NSMutableArray alloc] initWithObjects:dic,dicAdd, nil];
    _tableView.tableFooterView = [[UIView alloc] init];
    [_tableView setEditing:YES animated:YES];
    _tableView.allowsSelectionDuringEditing = YES;
    
    // 初始化选项面板内容
    _option = [[OptionDocViewController alloc] initWithNibName:@"OptionDocViewController" bundle:nil];
    _option.delegate = self;
}

-(void)alertWithMessage:(NSString*)msg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}


// 保存自定义表单
-(void)savePressed:(UIBarButtonItem*) btn
{
    /*
     一、此时数据库创建两张表单
     1、字段表单 ename cname index  表单名字为ColumnOption+index(首页还要有个表单存储字段表单名字)
     2、数据存储表单 字典中的option_ename 字段 加一个自增ID(首页也要存储这个表单的名字)
     二、将上述两个表单的名字，创建时间插入首页的数据库表单
     */
    btn.enabled = NO;
    NSMutableArray* formatArr = [NSMutableArray arrayWithArray:_formatArray];
    [formatArr removeLastObject];
    if(!formatArr.count) {
        [self alertWithMessage:@"必须有表单数据才能保存"];
        btn.enabled = YES;
        return;
    }
    
    for (NSDictionary* dic in formatArr) {
        NSString* type = [dic objectForKey:OPTION_TYPE];
        if (!type||[type isEqualToString:@""]) {
            [self alertWithMessage:@"请选择表单类型"];
            btn.enabled = YES;
            return;
        }
    }
    NSLog(@"formatArray = %@",formatArr);
    
    NSInteger count = [_fmdb queryCountFromTable:@"speedydoc"];
    
    NSString* modelname = [NSString stringWithFormat:@"model_%ld",count];
    NSString* dataTableName = [NSString stringWithFormat:@"table_%ld",count];
    
    //创建对应的模板表
    [_fmdb creatTable:modelname withColumnArray:@[OPTION_ENAME,OPTION_CNAME,OPTION_INDEX,OPTION_TYPE]];
    
    
    
    
    //根据所选的字段创建数据存储表
    NSMutableArray* columnArr = [[NSMutableArray alloc] init];
    for (int i = 0 ; i < formatArr.count; i++) {
        NSMutableDictionary* dic = [formatArr objectAtIndex:i];
        //向模板中插入数据 name index type  考虑数据多可以开一个线程
        [dic setObject:@(i) forKey:OPTION_INDEX];
        
        [_fmdb insertIntoTable:modelname data:dic];
    
        // 获取英文名字段 创建数据存储表
        NSString* str = [dic objectForKey:OPTION_ENAME];
        [columnArr addObject:str];
    }
    NSLog(@"colum = %@",columnArr);
    
    // 独自添加一个ctime 时间戳
    [columnArr addObject:@"ctime"];
    [_fmdb creatTable:dataTableName withColumnArray:columnArr];
    
    //向首页的speedydoc表中插入数据
    
    NSDate* date = [NSDate date];
    NSString* ctime = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
    
    NSDictionary* dic = [NSDictionary dictionaryWithObjects:@[modelname,dataTableName,dataTableName,ctime] forKeys:@[@"model_name",@"table_name",@"name",@"ctime"]];
    
    BOOL ret = [_fmdb insertIntoTable:@"speedydoc" data:dic];
    if (ret) {
        btn.enabled = YES;
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        btn.enabled = YES;
        NSLog(@"数据插入失败");
    }
    
}

#pragma mark - optionDoc delegate

-(void)callBackColumnOption:(NSDictionary *)option index:(NSInteger)index
{
    //NSLog(@"index = %ld dic = %@",index,option);
    // index 为字典中的option_index 值
    
    for (NSMutableDictionary* dic in _formatArray) {
        NSString* optionIndex = [dic objectForKey:OPTION_INDEX];
        if ([optionIndex integerValue] == index &&
            ![optionIndex isEqualToString:@""]) {
            [dic setObject:[option objectForKey:OPTION_CNAME] forKey:OPTION_CNAME];
            [dic setObject:[option objectForKey:OPTION_ENAME] forKey:OPTION_ENAME];
            [dic setObject:[option objectForKey:OPTION_TYPE] forKey:OPTION_TYPE];
        }
    }
    
    [_tableView reloadData];
}

#pragma mark - tableView dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _formatArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strID = @"FormatDocTableViewCell";
    FormatDocTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"FormatDocTableViewCell" owner:self options:nil] lastObject];
    }
    if (indexPath.row == _formatArray.count-1){
        
        cell.title.text = @"新增一行";
        cell.arrowView.hidden = YES;
        cell.verticalLine.hidden = YES;
    }
    else
    {
        NSDictionary* dic = [_formatArray objectAtIndex:indexPath.row];
        cell.title.text = [dic objectForKey:OPTION_CNAME];
        cell.arrowView.hidden = NO;
        cell.verticalLine.hidden = NO;
    }
    return cell;
}

#pragma mark - tableView delegate

// 点击最后一行或者添加按钮时 向formatArray倒数第二行添加空数据加一个index
-(void) insertObjectToFormatArrayAtIndex:(NSInteger) index
{
    _insertCount++;
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjects:@[@"",@"",[NSString stringWithFormat:@"%ld",_insertCount],@""] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_INDEX,OPTION_TYPE]];
    [_formatArray insertObject:dic atIndex:index];
    
    //NSLog(@"%@",_formatArray);
    [_tableView reloadData];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == _formatArray.count-1){
        [self insertObjectToFormatArrayAtIndex:indexPath.row];
    }
    else
    {
        NSDictionary* dic = [_formatArray objectAtIndex:indexPath.row];
        NSString* fromIndex = [dic objectForKey:OPTION_INDEX];
        _option.fromIndex = [fromIndex integerValue];
        [self.navigationController pushViewController:_option animated:YES];
    }
}


//删除或者新增 cell 时触发的事件
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        [self insertObjectToFormatArrayAtIndex:indexPath.row];
    }
    else if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSDictionary* dic = [_formatArray objectAtIndex:indexPath.row];
        [_formatArray removeObject:dic];
        NSString* fromIndex = [dic objectForKey:OPTION_INDEX];
        [_option deleteSelectedOptionByFromIndex:[fromIndex integerValue]];
        [_tableView reloadData];
        //NSLog(@"%@",_formatArray);
    }
}

// 移动行
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (destinationIndexPath.row == _formatArray.count-1) {
        [_tableView reloadData];
    }
    else
    {
        //[_formatArray exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
        NSMutableDictionary* temp = [NSMutableDictionary dictionaryWithDictionary:[_formatArray objectAtIndex:sourceIndexPath.row]];
        [_formatArray removeObjectAtIndex:sourceIndexPath.row];
        
        [_formatArray insertObject:temp atIndex:destinationIndexPath.row];
        
        NSLog(@"arr = %@",_formatArray);
        NSLog(@"si %ld,de %ld",sourceIndexPath.row,destinationIndexPath.row);
    }
    
    
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 最后一行为添加，其余的都可以删除
    if (indexPath.row == _formatArray.count-1){
        return UITableViewCellEditingStyleInsert;
    }
    return UITableViewCellEditingStyleDelete;
}

-(NSString*)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

-(BOOL) tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 当行数小于3的时候，最后一行 不能移动
    if (indexPath.row == _formatArray.count-1||_formatArray.count<3) {
        return NO;
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
