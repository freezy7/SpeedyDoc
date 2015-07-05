//
//  SpeedyDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/1.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SpeedyDocViewController.h"
#import "FormPatternViewController.h"
#import "FormatFormViewController.h"
#import "FMDBManmager.h"
#import "SpeedyDocCell.h"
#import "EditDocViewController.h"
#import "SDDetailFormController.h"
#import "SDHeaderAnimation.h"

@interface SpeedyDocViewController ()<SpeedyDocCellDelegate>
{
    NSMutableArray* _docArray;
    FMDBManmager* _fmdb;
    
    NSIndexPath* _animateIndex;
    
    SDHeaderAnimation* _transitionManager;
}

@end

@implementation SpeedyDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Speedy Doc";
    
    // 自定义转场动画
    _transitionManager = [[SDHeaderAnimation alloc] init];
    
    _fmdb = [FMDBManmager sharedManager];
    //创建数据表
    [_fmdb creatTable:@"speedydoc"];
    [_fmdb creatTable:@"columns"];
    
    NSInteger item = [_fmdb queryCountFromTable:@"columns"];
    if (item == 0) {
        NSArray* keysArr = [NSArray arrayWithObjects:OPTION_ENAME,OPTION_CNAME,OPTION_STATUS,OPTION_TYPE, nil];
        
        NSDictionary* dicDate = [NSDictionary dictionaryWithObjects:@[@"date",@"日期",@"-1",TYPE_DOC_DATE] forKeys:keysArr];
        NSDictionary* dicPhone = [NSDictionary dictionaryWithObjects:@[@"phone",@"电话",@"-1",TYPE_DOC_PHONE] forKeys:keysArr];
        NSDictionary* dicEmail = [NSDictionary dictionaryWithObjects:@[@"email",@"邮箱",@"-1",TYPE_DOC_EMAIL] forKeys:keysArr];
        NSDictionary* dicURL = [NSDictionary dictionaryWithObjects:@[@"url",@"网址",@"-1",TYPE_DOC_URL] forKeys:keysArr];
        
        [_fmdb insertIntoTable:@"columns" data:dicDate];
        [_fmdb insertIntoTable:@"columns" data:dicPhone];
        [_fmdb insertIntoTable:@"columns" data:dicEmail];
        [_fmdb insertIntoTable:@"columns" data:dicURL];
    }
    
    //从数据库中查询doc数据
    _docArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:@"speedydoc"]];
}

-(void) viewWillAppear:(BOOL)animated
{
    _docArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:@"speedydoc"]];
    [self.tableView reloadData];
}

-(void)speedyDocCellEditBtnAtIndex:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditDocSegue" sender:indexPath];
}

-(void)speedyDocCellHeaderBtnClickAtIndex:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"FormPattern" sender:indexPath];
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditDocSegue"]) {//编辑表名
        EditDocViewController* vc = segue.destinationViewController;
        NSIndexPath* indexPath = sender;
        NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
        vc.doc_id = [[dic objectForKey:@"id"] integerValue];
    }
    if ([segue.identifier isEqualToString:@"AddFormatDoc"]) {//增加一张表
        
    }
    if ([segue.identifier isEqualToString:@"FormPattern"]) {//读取一张表输入内容
        FormPatternViewController* vc = segue.destinationViewController;
        NSIndexPath* indexPath = sender;
        NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
        vc.model = [dic objectForKey:@"model_name"];
        vc.table = [dic objectForKey:@"table_name"];
    }
    if ([segue.identifier isEqualToString:@"DetailForm"]) {
        _animateIndex = [(SpeedyDocCell*)sender indexPath];
        SDDetailFormController* destination = segue.destinationViewController;
        destination.transitioningDelegate = _transitionManager;
        _transitionManager.destinationViewController = destination;
    }
    
}

#pragma mark - tableView dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _docArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strID = @"SpeedyDocCell";
    SpeedyDocCell* cell = [tableView dequeueReusableCellWithIdentifier:strID forIndexPath:indexPath];
    
    cell.background.layer.cornerRadius = 10;
    cell.background.clipsToBounds = YES;
    cell.delegate = self;
    cell.indexPath = indexPath;

    NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
    cell.name.text = [dic objectForKey:@"name"];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970:[[dic objectForKey:@"ctime"] integerValue]];
    NSDateFormatter* format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    cell.ctime.text = [format stringFromDate:date];
    
    return cell;
}

#pragma mark - tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

// 删除 插入等一系列操作
-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    //todo 删除放到以后优化增加，暂时放到编辑里面
    return NO;
}


-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

-(NSString*) tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"删除";
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
    NSLog(@"dic = %@ ",dic);
    BOOL ret = [_fmdb removeDataFromTable:@"speedydoc" ItemByIndex:[dic objectForKey:@"id"]];
    if (ret) {
        [_fmdb dropTable:[dic objectForKey:@"model_name"]];
        [_fmdb dropTable:[dic objectForKey:@"table_name"]];
        
        [_docArray removeObject:dic];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }else{
        NSLog(@"删除失败");
    }
}

#pragma mark - SDHeaderAnimatedDelegate

-(UIView*) headerView
{
    SpeedyDocCell* cell = (SpeedyDocCell*)[self tableView:self.tableView cellForRowAtIndexPath:_animateIndex];
    return cell.header;
}

-(UIView*) headerCopy:(UIView *)subView
{
    SpeedyDocCell* cell = (SpeedyDocCell*)[self tableView:self.tableView cellForRowAtIndexPath:_animateIndex];
    
//    [cell.header layoutIfNeeded];
    
    UIView* header = [[UIView alloc] initWithFrame:cell.header.frame];
    
    header.backgroundColor = [UIColor colorWithRed:176/255.0 green:238/255.0 blue:229/255.0 alpha:1];

    return header;
}

@end
