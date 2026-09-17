//
//  LaAdministratorVC.m
//  WildFireChat
//
//  Created by Ruby on 12/5/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaAdministratorVC.h"
#import "LaContactsTVCell.h"

#import "LaContactsVC.h"
#import "GroupPermissionViewController.h"

@interface LaAdministratorVC ()<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray<WFCCGroupMember *> *managerList;

@end

@implementation LaAdministratorVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"ManagerSetting");
    UIButton *itemBtn = [self itemTitle:LLLLLL(@"Add") action:@selector(selectMemberToAdd)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:itemBtn];
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"LaContactsTVCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LaContactsTVCell"];
    [self.view addSubview:self.tableView];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.groupInfo.target isEqualToString:note.object]) {
            [ws loadManagerList];
            [ws.tableView reloadData];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self loadManagerList];
}

- (void)loadManagerList {
    NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:YES];
    self.managerList = [[NSMutableArray alloc] init];
    for (WFCCGroupMember *member in memberList) {
        if (member.type == Member_Type_Manager) {
            [self.managerList addObject:member];
        }
    }
    [self.tableView reloadData];
}
- (void)selectMemberToAdd {
    if (![self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        if (![[self getMyself].controlOther isEqualToString:@"1"]) {
            [self.view makeToast:LLLLLL(@"GroupAccessManagerInsufficientPermissions") duration:1 position:CSToastPositionCenter];
            return;
        }
    }
    LaContactsVC *pvc = [[LaContactsVC alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = YES;
    __weak typeof(self)ws = self;
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        [[WFCCIMService sharedWFCIMService] setGroupManager:self.groupInfo.target isSet:YES memberIds:contacts notifyLines:@[@(0)] notifyContent:nil success:^{
            for (NSString *memberId in contacts) {
                WFCCGroupMember *member = [[WFCCIMService sharedWFCIMService] getGroupMember:ws.groupInfo.target memberId:memberId];
                if (member) {
                    member.type = Member_Type_Manager;
                    [ws.managerList addObject:member];
                }
            }
            if (contacts.count) {
                [ws.tableView reloadData];
            }
        } error:^(int error_code) {    
        }];
    };
    NSMutableArray *candidateUsers = [[NSMutableArray alloc] init];
    NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO];
    for (WFCCGroupMember *member in memberList) {
        if ((member.type == Member_Type_Normal || member.type == Member_Type_Muted || member.type == Member_Type_Allowed) && ![member.memberId isEqualToString:self.groupInfo.owner]) {
            [candidateUsers addObject:member.memberId];
        }
    }
    if([candidateUsers count]) {
        pvc.candidateUsers = candidateUsers;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    } else {
        [self.view makeToast:LLLLLL(@"BeenAddedAllMembers")];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; //成员管理，加群设置
}
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if (section == 1) {
        return self.managerList.count;
    }
    return 0;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    LaContactsTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaContactsTVCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.section == 0) {
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell setUserId:self.groupInfo.owner groupId:self.groupInfo.target];
    } else if(indexPath.section == 1) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell setUserId:self.managerList[indexPath.row].memberId groupId:self.groupInfo.target];
    }
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //群主
    if (indexPath.section == 0) {
        return;
    }
    NSString *selectUsr = self.managerList[indexPath.row].memberId;
    if ([self.groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId] || [[self getMyself].controlOther isEqualToString:@"1"]) {
        GroupPermissionViewController *vc = [[GroupPermissionViewController alloc] init];
        vc.groupInfo = self.groupInfo;
        vc.userId = selectUsr;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    if (![[self getMyself].controlOther isEqualToString:@"1"]) {
        [self.view makeToast:LLLLLL(@"GroupAccessManagerInsufficientPermissions") duration:1 position:CSToastPositionCenter];
    }
}


//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section == 0) {
//        return NO;
//    }
//    return [self.groupInfo.owner isEqualToString:WFCCNetworkService.sharedInstance.userId];
//}

//- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:LLLLLL(@"Remove") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        __weak typeof(self)ws = self;
//        [[WFCCIMService sharedWFCIMService] setGroupManager:self.groupInfo.target isSet:NO memberIds:@[[self.managerList objectAtIndex:indexPath.row].memberId] notifyLines:@[@(0)] notifyContent:nil success:^{
//            for (WFCCGroupMember *member in ws.managerList) {
//                if ([member.memberId isEqualToString:[ws.managerList objectAtIndex:indexPath.row].memberId]) {
//                    [ws.managerList removeObject:member];
//                    [ws.tableView reloadData];
//                    break;
//                }
//            }
//        } error:^(int error_code) {
//            
//        }];
//    }];
////    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:LLLLLL(@"Cancel") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
////        NSLog(@"点击了编辑");
////    }];
////    editAction.backgroundColor = [UIColor grayColor];
////    return @[deleteAction, editAction];
//    return @[deleteAction];
//}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 40.0;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return LLLLLL(@"GroupOwner");
    } else if(section == 1) {
        return LLLLLL(@"Manager");
    }
    return nil;
}

//获取自己的权限
- (WFCCGroupMember *)getMyself {
    for (WFCCGroupMember *obj in self.managerList) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            WFCCGroupMember *mem = [WFCCGroupMember mj_objectWithKeyValues:obj.extra];
            obj.controlOther = mem.controlOther;
            obj.modifyGroupInfo = mem.modifyGroupInfo;
            obj.pushNotice = mem.pushNotice;
            obj.renewRequest = mem.renewRequest;
            return obj;
        }
    }
    return nil;
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
