//
//  RWADCProfileMoreTableVC.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/22.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "RWADCProfileMoreTableVC.h"
#import <SDWebImage/SDWebImage.h>
#import <LavaWFChatClient/WFCChatClient.h>
#import "QWERMessageListVC.h"
#import "MBProgressHUD.h"
#import "QWERTMyPortraitVC.h"
#import "ATERWVerifyRequestVC.h"
#import "RWADCGeneralModifyVC.h"
#import "RADCOVideoVC.h"
#if WFCU_SUPPORT_VOIP
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>
#endif
#import "UIFont+YH.h"
#import "UIColor+YH.h"
#import "QWERConfigManager.h"
#import "QWERUserMessageListVC.h"
#import "QWERImage.h"
#import "TREWQGroupTableVC.h"


@interface RWADCProfileMoreTableVC () <UITableViewDelegate, UITableViewDataSource>


@property (strong, nonatomic)UITableViewCell *commonGroupCell;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, strong)NSMutableArray<UITableViewCell *> *cells;
@property (nonatomic, strong)WFCCUserInfo *userInfo;
@end

@implementation RWADCProfileMoreTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = WFCString(@"More");
    self.userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:self.userId refresh:YES];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [QWERConfigManager globalManager].backgroudColor;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.1)];
    [self loadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        keyWindow.tintAdjustmentMode = UIViewTintAdjustmentModeAutomatic;
    [keyWindow tintColorDidChange];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)loadData {
    self.cells = [[NSMutableArray alloc] init];
    
//    if (self.userInfo.mobile.length > 0) {
//        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
//        cell.asofaTextLabel.text = @"电话";
//        cell.detailTextLabel.text = self.userInfo.mobile;
//        [self.cells addObject:cell];
//    }
    
    if (self.userInfo.email.length > 0) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = @"邮箱";
        cell.detailTextLabel.text = self.userInfo.email;
        [self.cells addObject:cell];
    }
    
    if (self.userInfo.address.length) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = @"地址";
        cell.detailTextLabel.text = self.userInfo.address;
        [self.cells addObject:cell];
    }
    
    if (self.userInfo.company.length) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = @"公司";
        cell.detailTextLabel.text = self.userInfo.company;
        [self.cells addObject:cell];
    }
    
    if (self.userInfo.social.length) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.text = @"社交账号";
        cell.detailTextLabel.text = self.userInfo.social;
        [self.cells addObject:cell];
    }
    
    [self.tableView reloadData];
}

- (UITableViewCell *)commonGroupCell {
    if(!_commonGroupCell) {
        _commonGroupCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"common_group"];
        _commonGroupCell.textLabel.text = @"我和他的共同群组";
        _commonGroupCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个", self.commonGroupIds.count];
        _commonGroupCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return _commonGroupCell;
}

- (void)setCommonGroupIds:(NSArray<NSString *> *)commonGroupIds {
    _commonGroupIds = commonGroupIds;
    self.commonGroupCell.detailTextLabel.text = [NSString stringWithFormat:@"%ld个", commonGroupIds.count];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource<NSObject>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0) {
        return 1;
    }
    
    return self.cells.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"section:%ld",(long)indexPath.section);
    if (indexPath.section == 0) {
        return self.commonGroupCell;
    } else {
        return self.cells[indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cells.count) {
        return 2;
    } else {
        return 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section != 0) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 10)];
        view.backgroundColor = [QWERConfigManager globalManager].backgroudColor;
        return view;
    } else {
        return nil;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0;
    } else {
        return 10;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @" ";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if([tableView cellForRowAtIndexPath:indexPath] == self.commonGroupCell) {
        TREWQGroupTableVC *groupsVC = [[TREWQGroupTableVC alloc] init];
        groupsVC.groupIds = self.commonGroupIds;
        groupsVC.titleString = @"我和他的共同群组";
        [self.navigationController pushViewController:groupsVC animated:YES];
    }
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}
@end
