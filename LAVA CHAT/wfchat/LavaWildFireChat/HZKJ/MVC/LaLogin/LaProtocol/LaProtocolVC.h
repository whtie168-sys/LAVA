//
//  LaProtocolVC.h
//  LAVA
//
//  Created by Rubyuer on 10/8/23.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaProtocolVC : LaMainVC

/**
 *  类型
 *  - 0  用户协议
 *  - 1  隐私政策
 *  - 2  快速注册用户协议
 *
 */
@property(nonatomic, assign) NSInteger eogcsaioxType;

@end

NS_ASSUME_NONNULL_END
