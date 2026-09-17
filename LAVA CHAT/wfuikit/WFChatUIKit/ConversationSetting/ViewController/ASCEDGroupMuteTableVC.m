//
//  ASCEDGroupMuteTableVC.m
//  WFChatUIKit
//
//  Created by heavyrain lee on 2019/6/26.
//  Copyright © 2019 WildFireChat. All rights reserved.
//

#import "ASCEDGroupMuteTableVC.h"
#import <SDWebImage/SDWebImage.h>
#import "FRSDAContactListVC.h"
#import "DSRACGeneralSwitchTVCell.h"
#import "FRSDAContactListVC.h"
#import "QWERImage.h"
#import "UIView+Toast.h"

#import "DSRACICONNAMETVCell.h"


@interface ASCEDGroupMuteTableVC () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray<WFCCGroupMember *> *mutedMemberList;
@property(nonatomic, strong)NSMutableArray<WFCCGroupMember *> *allowedMemberList;
@end

@implementation ASCEDGroupMuteTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"群禁言管理";
    
    [self loadMemberList];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStyleGrouped];
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView reloadData];
    
    [self.view addSubview:self.tableView];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.groupInfo.target isEqualToString:note.object]) {
            [ws loadMemberList];
            [ws.tableView reloadData];
        }
    }];
}

- (void)loadMemberList {
    NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:YES];
    self.mutedMemberList = [[NSMutableArray alloc] init];
    self.allowedMemberList = [[NSMutableArray alloc] init];
    for (WFCCGroupMember *member in memberList) {
        if (member.type == Member_Type_Muted) {
            [self.mutedMemberList addObject:member];
        } else if (member.type == Member_Type_Allowed) {
            [self.allowedMemberList addObject:member];
        }
    }
}
- (void)selectMemberToAdd:(BOOL)isAllow {
    FRSDAContactListVC *pvc = [[FRSDAContactListVC alloc] init];
    pvc.selectContact = YES;
    pvc.multiSelect = YES;
    __weak typeof(self)ws = self;
    pvc.selectResult = ^(NSArray<NSString *> *contacts) {
        if (isAllow) {
//            设置群成员允许名单，当设置群全局禁言时，仅群主/群管理/运行名单成员可以发言，仅专业版支持
//            
//            @param groupId 群ID
//            @param isSet    设置或取消
//            @param memberIds    成员ID
//            @param notifyLines 默认传 @[@(0)]
//            @param notifyContent 通知消息
//            @param successBlock 成功的回调
//            @param errorBlock 失败的回调
            [[WFCCIMService sharedWFCIMService] allowGroupMember:self.groupInfo.target isSet:YES memberIds:contacts notifyLines:@[@(0)] notifyContent:nil success:^{
                [ws loadMemberList];
                [ws.tableView reloadData];
            } error:^(int error_code) {
                if (error_code == ERROR_CODE_NOT_IMPLEMENT) {
                    [self.view makeToast:@"未实现..."];
                }
            }];
        } else {
            [[WFCCIMService sharedWFCIMService] muteGroupMember:self.groupInfo.target isSet:YES memberIds:contacts notifyLines:@[@(0)] notifyContent:nil success:^{
                [ws loadMemberList];
                [ws.tableView reloadData];
            } error:^(int error_code) {
                if (error_code == ERROR_CODE_NOT_IMPLEMENT) {
                    [self.view makeToast:@"未实现..."];
                }
            }];
        }
        
    };
    NSMutableArray *candidateUsers = [[NSMutableArray alloc] init];
    NSArray *memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:self.groupInfo.target forceUpdate:NO];
    for (WFCCGroupMember *member in memberList) {
        if ((member.type == Member_Type_Normal || (isAllow && member.type == Member_Type_Muted) || (!isAllow && member.type == Member_Type_Allowed)) && ![member.memberId isEqualToString:self.groupInfo.owner]) {
            [candidateUsers addObject:member.memberId];
        }
    }
    if([candidateUsers count]) {
        pvc.candidateUsers = candidateUsers;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:pvc];
        [self.navigationController presentViewController:navi animated:YES completion:nil];
    } else {
        [self.view makeToast:@"成员已全部添加"];
    }
}
- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    __weak typeof(self)ws = self;
    if (indexPath.section == 0) {
        DSRACGeneralSwitchTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"switchcell"];
        if (cell == nil) {
            cell = [[DSRACGeneralSwitchTVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"switchcell"];
            cell.textLabel.text = WFCString(@"MuteAll");
            cell.textLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:16.0];
            cell.onSwitch = ^(BOOL value, int type, void (^onDone)(BOOL success)) {
                [[WFCCIMService sharedWFCIMService] modifyGroupInfo:self.groupInfo.target type:Modify_Group_Mute newValue:value?@"1":@"0" notifyLines:@[@(0)] notifyContent:nil success:^{
                    ws.groupInfo.mute = value;
                    onDone(YES);
                } error:^(int error_code) {
                    onDone(NO);
                }];
            };
        }
        
        cell.on = self.groupInfo.mute;
        return cell;
    } else {
        DSRACICONNAMETVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
        if (cell == nil) {
            cell = [[DSRACICONNAMETVCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if(indexPath.section == 1) {
            if (indexPath.row == 0) {
                cell.iconView.image = [QWERImage imageNamed:@"plus"];
                cell.asoucNameLabel.text = WFCString(@"MuteMember");
            } else {
                WFCCUserInfo *member = [[WFCCIMService sharedWFCIMService] getUserInfo:[self.mutedMemberList objectAtIndex:indexPath.row-1].memberId  refresh:NO];
                [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[member.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
                cell.asoucNameLabel.text = member.displayName;
            }
        } else if(indexPath.section == 2) {
            if (indexPath.row == 0) {
                cell.iconView.image = [QWERImage imageNamed:@"plus"];
                cell.asoucNameLabel.text = WFCString(@"AllowMember");
            } else {
                WFCCUserInfo *member = [[WFCCIMService sharedWFCIMService] getUserInfo:[self.allowedMemberList objectAtIndex:indexPath.row-1].memberId  refresh:NO];
                [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[member.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
                cell.asoucNameLabel.text = member.displayName;
            }
        }
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 || (indexPath.section == 1 && indexPath.row == 0)) {
        return NO;
    }
    return YES;
}
- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:WFCString(@"Unmute") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

        __weak typeof(self)ws = self;
        if (indexPath.section == 1) {
            [[WFCCIMService sharedWFCIMService] muteGroupMember:self.groupInfo.target isSet:NO memberIds:@[[self.mutedMemberList objectAtIndex:indexPath.row-1].memberId] notifyLines:@[@(0)] notifyContent:nil success:^{
                for (WFCCGroupMember *member in ws.mutedMemberList) {
                    if ([member.memberId isEqualToString:[ws.mutedMemberList objectAtIndex:indexPath.row-1].memberId]) {
                        [ws.mutedMemberList removeObject:member];
                        [ws.tableView reloadData];
                        break;
                    }
                }
            } error:^(int error_code) {
                
            }];
        } else if(indexPath.section == 2) {
            [[WFCCIMService sharedWFCIMService] allowGroupMember:self.groupInfo.target isSet:NO memberIds:@[[self.allowedMemberList objectAtIndex:indexPath.row-1].memberId] notifyLines:@[@(0)] notifyContent:nil success:^{
                for (WFCCGroupMember *member in ws.allowedMemberList) {
                    if ([member.memberId isEqualToString:[ws.allowedMemberList objectAtIndex:indexPath.row-1].memberId]) {
                        [ws.allowedMemberList removeObject:member];
                        [ws.tableView reloadData];
                        break;
                    }
                }
            } error:^(int error_code) {
                
            }];
        }
        
    }];
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:WFCString(@"Cancel") handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {

    }];
    editAction.backgroundColor = [UIColor grayColor];
    return @[deleteAction, editAction];
}


- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else if(section == 1) {
        return self.mutedMemberList.count+1;
    } else if(section == 2) {
        return self.allowedMemberList.count+1;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return WFCString(@"MuteAll");
    } else if(section == 1) {
        return WFCString(@"MutedList");
    } else if(section == 2) {
        return WFCString(@"AllowList");
    }
    return nil;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.f;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.f;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3; //全员禁言，群成员禁言，允许发言成员
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section == 0) {
        
    } else if(indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self selectMemberToAdd:NO];
        } else {
            
        }
    } else if(indexPath.section == 2) {
        if (indexPath.row == 0) {
            [self selectMemberToAdd:YES];
        } else {
            
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
