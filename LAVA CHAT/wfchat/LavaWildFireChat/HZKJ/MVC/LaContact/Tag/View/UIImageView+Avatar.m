//
//  UIImageView+Avatar.m
//  WildFireChat
//

#import "UIImageView+Avatar.h"
#import <SDWebImage/SDWebImage.h>

@implementation UIImageView (Avatar)

- (void)sd_setAvatarWithURLString:(NSString *)urlString
                      placeholder:(UIImage *)placeholder
                           userId:(NSString *)userId
                     cornerRadius:(CGFloat)cornerRadius {
    if (cornerRadius > 0) {
        self.layer.cornerRadius = cornerRadius;
        self.layer.masksToBounds = YES;
    }
    NSURL *url = urlString.length ? [NSURL URLWithString:urlString] : nil;
    [self sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageScaleDownLargeImages];
}

- (void)setAvatarIdentifier:(NSString *)identifier {
    // Compatibility shim for QXQ tag views. LAVA uses static placeholders here.
}

@end
