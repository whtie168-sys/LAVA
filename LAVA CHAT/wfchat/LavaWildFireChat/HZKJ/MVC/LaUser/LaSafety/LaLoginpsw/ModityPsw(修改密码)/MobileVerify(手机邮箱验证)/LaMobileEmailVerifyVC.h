//
//  LaMobileEmailVerifyVC.h
//  WildFireChat
//
//  Created by Ruby on 1/23/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaMobileEmailVerifyVC : LaMainVC

// YES 手机验证方式找回密码  否则 邮箱验证方式
@property (nonatomic, assign) BOOL isMobile;

@end

NS_ASSUME_NONNULL_END
