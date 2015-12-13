//
//  EditDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/26.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "EditDocViewController.h"
#import "FMDBManmager.h"
#import "QCPRefreshLoadingView.h"

@interface EditDocViewController ()
{
    FMDBManmager* _fmdb;
  QCPRefreshLoadingView *_loadingView;
}

@property(weak,nonatomic) IBOutlet UITextField* docName;

@end

@implementation EditDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"编辑文档名";
    _fmdb = [FMDBManmager sharedManager];
    UIBarButtonItem* rigitBar = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBtnPressed:)];
    self.navigationItem.rightBarButtonItem = rigitBar;
    
    NSString* sql = [NSString stringWithFormat:@"select name from speedydoc where id = %ld",_doc_id];
    NSArray* arr = [_fmdb querySql:sql];
    _docName.text = [arr[0] objectForKey:@"name"];
  
  _loadingView = [[QCPRefreshLoadingView alloc] initWithFrame:CGRectMake(0, 200, self.view.frame.size.width, 100)];
  _loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
  [self.view addSubview:_loadingView];
}

-(void)saveBtnPressed:(UIBarButtonItem*) btn
{
    [_docName endEditing:YES];
    NSString* sql = [NSString stringWithFormat:@"update speedydoc set name = '%@' where id = %ld",_docName.text,_doc_id];
    BOOL ret = [_fmdb excuteUpdateSql:sql];
    if (ret) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)animationButtonDidClicked:(id)sender
{
  [_loadingView showInView:self.view];
}

@end
