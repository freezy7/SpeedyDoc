//
//  CustomFormatViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/1.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "CustomFormatViewController.h"
#import "XLForm.h"

NSString *const kSelectorLeftRight = @"selectorLeftRight";


@interface CustomFormatViewController ()

@end

@implementation CustomFormatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"选择字段";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    
    [self initializeForm];
    
}

-(void)initializeForm
{
    XLFormDescriptor* form = [XLFormDescriptor formDescriptorWithTitle:@"Custom Selectors"];
    XLFormSectionDescriptor* section;
    XLFormRowDescriptor* row;
    
    // Basic Information
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Selectors" sectionOptions:
               XLFormSectionOptionCanInsert|
               XLFormSectionOptionCanDelete|
               XLFormSectionOptionCanReorder sectionInsertMode:XLFormSectionInsertModeButton];
    section.footerTitle = @"this is a test";
    
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectorLeftRight rowType:XLFormRowDescriptorTypeSelectorPush title:@"选择名字"];
    row.selectorOptions = @[@"姓名",@"年龄",@"性别",@"出生日期"];
    //section.multivaluedRowTemplate = [row copy];
    [section addFormRow:row];
    
    /*
    // Selector Left Right
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kSelectorLeftRight rowType:XLFormRowDescriptorTypeSelectorLeftRight title:@"Left Right"];
    //row.noValueDisplayText = @"空";
    //row.leftRightSelectorLeftOptionSelected = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"选项1"];
    NSArray* rightOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Right Option 1"],
                              [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Right Option 2"],
                              [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Right Option 3"],
                              [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Right Option 4"],
                              [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Right option 5"]
                              ];
    // create right selectors
    NSMutableArray* leftRightSelectionOptions = [[NSMutableArray alloc] init];
    NSMutableArray* mutableRightOptions = [rightOptions mutableCopy];
    [mutableRightOptions removeObjectAtIndex:0];
    XLFormLeftRightSelectorOption* leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"选项1"] httpParameterKey:@"选项1" rightOptions:mutableRightOptions];
    [leftRightSelectionOptions addObject:leftRightSelectorOption];
    
    mutableRightOptions = [rightOptions mutableCopy];
    [mutableRightOptions removeObjectAtIndex:1];
    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"选项2"] httpParameterKey:@"选项2" rightOptions:mutableRightOptions];
    [leftRightSelectionOptions addObject:leftRightSelectorOption];
    
    mutableRightOptions = [rightOptions mutableCopy];
    [mutableRightOptions removeObjectAtIndex:2];
    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"选项3"] httpParameterKey:@"选项3" rightOptions:mutableRightOptions];
    [leftRightSelectionOptions addObject:leftRightSelectorOption];
    
    mutableRightOptions = [rightOptions mutableCopy];
    [mutableRightOptions removeObjectAtIndex:3];
    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"选项4"] httpParameterKey:@"选项4" rightOptions:mutableRightOptions];
    [leftRightSelectionOptions addObject:leftRightSelectorOption];
    
    mutableRightOptions = [rightOptions mutableCopy];
    [mutableRightOptions removeObjectAtIndex:4];
    leftRightSelectorOption = [XLFormLeftRightSelectorOption formLeftRightSelectorOptionWithLeftValue:[XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"选项5"] httpParameterKey:@"选项5" rightOptions:mutableRightOptions];
    [leftRightSelectionOptions addObject:leftRightSelectorOption];
    
    row.selectorOptions = leftRightSelectionOptions;
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Right Option 4"];
    
    //section.multivaluedRowTemplate = [row copy];
    [section addFormRow:row];
    */
    
    
    self.form = form;
}

#pragma mark - btn click event
-(void)savePressed:(UIButton*) btn
{
    NSLog(@"value = %@",self.formValues);
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
