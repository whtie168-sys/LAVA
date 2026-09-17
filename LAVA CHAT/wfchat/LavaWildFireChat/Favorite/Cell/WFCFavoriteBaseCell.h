//
//  WFCFavoriteBaseCell.h
//  WildFireChat
//
//  Created by Tom Lee on 2020/11/1.
//  Copyright © 2020 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WFChatUIKitLava/WFChatUIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WFCFavoriteBaseCell : UITableViewCell
@property(nonatomic, strong)QWERFavoriteItem *favoriteItem;
@property(nonatomic, strong)UIView *asoucContentArea;

//子类实现，必须重新返回内容区高度
+ (CGFloat)contentHeight:(QWERFavoriteItem *)favoriteItem;

//基类实现，不能重写
+ (CGFloat)heightOf:(QWERFavoriteItem *)favoriteItem;
@end

NS_ASSUME_NONNULL_END
