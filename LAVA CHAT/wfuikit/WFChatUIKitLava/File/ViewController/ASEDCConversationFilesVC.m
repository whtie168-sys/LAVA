//
//  ASEDCConversationFilesVC.m
//  WFChatUIKit
//
//  Created by dali on 2020/11/12.
//  Copyright © 2020 Wildfirechat. All rights reserved.
//

#import "ASEDCConversationFilesVC.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import "ASEDCFilesVC.h"
#import <SDWebImage/SDWebImage.h>
#import "QWERImage.h"

@interface ASEDCConversationFilesVC () <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSArray<WFCCConversationInfo *> *conversations;
@end

@implementation ASEDCConversationFilesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    self.conversations = [[WFCCIMService sharedWFCIMService] getConversationInfos:@[@(Single_Type),@(Group_Type),@(SecretChat_Type)] lines:@[@(0)]];
    [self.tableView reloadData];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    WFCCConversationInfo *conv = self.conversations[indexPath.row];
    if (conv.conversation.type == Single_Type) {
        WFCCUserInfo *user = [[WFCCIMService sharedWFCIMService] getUserInfo:conv.conversation.target refresh:NO];
        if (user.friendAlias.length) {
            cell.textLabel.text = user.friendAlias;
        } else if(user.displayName.length) {
            cell.textLabel.text = user.displayName;
        } else {
            cell.textLabel.text = @"用户";
        }
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.portrait] placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else if (conv.conversation.type == Group_Type) {
        WFCCGroupInfo *group = [[WFCCIMService sharedWFCIMService] getGroupInfo:conv.conversation.target refresh:NO];
        if (group.displayName.length) {
            cell.textLabel.text = group.displayName;
        } else {
            cell.textLabel.text = WFCString(@"Group");
        }

//        if (group.portrait.length) {
            [cell.imageView sd_setImageWithURL:[NSURL URLWithString:[group.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
//        } else {
//            NSString *path = [WFCCUtilities getGroupGridPortrait:group.target width:80 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
//                return [QWERImage imageNamed:@"PersonalChat"];
//            }];
//            
//            if (path) {
//                [cell.imageView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[QWERImage imageNamed:@"groupIcon"]];
//            }
//        }
    } else if (conv.conversation.type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:conv.conversation.target].userId;
        WFCCUserInfo *user = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        if (user.friendAlias.length) {
            cell.textLabel.text = user.friendAlias;
        } else if(user.displayName.length) {
            cell.textLabel.text = user.displayName;
        } else {
            cell.textLabel.text = @"用户";
        }
        [cell.imageView sd_setImageWithURL:[NSURL URLWithString:user.portrait] placeholderImage: [QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    }
    
    return cell;
}

#pragma mark - UITableViewDelegate
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCConversationInfo *conv = self.conversations[indexPath.row];
    ASEDCFilesVC *vc = [[ASEDCFilesVC alloc] init];
    vc.conversation = conv.conversation;
    [self.navigationController pushViewController:vc animated:YES];
}
@end
