//
//  FRSDASeletedUserSearchResultVC.h
//  WFChatUIKit
//
//  Created by Zack Zhang on 2020/4/4.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FRSDASelectModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FRSDASeletedUserSearchResultVC : UIViewController
@property (nonatomic, assign)NSInteger organizationId;
@property (nonatomic, strong)UITableView *tableView;
@property (nonatomic, assign)BOOL needSection;
@property (nonatomic, strong)NSDictionary *sectionDictionary;
@property (nonatomic, strong)NSArray *sectionKeys;
@property (nonatomic, strong)NSMutableArray <FRSDASelectModel *> *dataSource;
@property (nonatomic, strong)NSMutableArray <FRSDASelectModel *> *selectedUsers;
@property (nonatomic, copy) void(^ selectedUserBlock) (FRSDASelectModel *user);

@end

NS_ASSUME_NONNULL_END
