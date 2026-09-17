//
//  FavGroupTableViewController.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/13.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "TREWQFavGroupTableVC.h"
#import "RWADCGroupTVCell.h"
#import "QWERMessageListVC.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "RWADCGroupMemberTVController.h"
#import "RWADCInviteGroupMemberVC.h"
#import "UIView+Toast.h"
#import "QWERConfigManager.h"

@interface TREWQFavGroupTableVC ()
@property (nonatomic, strong)NSMutableArray<WFCCGroupInfo *> *groups;
@end

@implementation TREWQFavGroupTableVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshList];
    self.tabBarController.tabBar.hidden = YES;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.groups = [[NSMutableArray alloc] init];
    self.title = WFCString(@"MyGroup");
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)refreshList {
    NSArray *ids = [[WFCCIMService sharedWFCIMService] getFavGroups];
    [self.groups removeAllObjects];
    
    for (NSString *groupId in ids) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:groupId refresh:NO];
        if (groupInfo) {
            groupInfo.target = groupId;
            [self.groups addObject:groupInfo];
        }
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    [self.tableView reloadData];
}

- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    for (int i = 0; i < self.groups.count; ++i) {
        for (WFCCGroupInfo *groupInfo in groupInfoList) {
            if([self.groups[i].target isEqualToString:groupInfo.target]) {
                self.groups[i] = groupInfo;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RWADCGroupTVCell *cell = (RWADCGroupTVCell*)[tableView dequeueReusableCellWithIdentifier:@"groupCellId"];
    if (cell == nil) {
        cell = [[RWADCGroupTVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"groupCellId"];
    }
    cell.groupInfo = self.groups[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCGroupInfo *groupInfo = self.groups[indexPath.row];
    
    QWERMessageListVC *mvc = [[QWERMessageListVC alloc] init];
    NSString *groupId = groupInfo.target;
    mvc.conversation = [WFCCConversation conversationWithType:Group_Type target:groupId line:0];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
       // [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *groupId = self.groups[indexPath.row].target;
    __weak typeof(self) ws = self;
    
    
    UITableViewRowAction *cancel = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"移除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        
        [[WFCCIMService sharedWFCIMService] setFavGroup:groupId fav:NO success:^{
            [ws.view makeToast:WFCString(@"Removed") duration:2.0 position:CSToastPositionCenter];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws refreshList];
            });
            
        } error:^(int error_code) {
            [ws.view makeToast:WFCString(@"OperationFailure") duration:2 position:CSToastPositionCenter];
        }];
    }];
    
    cancel.backgroundColor = [UIColor redColor];

    return @[cancel];
};

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
