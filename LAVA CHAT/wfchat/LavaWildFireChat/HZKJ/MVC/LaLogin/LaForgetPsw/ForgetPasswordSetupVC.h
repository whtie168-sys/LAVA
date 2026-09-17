//
//  ForgetPasswordSetupVC.h
//  WildFireChat
//
//  Created by Ruby on 2/2/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface ForgetPasswordSetupVC : LaMainVC

@property (nonatomic, assign) NSInteger type; // 0 手机号找回   1 邮箱找回
@property (nonatomic, strong) NSString *account;
@property (nonatomic, strong) NSString *code;
@property (nonatomic, strong) NSString *area;

@end

NS_ASSUME_NONNULL_END
