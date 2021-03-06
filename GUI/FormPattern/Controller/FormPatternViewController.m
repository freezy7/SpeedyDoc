//
//  FormPatternViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/10.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "FormPatternViewController.h"
#import "FMDBManmager.h"
#import "XLForm.h"

#import "DetailFormViewController.h"

@interface FormPatternViewController ()
{
    FMDBManmager* _fmdb;
    NSMutableArray* _rowArray;
}

@end

@implementation FormPatternViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"单条数据录入";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    
    _fmdb = [FMDBManmager sharedManager];
    _rowArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:_model]];
    [self initializeForm];
}

-(void)alertWithMessage:(NSString*)msg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

-(void)savePressed:(UIBarButtonItem*) btn
{
    btn.enabled = NO;
    [self.tableView endEditing:YES];
    NSMutableDictionary* dic = (NSMutableDictionary*)self.formValues;
    [dic removeObjectForKey:@"button"];
    
    for (id value in [dic allValues]) {
        if (!value || [value isEqual:@""]||[[value class] isEqual:[NSNull class]]) {
            [self alertWithMessage:@"全为必填项"];
            btn.enabled = YES;
            return;
        }
    }
    if ([dic objectForKey:@"date"]) {// 如果是日期对日期进行时间戳化
        NSDate* date = (NSDate*)[dic objectForKey:@"date"];
        if (!date) {
            return;
        }else{
            NSString* ctime = [NSString stringWithFormat:@"%f",[date timeIntervalSince1970]];
            [dic setObject:ctime forKey:@"date"];
        }
    }
    
    // 对插入数据建立一个时间戳
    NSDate* curDate = [NSDate date];
    NSString* curtime = [NSString stringWithFormat:@"%f",[curDate timeIntervalSince1970]];
    [dic setObject:curtime forKey:@"ctime"];
    
    BOOL ret = [_fmdb insertIntoTable:_table data:dic];
    if (ret) {//数据保存成功
        [self clearFormRowValues];
        // 制作动画
        UIView* snapshotView = [self.view snapshotViewAfterScreenUpdates:NO];
        
        [self.view addSubview:snapshotView];
        
        [self performSelector:@selector(animateViewAwayAndReset:) withObject:snapshotView];
    }
    btn.enabled = YES;
}

// animate and remove the snapshotView
-(void) animateViewAwayAndReset:(UIView*)view
{
    [UIView animateWithDuration:0.5 animations:^{
        view.center = CGPointMake(self.view.frame.size.width,64);
        view.bounds = CGRectZero;
    } completion:^(BOOL finished) {
        [view removeFromSuperview];
    }];
}

#pragma mark - clear form row values after save success

-(void)clearFormRowValues
{
    for (XLFormSectionDescriptor* section in [self.form formSections]) {
        for (XLFormRowDescriptor * row in section.formRows) {
            row.value = @"";
        }
    }
    [self.tableView reloadData];
}

-(void)initializeForm
{
    XLFormDescriptor* form = [XLFormDescriptor formDescriptorWithTitle:@"表单数据录入"];
    XLFormSectionDescriptor* section;
    XLFormRowDescriptor* row;
    
    // Detail sheet button event
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"表单详情"];
    
    // Button
    XLFormRowDescriptor * buttonRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"button" rowType:XLFormRowDescriptorTypeButton title:@"表单详情"];
    [buttonRow.cellConfig setObject:[UIColor colorWithRed:0.0 green:122.0/255.0 blue:1.0 alpha:1.0] forKey:@"textLabel.textColor"];
    buttonRow.action.formSelector = @selector(didTouchButton:);
    [section addFormRow:buttonRow];
    
    [form addFormSection:section];
    
    
    // Basie information - section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"表单数据录入（单条）"];
    section.footerTitle = @"请正确填写表单数据，每次保存为一条数据插入，请认真核对";
    [form addFormSection:section];
    
    for (NSDictionary* dic in _rowArray) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[dic objectForKey:OPTION_ENAME] rowType:[dic objectForKey:OPTION_TYPE] title:[dic objectForKey:OPTION_CNAME]];
        if ([[dic objectForKey:OPTION_TYPE] isEqualToString:TYPE_DOC_DATE]||
            [[dic objectForKey:OPTION_TYPE] isEqualToString:TYPE_DOC_TEXTVIEW]) {
            
        }
        else
        {
            //[row.cellConfigAtConfigure setObject:@"Required..." forKey:@"textField.placeholder"];
            [row.cellConfigAtConfigure setObject:@(NSTextAlignmentRight) forKey:@"textField.textAlignment"];
            //row.required = YES;
        }
        
        [section addFormRow:row];
    }
    
    self.form = form;
}

-(void)didTouchButton:(XLFormRowDescriptor *)sender
{
    
    DetailFormViewController* detail = [[DetailFormViewController alloc] initWithNibName:@"DetailFormViewController" bundle:nil];
    
    detail.tableName = _table;
    detail.modelArray = _rowArray;
    
    [self deselectFormRow:sender];
    
    [self.navigationController pushViewController:detail animated:YES];
    
    
}

-(void)deselectFormRow:(XLFormRowDescriptor *)formRow
{
    NSIndexPath * indexPath = [self.form indexPathOfFormRow:formRow];
    if (indexPath){
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
