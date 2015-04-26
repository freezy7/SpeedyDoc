//
//  MainViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/4/25.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//
#import "XLForm.h"
#import "MainViewController.h"
#import "FMDBManmager.h"
#import "FormModel.h"

@interface MainViewController ()
{
    FMDBManmager* _dbManager;
}

@end

@implementation MainViewController

NSString *const kName = @"name";
NSString *const kEmail = @"email";
NSString *const kTwitter = @"twitter";
NSString *const kNumber = @"number";
NSString *const kInteger = @"integer";
NSString *const kDecimal = @"decimal";
NSString *const kPassword = @"password";
NSString *const kPhone = @"phone";
NSString *const kUrl = @"url";
NSString *const kTextView = @"textView";
NSString *const kNotes = @"notes";

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self = [self init];
        _dbManager = [FMDBManmager sharedManager];
        [_dbManager creatDatabase:@"testform"];
    }
    return self;
}

-(id)init
{
    XLFormDescriptor * formDescriptor = [XLFormDescriptor formDescriptorWithTitle:@"Text Fields"];
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    formDescriptor.assignFirstResponderOnShow = YES;
    
    // Basic Information - Section
    section = [XLFormSectionDescriptor formSectionWithTitle:@"TextField Types"];
    section.footerTitle = @"This is a long text that will appear on section footer";
    [formDescriptor addFormSection:section];
    
    // Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kName rowType:XLFormRowDescriptorTypeText title:@"Name"];
    row.required = YES;
    [section addFormRow:row];
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kEmail rowType:XLFormRowDescriptorTypeEmail title:@"Email"];
    // validate the email
    [row addValidator:[XLFormValidator emailValidator]];
    [section addFormRow:row];
    
    // Twitter
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTwitter rowType:XLFormRowDescriptorTypeTwitter title:@"Twitter"];
    row.disabled = YES;
    row.value = @"@no_editable";
    [section addFormRow:row];
    
    // Number
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNumber rowType:XLFormRowDescriptorTypeNumber title:@"Number"];
    [section addFormRow:row];
    
    // Integer
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kInteger rowType:XLFormRowDescriptorTypeInteger title:@"Integer"];
    [section addFormRow:row];
    
    // Decimal
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kDecimal rowType:XLFormRowDescriptorTypeDecimal title:@"Decimal"];
    [section addFormRow:row];
    
    // Password
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPassword rowType:XLFormRowDescriptorTypePassword title:@"Password"];
    [section addFormRow:row];
    
    // Phone
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kPhone rowType:XLFormRowDescriptorTypePhone title:@"Phone"];
    [section addFormRow:row];
    
    // Url
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kUrl rowType:XLFormRowDescriptorTypeURL title:@"Url"];
    [section addFormRow:row];
    
    
    section = [XLFormSectionDescriptor formSection];
    [formDescriptor addFormSection:section];
    
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kTextView rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfigAtConfigure setObject:@"TEXT VIEW EXAMPLE" forKey:@"textView.placeholder"];
    [section addFormRow:row];
    
    section = [XLFormSectionDescriptor formSectionWithTitle:@"TextView With Label Example"];
    [formDescriptor addFormSection:section];
    row = [XLFormRowDescriptor formRowDescriptorWithTag:kNotes rowType:XLFormRowDescriptorTypeTextView title:@"Notes"];
    [section addFormRow:row];
    
    return [super initWithForm:formDescriptor];
    
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(formAction:)];
}

-(void)formAction:(UIBarButtonItem * __unused)button
{
    NSArray* dataArray = [_dbManager queryForm];

}

-(IBAction)savePressed:(UIBarButtonItem * __unused)button
{
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    [self.tableView endEditing:YES];
    
    NSDictionary* data = [self formValues];
    //NSString* str =[NSHomeDirectory() stringByAppendingString:@"/Documents"];
    FormModel* model = [[FormModel alloc] init];
    model.name = [data objectForKey:kName];
    model.email = [data objectForKey:kEmail];
    model.number = [NSString stringWithFormat:@"%@",[data objectForKey:kNumber]];
    model.integer = [NSString stringWithFormat:@"%@",[data objectForKey:kInteger]];
    model.decimal = [NSString stringWithFormat:@"%@",[data objectForKey:kDecimal]];
    model.password = [data objectForKey:kPassword];
    model.phone = [data objectForKey:kPhone];
    model.url = [data objectForKey:kUrl];
    model.textView = [data objectForKey:kTextView];
    model.notes = [data objectForKey:kNotes];
    [_dbManager addDataItem:model];
    //NSLog(@"data = %@",data);
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil) message:@"No errors found" delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

@end
