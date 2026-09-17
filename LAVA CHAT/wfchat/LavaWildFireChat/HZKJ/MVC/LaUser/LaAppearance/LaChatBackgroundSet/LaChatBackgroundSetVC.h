//
//  LaChatBackgroundSetVC.h
//  WildFireChat
//
//  Created by Rubyuer on 8/12/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaChatBackgroundSetVC : LaMainVC

@property(nonatomic, copy)void (^chatBackgroundSet)(float ceoxsoAlpha, NSInteger ceoxsoBgColorIndex);

@property (nonatomic, assign) NSInteger ceoxsoBubbleColorIndex; // kAppearanceBubbleColor 气泡颜色的索引
@property (nonatomic, assign) NSInteger ceoxsoChatBgImgIndex; // kAppearanceChatBackgroundImg 聊天背景图片索引

@property (nonatomic, assign) float ceoxsoAlpha;
@property (nonatomic, assign) NSInteger ceoxsoBgColorIndex;
@end

NS_ASSUME_NONNULL_END
