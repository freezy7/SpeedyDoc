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
#import <MessageUI/MFMailComposeViewController.h>

#include "LibXL/libxl.h"

@interface MainViewController ()<MFMailComposeViewControllerDelegate>
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
        //[_dbManager creatDatabase:@"testform"];
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
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(formAction:)];
}

-(void)formAction:(UIBarButtonItem * __unused)button
{
    //NSArray* dataArray = [_dbManager queryForm];
    //[self creatExcel];
    [self sendMailInApp];

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
    NSString* str =[NSHomeDirectory() stringByAppendingString:@"/Documents"];
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
    [self alertWithMessage:@"no errors"];
}

-(void)alertWithMessage:(NSString*)msg
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Valid Form", nil) message:msg delegate:self cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - 在应用内发送邮件

-(void)sendMailInApp
{
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
    if (!mailClass) {
        [self alertWithMessage:@"当前系统版本不支持应用内发送邮件功能，您可以使用mailto方法代替"];
        return;
    }
    if (![mailClass canSendMail]) {
        [self alertWithMessage:@"用户没有设置邮件账户"];
    }
    [self displayMailPicker];
}

// 调出邮件发送窗口

-(void)displayMailPicker
{
    MFMailComposeViewController* mailPicker = [[MFMailComposeViewController alloc] init];
    mailPicker.mailComposeDelegate = self;
    
    //设置主题
    [mailPicker setSubject:@"邮件主题"];
    
    //添加收件人
    NSArray* toRecipients = [NSArray arrayWithObject:@"first@example.com"];
    [mailPicker setToRecipients:toRecipients];
    
    //添加抄送
    NSArray* ccRecipents = [NSArray arrayWithObjects:@"second@example.com",@"third@example.com", nil];
    [mailPicker setCcRecipients:ccRecipents];
    
    //添加密送
    NSArray* bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
    [mailPicker setBccRecipients:bccRecipients];
    
    //添加一张图片
//    UIImage *addPic = [UIImage imageNamed: @"Icon@2x.png"];
//    NSData *imageData = UIImagePNGRepresentation(addPic);            // png
//    [mailPicker addAttachmentData: imageData mimeType: @"" fileName: @"Icon.png"];
    //添加一个pdf附件
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filename = [documentPath stringByAppendingPathComponent:@"out.xls"];
    NSData* xls = [NSData dataWithContentsOfFile:filename];
    
    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
    [mailPicker addAttachmentData: xls mimeType: @"application/octet-stream" fileName: @"out.xls"];
    NSString* emailBody = @"<font color='red'>emali</font>";
    [mailPicker setMessageBody:emailBody isHTML:YES];
    [self presentViewController:mailPicker animated:YES completion:nil];
    
}

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    //关闭邮件发送窗口
    [self dismissViewControllerAnimated:YES completion:nil];
    NSString *msg;
    switch (result) {
        case MFMailComposeResultCancelled:
            msg = @"用户取消编辑邮件";
            break;
        case MFMailComposeResultSaved:
            msg = @"用户成功保存邮件";
            break;
        case MFMailComposeResultSent:
            msg = @"用户点击发送，将邮件放到队列中，还没发送";
            break;
        case MFMailComposeResultFailed:
            msg = @"用户试图保存或者发送邮件失败";
            break;
        default:
            msg = @"";
            break;
    }
    [self alertWithMessage:msg];
}

-(void)creatExcel
{
    NSLog(@"creatExcel");
    
    BookHandle book = xlCreateBook();//use xlCreateXMLBook() for working with xlsx files
    
    SheetHandle sheet = xlBookAddSheet(book,"Sheet1",NULL);
    
    xlSheetWriteStr(sheet,2,1,"Hello World !",0);
    xlSheetWriteNum(sheet,4,1,1000,0);
    xlSheetWriteNum(sheet,5,1,2000,0);
    
    FontHandle font = xlBookAddFont(book,0);
    xlFontSetColor(font,COLOR_RED);
    xlFontSetBold(font,true);
    FormatHandle boldFormat = xlBookAddFormat(book,0);
    xlFormatSetFont(boldFormat,font);
    xlSheetWriteFormula(sheet,6,1,"SUM(B5:B6)",boldFormat);
    
    FormatHandle dateFormat = xlBookAddFormat(book,0);
    xlFormatSetNumFormat(dateFormat,NUMFORMAT_DATE);
    xlSheetWriteNum(sheet,8,1,xlBookDatePack(book,2015,4,26,0,0,0,0),dateFormat);
    
    xlSheetSetCol(sheet,1,1,12,0,0);
    
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filename = [documentPath stringByAppendingPathComponent:@"out.xls"];
    
    xlBookSave(book,[filename UTF8String]);
    
    xlBookRelease(book);
    
}

@end
