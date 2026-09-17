//
//  RUJBVOGHUYGroupVC.h
//  WUHOIBDK
//
//  Created by Ruby on 11/13/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface SelectLaGroupVC : UITableViewController

@property (nonatomic, strong) WFCCMessage *message;
//可以转发一条或者转发多条
@property (nonatomic, strong) NSArray<WFCCMessage *> *messages;


@end

NS_ASSUME_NONNULL_END
