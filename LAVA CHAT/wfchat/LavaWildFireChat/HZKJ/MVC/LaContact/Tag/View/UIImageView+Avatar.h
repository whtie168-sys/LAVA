//
//  UIImageView+Avatar.h
//  WildFireChat
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (Avatar)

- (void)sd_setAvatarWithURLString:(NSString *)urlString
                      placeholder:(nullable UIImage *)placeholder
                           userId:(nullable NSString *)userId
                     cornerRadius:(CGFloat)cornerRadius;

- (void)setAvatarIdentifier:(NSString *)identifier;

@end

NS_ASSUME_NONNULL_END
