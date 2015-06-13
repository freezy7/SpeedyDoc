//
//  EditDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/26.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "EditDocViewController.h"
#import "FMDBManmager.h"

@interface EditDocViewController ()
{
    FMDBManmager* _fmdb;
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
