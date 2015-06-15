//
//  SpeedyDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/1.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SpeedyDocViewController.h"
#import "FormPatternViewController.h"

//#import "FormatDocViewController.h"
#import "FormatFormViewController.h"

#import "FMDBManmager.h"
#import "SpeedyDocCell.h"
#import "EditDocViewController.h"

@interface SpeedyDocViewController ()<UITableViewDelegate,UITableViewDataSource,SpeedyDocCellDelegate>
{
    NSMutableArray* _docArray;
    FMDBManmager* _fmdb;
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation SpeedyDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Speedy Doc";
    
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
    [_tableView reloadData];
}

-(void)speedyDocCellEditBtnAtIndex:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"EditDocSegue" sender:indexPath];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"EditDocSegue"]) {
        EditDocViewController* vc = segue.destinationViewController;
        NSIndexPath* indexPath = sender;
        NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
        vc.doc_id = [[dic objectForKey:@"id"] integerValue];
    }

    if ([segue.identifier isEqualToString:@"AddFormatDoc"]) {
        
        
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
    SpeedyDocCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpeedyDocCell" owner:self options:nil] lastObject];
    }
    
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
    NSDictionary* dic = [_docArray objectAtIndex:indexPath.row];
    NSString* model = [dic objectForKey:@"model_name"];
    NSString* table = [dic objectForKey:@"table_name"];
    FormPatternViewController* formPattern = [[FormPatternViewController alloc] initWithNibName:@"FormPatternViewController" bundle:nil];
    
    formPattern.model = model;
    formPattern.table = table;
    
    [self.navigationController pushViewController:formPattern animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


-(void)addPressed:(UIButton*) btn
{


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
