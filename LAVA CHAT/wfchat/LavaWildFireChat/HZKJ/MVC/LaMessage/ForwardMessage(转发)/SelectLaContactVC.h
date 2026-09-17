//
//  SelectLaContactVC.h
//  WildFireChat
//
//  Created by wtb on 2025/4/23.
//  Copyright © 2025 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SelectLaContactVC : UITableViewController
@property (nonatomic, strong) WFCCMessage *message;
//可以转发一条或者转发多条
@property (nonatomic, strong) NSArray<WFCCMessage *> *messages;

@property (nonatomic, strong)NSString *groupId;

@end

NS_ASSUME_NONNULL_END
