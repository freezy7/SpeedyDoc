//
//  SpeedyDocViewController.m
//  SpeedyDoc
//
//  Created by R_style_Man on 15/5/1.
//  Copyright (c) 2015年 R_style Man. All rights reserved.
//

#import "SpeedyDocViewController.h"
#import "CustomFormatViewController.h"
#import "FormatDocViewController.h"

@interface SpeedyDocViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSMutableArray* _docArray;
}

@property(strong,nonatomic) IBOutlet UITableView* tableView;

@end

@implementation SpeedyDocViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"Speedy Doc";
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPressed:)];
    
    _docArray = [[NSMutableArray alloc] initWithObjects:@"1",@"1",@"1", nil];
}

#pragma mark - tableView dataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _docArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString* strID = @"ID";
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:strID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strID];
    }
    cell.textLabel.text = @"测试";
    return cell;
}

#pragma mark - tableView delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FormatDocViewController* format = [[FormatDocViewController alloc] initWithNibName:@"FormatDocViewController" bundle:nil];
    [self.navigationController pushViewController:format animated:YES];
}


-(void)addPressed:(UIButton*) btn
{
    CustomFormatViewController* custom = [[CustomFormatViewController alloc] initWithNibName:@"CustomFormatViewController" bundle:nil];
    
    [self.navigationController pushViewController:custom animated:YES];
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
