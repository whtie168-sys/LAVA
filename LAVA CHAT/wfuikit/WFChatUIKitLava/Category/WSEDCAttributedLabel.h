//
//  UILabel+LinkUrl.h
//  WildFireChat
//
//  Created by heavyrain.lee on 2018/5/15.
//  Copyright © 2018 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSEDCAttributedLabelDelegate <NSObject>
@optional
- (void)didSelectUrl:(NSString *)urlString;
- (void)didSelectPhoneNumber:(NSString *)phoneNumberString;
@end

@interface WSEDCAttributedLabel : UILabel
@property(nonatomic, weak)id<WSEDCAttributedLabelDelegate> attributedLabelDelegate;
- (void)setText:(NSString *)text;
@end
