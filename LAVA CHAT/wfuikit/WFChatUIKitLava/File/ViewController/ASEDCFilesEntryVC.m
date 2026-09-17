//
//  ASEDCFilesEntryVC.m
//  WFChatUIKit
//
//  Created by dali on 2020/11/12.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import "ASEDCFilesEntryVC.h"
#import "ASEDCFilesVC.h"
#import "ASEDCConversationFilesVC.h"
#import "FRSDAContactListVC.h"
#import <LavaWFChatClient/WFCChatClient.h>
@interface ASEDCFilesEntryVC () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL _isChinese;
}
@property(nonatomic, strong)UITableView *tableView;
@end

@implementation ASEDCFilesEntryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [WFCCIMService.main isChinese];
    
    self.title = (_isChinese?@"文件":@"Tài liệu");
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 4;
    //所有，我发的，群文件，用户文件
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    if (indexPath.row == 0) {
        cell.textLabel.text = (_isChinese?@"所有文件":@"Tất cả tài liệu");
    } else if (indexPath.row == 1) {
        cell.textLabel.text = (_isChinese?@"我的文件":@"Tài liệu của tôi");
    } else if (indexPath.row == 2) {
        cell.textLabel.text = (_isChinese?@"会话文件":@"Tập tin phiên chạy");
    } else if (indexPath.row == 3) {
        cell.textLabel.text = (_isChinese?@"用户文件":@"Tập tin người dùng");
    }
    return cell;
}
#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        ASEDCFilesVC *vc = [[ASEDCFilesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.row == 1) {
        ASEDCFilesVC *vc = [[ASEDCFilesVC alloc] init];
        vc.myFiles = YES;
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.row == 2) { // 会话文件
        ASEDCConversationFilesVC *vc = [[ASEDCConversationFilesVC alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
    } else if(indexPath.row == 3) {
        FRSDAContactListVC *pvc = [[FRSDAContactListVC alloc] init];
        pvc.selectContact = YES;
        pvc.multiSelect = NO;
        pvc.withoutCheckBox = YES;
        
        
        __weak typeof(self)ws = self;
        pvc.selectResult = ^(NSArray<NSString *> *contacts) {
            if (contacts.count == 1) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    ASEDCFilesVC *vc = [[ASEDCFilesVC alloc] init];
                    vc.userFiles = YES;
                    vc.userId = contacts[0];
                    [ws.navigationController pushViewController:vc animated:YES];
                });
            } else {
                
            }
        };
        
        pvc.disableUsersSelected = YES;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    }
}
@end
