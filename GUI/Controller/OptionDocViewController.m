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

@interface OptionDocViewController ()<UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,OptionDocCellDelegate,UITextFieldDelegate>
{
    FMDBManmager* _fmdb;
    
    UITextField* _tempTextField;
    
    NSMutableArray* _dataArray;    // 数据库字段总数据
    NSMutableArray* _constArray;   // 初始化固定的数组
    NSMutableArray* _varArray;     // section2 单行条目可以修改的
    NSMutableArray* _addArray;     // 编辑时增加数据的数组
    NSMutableArray* _removeArray;  // 编辑时删除的数据库的数组
    
    NSMutableArray* _optionArray;
    NSMutableDictionary* _optionDictionary;  // type 类型数据
    NSIndexPath* _optionClickIndexPath;// cell 按钮选中的index path
    
    NSInteger _insertCount;
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation OptionDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择字段";
    
    // 定义navBar 右侧按钮
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    
    // 从 datamodel 获取数据
    
    _constArray = [[NSMutableArray alloc] init];
    _varArray = [[NSMutableArray alloc] init];
    _addArray = [[NSMutableArray alloc] init];
    _removeArray = [[NSMutableArray alloc] init];
    
    // 加载初始化数据
    [self setUpColumnsArray];
    
    
    _optionArray = [[NSMutableArray alloc] initWithObjects:@"单行文本",@"多行文本",@"日期",@"数字",@"纯整数",@"纯小数",@"网址",@"电话",@"邮箱", nil];
    _optionDictionary = [[NSMutableDictionary alloc] initWithObjects:_optionArray forKeys:@[TYPE_DOC_TEXTFIELD,TYPE_DOC_TEXTVIEW,TYPE_DOC_DATE,TYPE_DOC_NUMBER,TYPE_DOC_INTGER,TYPE_DOC_DECIMAL,TYPE_DOC_URL,TYPE_DOC_PHONE,TYPE_DOC_EMAIL]];
    
    _tableView.tableFooterView = [[UIView alloc] init];
}


// 初始化列表数据
-(void) setUpColumnsArray
{
    _fmdb = [FMDBManmager sharedManager];
    _dataArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:@"columns"]];
    // 前四行的的值是固定的不可变的
    // 从第四行以后开始取值赋给 _varArray
    [_constArray removeAllObjects];
    [_varArray removeAllObjects];
    for (int i = 0; i<_dataArray.count; i++) {
        if (i<4) {
            [_constArray addObject:[_dataArray objectAtIndex:i]];
        }
        else
        {
            [_varArray addObject:[_dataArray objectAtIndex:i]];
        }
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedyDocKeyBoardChange:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(speedyDocKeyBoardChangeHide:) name:UIKeyboardWillHideNotification object:nil];

    NSLog(@"data = %@",_dataArray);
    [_tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_tempTextField resignFirstResponder];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}


-(void)editPressed:(UIBarButtonItem*) btn
{
    _insertCount = 0;
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjects:@[@"3",@"3",@"-1",@"3"] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_STATUS,OPTION_TYPE]];
    [_varArray addObject:dic];
    [_tableView reloadData];
    [_tableView setEditing:YES animated:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(donePressed:)];
}

-(void)donePressed:(UIBarButtonItem*) btn
{
    [_tempTextField resignFirstResponder];
    NSInteger max_id = [_fmdb queryMaxAutoIncrementIDFromTable:@"columns"];
    
    // 新增的数据
    for (NSMutableDictionary* dic in _addArray) {//考虑开启线程
        max_id++;
        [dic setObject:[NSString stringWithFormat:@"name_%ld",max_id] forKey:@"option_ename"];
        [_fmdb insertIntoTable:@"columns" data:dic];
    }
    [_addArray removeAllObjects];//插入完成删除数组
    
    
    // 删除的数据
    for (NSMutableDictionary* dic in _removeArray) {
        NSString* index = [dic objectForKey:@"id"];
        [_fmdb removeDataFromTable:@"columns" ItemByIndex:index];
    }
    [_removeArray removeAllObjects];
    
    // 改名字的时候更新数据  现在为全局更新，以后要做成根据需要更新
    [_varArray removeLastObject];
    for (NSDictionary* dic in _varArray) {
        if ([dic objectForKey:@"id"]) {
            [_fmdb updateTable:@"columns" byData:dic];
        }
    }
    
    // 重新查询数据
    
    [self setUpColumnsArray];
    
    [_tableView setEditing:NO animated:YES];
    [_tableView reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editPressed:)];
    
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
           
            
        }else if (_optionClickIndexPath.section == 1)
        {
            NSMutableDictionary* dic = [_varArray objectAtIndex:_optionClickIndexPath.row];
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
        return _constArray.count;
    }else
    {
        return _varArray.count;
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
        NSDictionary* dic = [_constArray objectAtIndex:indexPath.row];
        cell.title.text = [dic objectForKey:OPTION_CNAME];
        cell.title.hidden = NO;
        cell.editField.hidden = YES;
        NSString* title = [_optionDictionary objectForKey:[dic objectForKey:OPTION_TYPE]];
        cell.option.hidden = NO;
        cell.option.enabled = NO;
        [cell.option setTitle:title forState:UIControlStateNormal];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.backgroundColor = [UIColor whiteColor];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else// ==1
    {
        
        cell.editField.delegate = self;
        NSDictionary* dic = [_varArray objectAtIndex:indexPath.row];
        NSString* title = [_optionDictionary objectForKey:[dic objectForKey:OPTION_TYPE]];
        if (tableView.editing) {
            if (indexPath.row == _varArray.count - 1) {
                cell.option.hidden = YES;
                cell.editField.hidden = YES;
                cell.title.hidden = NO;
                cell.title.text = @"添加";
            }else{
                cell.title.hidden = YES;
                cell.editField.hidden = NO;
                cell.option.hidden = NO;
                cell.option.enabled = YES;
                cell.editField.text = [dic objectForKey:OPTION_CNAME];
            }
        }else{
            cell.title.hidden = NO;
            cell.editField.hidden = YES;
            cell.option.hidden = NO;
            cell.option.enabled = NO;
            cell.title.text = [dic objectForKey:OPTION_CNAME];
        }
        
        [cell.option setTitle:title forState:UIControlStateNormal];
        
        
//        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.backgroundColor = [UIColor lightGrayColor];
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    return cell;
}

#pragma mark - tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        
        //删除selected 数组中得，添加到显示数组中得
//        [self deleteSelectedOptionByFromIndex:_fromIndex];
//        
//        NSString* strIndex = [NSString stringWithFormat:@"%ld",_fromIndex];
        
        //点击的时候替换数组数据
        NSMutableDictionary* dic = [_constArray objectAtIndex:indexPath.row];
//        [dic setObject:strIndex forKey:OPTION_STATUS];
//        
//        // 已选数组添加数据
//        [_selectedArray addObject:dic];
//        //展示数组删除数据
//        [_dataArray removeObject:dic];
        
        
        [_delegate callBackColumnOption:dic index:_fromIndex];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        
    }
    
}

// 点击最后一行或者添加按钮时 向_varArray倒数第二行添加空数据加一个index
-(void) insertObjectToVarArrayAtIndex:(NSInteger) index
{
    NSString* ename = [NSString stringWithFormat:@"name_%ld",_insertCount];
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjects:@[ename,ename,@"-1",TYPE_DOC_TEXTFIELD] forKeys:@[OPTION_CNAME,OPTION_ENAME,OPTION_STATUS,OPTION_TYPE]];
    //显示数组，用于更新tableview（index不考虑）
    [_varArray insertObject:dic atIndex:index];
    
    // 暂存数据数组 用于数据库的增加
    [_addArray addObject:dic];
    
    _insertCount++;
    [_tableView reloadData];
    NSLog(@"%@",_addArray);
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleInsert) {
        if (indexPath.section == 1) {
            [self insertObjectToVarArrayAtIndex:indexPath.row];
        }
        
    }
    else if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // 新加的数据还没有id，老得有
        NSDictionary* dic = [_varArray objectAtIndex:indexPath.row];
        if ([dic objectForKey:@"id"]) {
            [_removeArray addObject:dic];
            [_varArray removeObject:dic];
            
        }
        else
        {
            [_addArray removeObject:dic];
            [_varArray removeObject:dic];
        }
        
        
        [_tableView reloadData];
        NSLog(@"%@",_varArray);
    }
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == _varArray.count-1){
            return UITableViewCellEditingStyleInsert;
        }
        return UITableViewCellEditingStyleDelete;
    }
    else
    {
        return UITableViewCellEditingStyleNone;
    }
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - keyBoard show and hide

-(void)speedyDocKeyBoardChange:(NSNotification *)notification
{
    
    CGPoint p= [_tempTextField.superview convertPoint:_tempTextField.center toView:_tableView];
    NSIndexPath *selectedRow= [_tableView indexPathForRowAtPoint:p];
    
    NSDictionary *keyboardInfo = [notification userInfo];
    CGRect keyboardFrame = [self.tableView.window convertRect:[keyboardInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue] toView:self.tableView.superview];
    CGFloat newBottomInset = self.tableView.frame.origin.y + self.tableView.frame.size.height - keyboardFrame.origin.y;
    if (newBottomInset > 0){
        UIEdgeInsets tableContentInset = self.tableView.contentInset;
        UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
        tableContentInset.bottom = newBottomInset+44;// 借鉴XLForm 先用吧
        tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
        [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
        self.tableView.contentInset = tableContentInset;
        self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
        [self.tableView scrollToRowAtIndexPath:selectedRow atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [UIView commitAnimations];
    }
    
//    NSDictionary *userInfo = [noti userInfo];
//
//    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
//    
//    CGRect keyboardRect = [aValue CGRectValue];
//    
//    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
//    NSTimeInterval animationDuration;
//    [animationDurationValue getValue:&animationDuration];
//    
//    [UIView animateWithDuration:animationDuration animations:^{
//        self.view.transform=CGAffineTransformMakeTranslation(0, -keyboardRect.size.height);
//    }];

    
}

-(void)speedyDocKeyBoardChangeHide:(NSNotification *)notification
{
    NSDictionary *keyboardInfo = [notification userInfo];
    UIEdgeInsets tableContentInset = self.tableView.contentInset;
    UIEdgeInsets tableScrollIndicatorInsets = self.tableView.scrollIndicatorInsets;
    tableContentInset.bottom = 0;
    tableScrollIndicatorInsets.bottom = tableContentInset.bottom;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue]];
    [UIView setAnimationCurve:[keyboardInfo[UIKeyboardAnimationCurveUserInfoKey] intValue]];
    self.tableView.contentInset = tableContentInset;
    self.tableView.scrollIndicatorInsets = tableScrollIndicatorInsets;
    [UIView commitAnimations];
}



#pragma mark - textField delegate

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@"%s___%@",__FUNCTION__,textField);
    _tempTextField = textField;
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    CGPoint pt=[textField.superview convertPoint:textField.center toView:_tableView];
    NSIndexPath *ipath=[_tableView indexPathForRowAtPoint:pt];
    
    if (ipath.section == 1)
    {
        NSMutableDictionary* dic = [_varArray objectAtIndex:ipath.row];
        [dic setObject:textField.text forKey:@"option_cname"];
    }

}


#pragma mark - 当添加字段列表删除一行时触发 或者点击的时候替换的

-(void) deleteSelectedOptionByFromIndex:(NSInteger) index
{
//    NSString* strIndex = [NSString stringWithFormat:@"%ld",index];
//    
//    NSMutableArray* selectedArr = [NSMutableArray arrayWithArray:_selectedArray];
//    
//    for (NSMutableDictionary* dic in selectedArr) {
//        // 排除formIndex 已经对应的item
//        NSString* status = [dic objectForKey:OPTION_STATUS];
//        if ([status isEqualToString:strIndex]) {
//            [dic setObject:@"-1" forKey:OPTION_STATUS];
//            //添加到显示的数组
//            [_dataArray addObject:dic];
//            // 如果已经选择的数组中有对应的 fromIndex 将其赋为初始值并删除
//            [_selectedArray removeObject:dic];
//        }
//    }
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
