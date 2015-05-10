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

-(void)savePressed:(UIBarButtonItem*) btn
{
//    NSDictionary* dic = self.formValues;
//    NSDate* date = (NSDate*)[dic valueForKey:@"age"];
//    NSDateFormatter* format = [[NSDateFormatter alloc] init];
//    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//    NSString* str = [format stringFromDate:date];
    
    [_fmdb insertIntoTable:_table data:self.formValues];
    
}

-(void)initializeForm
{
    XLFormDescriptor* form = [XLFormDescriptor formDescriptorWithTitle:@"表单数据录入"];
    XLFormSectionDescriptor* section;
    XLFormRowDescriptor* row;
    
    // Basie information - section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"表单数据录入（单条）"];
    section.footerTitle = @"请正确填写表单数据，每次保存为一条数据插入，请认真核对";
    [form addFormSection:section];
    
    for (NSDictionary* dic in _rowArray) {
        row = [XLFormRowDescriptor formRowDescriptorWithTag:[dic objectForKey:OPTION_ENAME] rowType:[dic objectForKey:OPTION_TYPE] title:[dic objectForKey:OPTION_CNAME]];
        [section addFormRow:row];
    }
    
    self.form = form;
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
