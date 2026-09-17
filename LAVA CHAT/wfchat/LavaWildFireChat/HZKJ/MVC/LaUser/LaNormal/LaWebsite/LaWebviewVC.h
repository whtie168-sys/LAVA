//
//  LaWebviewVC.h
//  WildFireChat
//
//  Created by Ruby on 1/15/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaWebviewVC : LaMainVC
// 0  LAVA官网    1 使用帮助  2 用户服务协议  3 隐私协议  4 法律申明
@property (nonatomic, assign) NSInteger type;
@end

NS_ASSUME_NONNULL_END
