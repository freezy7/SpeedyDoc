//
//  OptionDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/9.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "OptionDocViewController.h"
#import "ColumnOption.h"

@interface OptionDocViewController ()<UITableViewDataSource,UITableViewDelegate>
{
    NSMutableArray* _dataArray;
    NSMutableArray* _selectedArray;
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation OptionDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择字段";
    
    // 从 datamodel 获取数据
    ColumnOption* column = [[ColumnOption alloc] init];
    _dataArray = [NSMutableArray arrayWithArray:[column columnOption]];
    _selectedArray = [[NSMutableArray alloc] init];
    
    _tableView.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"data = %@",_dataArray);
    [_tableView reloadData];
}

#pragma mark - tableView datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _dataArray.count;
    }else
    {
        return _selectedArray.count;
    }
    
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strID = @"commonCell";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
    }
    if(indexPath.section == 0)
    {
        NSDictionary* dic = [_dataArray objectAtIndex:indexPath.row];
        cell.textLabel.text = [dic objectForKey:OPTION_CNAME];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else// ==1
    {
        NSDictionary* dic = [_selectedArray objectAtIndex:indexPath.row];

        cell.textLabel.text = [dic objectForKey:OPTION_CNAME];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor lightGrayColor];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
        //删除selected 数组中得，添加到显示数组中得
        [self deleteSelectedOptionByFromIndex:_fromIndex];
        
        NSString* strIndex = [NSString stringWithFormat:@"%ld",_fromIndex];
        
        //点击的时候替换数组数据
        NSMutableDictionary* dic = [_dataArray objectAtIndex:indexPath.row];
        [dic setObject:strIndex forKey:OPTION_STATUS];
        
        // 已选数组添加数据
        [_selectedArray addObject:dic];
        //展示数组删除数据
        [_dataArray removeObject:dic];
        
        
        [_delegate callBackColumnOption:dic index:_fromIndex];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
    }
    
}

-(UIView*) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UILabel* lab = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 20)];
        lab.text = @"已选字段";
        return lab;
    }
    else
    {
        return nil;
    }
}

#pragma mark - 当添加字段列表删除一行时触发 或者点击的时候替换的

-(void) deleteSelectedOptionByFromIndex:(NSInteger) index
{
    NSString* strIndex = [NSString stringWithFormat:@"%ld",index];
    
    NSMutableArray* selectedArr = [NSMutableArray arrayWithArray:_selectedArray];
    
    for (NSMutableDictionary* dic in selectedArr) {
        // 排除formIndex 已经对应的item
        NSString* status = [dic objectForKey:OPTION_STATUS];
        if ([status isEqualToString:strIndex]) {
            [dic setObject:@"-1" forKey:OPTION_STATUS];
            //添加到显示的数组
            [_dataArray addObject:dic];
            // 如果已经选择的数组中有对应的 fromIndex 将其赋为初始值并删除
            [_selectedArray removeObject:dic];
        }
    }
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
