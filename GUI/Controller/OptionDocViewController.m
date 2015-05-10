//
//  OptionDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/9.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "OptionDocViewController.h"
#import "OptionDocTableViewCell.h"
#import "FMDBManmager.h"

@interface OptionDocViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,OptionDocCellDelegate>
{
    FMDBManmager* _fmdb;
    
    NSMutableArray* _dataArray;    // 未选字段数据
    NSMutableArray* _selectedArray;// 已选字段数据
    NSMutableArray* _optionArray;
    NSMutableDictionary* _optionDictionary;  // type 类型数据
    NSIndexPath* _optionClickIndexPath;// cell 按钮选中的index path
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation OptionDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择字段";
    
    // 从 datamodel 获取数据
    _fmdb = [FMDBManmager sharedManager];
    _dataArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:@"columnoption"]];
    _selectedArray = [[NSMutableArray alloc] init];
    _optionArray = [[NSMutableArray alloc] initWithObjects:@"单行文本",@"多行文本",@"日期",@"数字",@"纯整数",@"纯小数",@"网址",@"电话",@"邮箱", nil];
    _optionDictionary = [[NSMutableDictionary alloc] initWithObjects:_optionArray forKeys:@[TYPE_DOC_TEXTFIELD,TYPE_DOC_TEXTVIEW,TYPE_DOC_DATE,TYPE_DOC_NUMBER,TYPE_DOC_INTGER,TYPE_DOC_DECIMAL,TYPE_DOC_URL,TYPE_DOC_PHONE,TYPE_DOC_EMAIL]];
    
    _tableView.tableFooterView = [[UIView alloc] init];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"data = %@",_dataArray);
    [_tableView reloadData];
}

#pragma mark - optionDoc cell delegate

-(void)optionDocCellClickedAtIndex:(NSIndexPath*)indexPath
{
    _optionClickIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];//尝试能不能copy
    UIActionSheet* actionSheet =[[UIActionSheet alloc] initWithTitle:@"字段类型" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"单行文本",@"多行文本",@"日期",@"数字",@"纯整数",@"纯小数",@"网址",@"电话",@"邮箱", nil];
    [actionSheet showInView:self.view];
}

#pragma mark - actionSheet delegate

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString* selectedType;
    switch (buttonIndex) {
        case 0:
            selectedType = TYPE_DOC_TEXTFIELD;
            break;
        case 1:
            selectedType = TYPE_DOC_TEXTVIEW;
            break;
        case 2:
            selectedType = TYPE_DOC_DATE;
            break;
        case 3:
            selectedType = TYPE_DOC_NUMBER;
            break;
        case 4:
            selectedType = TYPE_DOC_INTGER;
            break;
        case 5:
            selectedType = TYPE_DOC_DECIMAL;
            break;
        case 6:
            selectedType = TYPE_DOC_URL;
            break;
        case 7:
            selectedType = TYPE_DOC_PHONE;
            break;
        case 8:
            selectedType = TYPE_DOC_EMAIL;
            break;
        default:
            break;
    }
    
    NSLog(@"index = %@",selectedType);
    
    if (selectedType) {
        if (_optionClickIndexPath.section == 0) {
            NSMutableDictionary* dic = [_dataArray objectAtIndex:_optionClickIndexPath.row];
            [dic setObject:selectedType forKey:OPTION_TYPE];
            
        }else if (_optionClickIndexPath.section == 1)
        {
            NSMutableDictionary* dic = [_selectedArray objectAtIndex:_optionClickIndexPath.row];
            [dic setObject:selectedType forKey:OPTION_TYPE];
        }
        [_tableView reloadData];
    }
    
    
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
    static NSString* strID = @"OptionDocTableViewCell";
    OptionDocTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if(cell == nil)
    {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"OptionDocTableViewCell" owner:self options:nil] lastObject];
    }
    
    cell.delgate = self;
    cell.indexPath = indexPath;
    if(indexPath.section == 0)
    {
        NSDictionary* dic = [_dataArray objectAtIndex:indexPath.row];
        cell.title.text = [dic objectForKey:OPTION_CNAME];
        NSString* title = [_optionDictionary objectForKey:[dic objectForKey:OPTION_TYPE]];
        [cell.option setTitle:title forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else// ==1
    {
        NSDictionary* dic = [_selectedArray objectAtIndex:indexPath.row];
        NSString* title = [_optionDictionary objectForKey:[dic objectForKey:OPTION_TYPE]];
        [cell.option setTitle:title forState:UIControlStateNormal];
        cell.option.enabled = NO;//开启要注意对上一层值得改变，要变动，暂不处理
        cell.title.text = [dic objectForKey:OPTION_CNAME];
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
