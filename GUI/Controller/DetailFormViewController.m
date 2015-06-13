//
//  DetailFormViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/16.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "DetailFormViewController.h"
#import "FMDBManmager.h"
#import "DetailFormTableViewCell.h"
//#import <LibXL/LibXL.h>
#import <MessageUI/MFMailComposeViewController.h>

@interface DetailFormViewController ()<UITableViewDataSource,UITableViewDelegate,MFMailComposeViewControllerDelegate>
{
    NSMutableArray* _dataArray;
    
    FMDBManmager* _fmdb;
    
    NSString* _tableCName;
    
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation DetailFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"表单详情";
    
    _tableView.tableFooterView = [[UIView alloc] init];
    
    _fmdb = [FMDBManmager sharedManager];
    
    _dataArray = [NSMutableArray arrayWithArray:[_fmdb queryListFromTable:_tableName]];
    NSArray* arr = [_fmdb querySql:[NSString stringWithFormat:@"select name from speedydoc where table_name = '%@'",_tableName]];
    
    _tableCName = [NSString stringWithFormat:@"%@.xls",[arr[0] objectForKey:@"name"]];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareAction:)];
}

-(void)shareAction:(UIBarButtonItem*) btn
{
    NSLog(@"creatExcel");
    
//    BookHandle book = xlCreateBook();//use xlCreateXMLBook() for working with xlsx files
//    
//    SheetHandle sheet = xlBookAddSheet(book,"Sheet1",NULL);
//    
//    for (int i = 0;i < _modelArray.count;i++) {
//        NSDictionary* dic = _modelArray[i];
//        NSString* cname = [dic objectForKey:OPTION_CNAME];
//        xlSheetWriteStr(sheet,1,i,[cname UTF8String],0);
//    }
//    for (int i = 0; i<_dataArray.count; i++) {
//        NSDictionary* dicData = _dataArray[i];
//        for (int j = 0; j<_modelArray.count; j++) {
//            NSDictionary* dic = _modelArray[j];
//            NSString* ename = [dic objectForKey:OPTION_ENAME];
//            NSString* str = [dicData objectForKey:ename];
//            xlSheetWriteStr(sheet,i+2,j,[str UTF8String],0);
//        }
//    }
//    
//    // 用的是table的cname
//    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString* filename = [documentPath stringByAppendingPathComponent:_tableCName];
//    
//    // 不用重新删除表格，数据能够存储加保存
//    xlBookSave(book,[filename UTF8String]);
//    
//    xlBookRelease(book);
//    
//    [self sendMailInApp];

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
//    NSArray* ccRecipents = [NSArray arrayWithObjects:@"second@example.com",@"third@example.com", nil];
//    [mailPicker setCcRecipients:ccRecipents];
    
    //添加密送
//    NSArray* bccRecipients = [NSArray arrayWithObject:@"fourth@example.com"];
//    [mailPicker setBccRecipients:bccRecipients];
    
    //添加一个pdf附件
    NSString* documentPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filename = [documentPath stringByAppendingPathComponent:_tableCName];
    NSData* xls = [NSData dataWithContentsOfFile:filename];
    
    //关于mimeType：http://www.iana.org/assignments/media-types/index.html
    [mailPicker addAttachmentData: xls mimeType: @"application/octet-stream" fileName: _tableCName];
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


#pragma mark - tableView dataSource

-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _dataArray.count;
}

-(UITableViewCell*) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strID = @"DetailFormTableViewCell";
    
    DetailFormTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DetailFormTableViewCell" owner:self options:nil] lastObject];
        cell.modelArray = _modelArray;
    }
    
    NSDictionary* dic = [_dataArray objectAtIndex:indexPath.row];
    
    cell.data = dic;
    
    return cell;
}


#pragma mark - tableView delegate

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 32*_modelArray.count;//后续自定义的时候优化
}


@end
