//
//  LaNormalQrcodeVC.h
//  WildFireChat
//
//  Created by Ruby on 11/14/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaNormalQrcodeVC : LaMainVC

@property (nonatomic, assign) int qrType;
@property (nonatomic, strong) NSString *target;
@property (nonatomic, strong) NSString *conferenceUrl;
@property (nonatomic, strong) NSString *conferenceTitle;

@end

NS_ASSUME_NONNULL_END
