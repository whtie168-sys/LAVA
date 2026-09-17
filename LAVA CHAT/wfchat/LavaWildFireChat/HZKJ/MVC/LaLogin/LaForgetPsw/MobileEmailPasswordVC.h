//
//  MobileEmailPasswordVC.h
//  WildFireChat
//
//  Created by Ruby on 12/26/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface MobileEmailPasswordVC : LaMainVC

/**
 * 0 手机号
 * 1  邮箱
 */
@property (nonatomic, assign) NSInteger type;

@end

NS_ASSUME_NONNULL_END
