//
//  ShareMessageView.m
//  TYAlertControllerDemo
//
//  Created by tanyang on 15/10/26.
//  Copyright © 2015年 tanyang. All rights reserved.
//

#import "QWASZShareMessageView.h"
#import "UIView+TYAlertView.h"
#import "UITextView+Placeholder.h"
#import <SDWebImage/SDWebImage.h>
#import "QWERImage.h"

@interface QWASZShareMessageView ()
@property (weak, nonatomic) IBOutlet UIImageView *portraitImageView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *digestLabel;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *digestBackgrouView;
@end

@implementation QWASZShareMessageView
- (void)updateUI {
    self.digestBackgrouView.clipsToBounds = YES;
    self.digestBackgrouView.layer.masksToBounds = YES;
    self.digestBackgrouView.layer.cornerRadius = 8.f;
    self.messageTextView.placeholder = WFCString(@"LeaveMessage");
    self.messageTextView.layer.masksToBounds = YES;
    self.messageTextView.layer.cornerRadius = 8.f;
    self.messageTextView.contentInset = UIEdgeInsetsMake(2, 8, 2, 2);
    self.messageTextView.layer.borderWidth = 0.5f;
    self.messageTextView.layer.borderColor = [[UIColor greenColor] CGColor];
}

- (IBAction)sendAction:(id)sender {
    [self hideView];
    WFCCTextMessageContent *textMsg;
    if (self.messageTextView.text.length) {
        textMsg = [[WFCCTextMessageContent alloc] init];
        textMsg.text = self.messageTextView.text;
    }
    
    __strong WFCCConversation *conversation = self.conversation;
    __strong void (^forwardDone)(BOOL success) = self.forwardDone;
    
    if (self.message) {
        [[WFCCIMService sharedWFCIMService] send:conversation content:self.message.content success:^(long long messageUid, long long timestamp) {
            if (textMsg) {
                [[WFCCIMService sharedWFCIMService] send:conversation content:textMsg success:^(long long messageUid, long long timestamp) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (forwardDone) {
                            forwardDone(YES);
                        }
                    });
                } error:^(int error_code) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (forwardDone) {
                            forwardDone(NO);
                        }
                    });
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (forwardDone) {
                        forwardDone(YES);
                    }
                });
            }
        } error:^(int error_code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (forwardDone) {
                    forwardDone(NO);
                }
            });
        }];
    } else {
        for (WFCCMessage *msg in self.messages) {
            [[WFCCIMService sharedWFCIMService] send:conversation content:msg.content success:^(long long messageUid, long long timestamp) {
                
            } error:^(int error_code) {
                
            }];
            [NSThread sleepForTimeInterval:0.1];
        }
        if (textMsg) {
            [[WFCCIMService sharedWFCIMService] send:conversation content:textMsg success:^(long long messageUid, long long timestamp) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (forwardDone) {
                        forwardDone(YES);
                    }
                });
            } error:^(int error_code) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (forwardDone) {
                        forwardDone(NO);
                    }
                });
            }];
        } else {
            if (forwardDone) {
                forwardDone(YES);
            }
        }
    }
}

- (IBAction)cancelAction:(id)sender {
    [self hideView];
}

- (void)setConversation:(WFCCConversation *)conversation {
    [self updateUI];
    _conversation = conversation;
    NSString *name;
    NSString *portrait;
    
    if (conversation.type == Single_Type) {
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:conversation.target refresh:NO];
        if (userInfo) {
            name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
            portrait = userInfo.portrait;
        } else {
            name = [NSString stringWithFormat:@"%@<%@>", @"Người dùng", conversation.target];
        }
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else if (conversation.type == Group_Type) {
        WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:conversation.target refresh:NO];
        if (groupInfo) {
            name = groupInfo.displayName;
//            if (groupInfo.portrait.length) {
                [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[groupInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                                   context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
//            } else {
//                NSString *path = [WFCCUtilities getGroupGridPortrait:groupInfo.target width:80 generateIfNotExist:YES defaultUserPortrait:^UIImage *(NSString *userId) {
//                    return [QWERImage imageNamed:@"PersonalChat"];
//                }];
//                
//                if (path) {
//                    [self.portraitImageView sd_setImageWithURL:[NSURL fileURLWithPath:path] placeholderImage:[QWERImage imageNamed:@"groupIcon"]];
//                }
//            }
        } else {
            name = @"Nhóm";
            [self.portraitImageView setImage:[QWERImage imageNamed:@"groupIcon"]];
        }
    } else if (conversation.type == Channel_Type) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:conversation.target refresh:NO];
        if (channelInfo) {
            name = channelInfo.name;
            portrait = channelInfo.portrait;
        } else {
            name = @"频道";
        }
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"channel_default_portrait"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    } else if (conversation.type == SecretChat_Type) {
        NSString *userId = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:conversation.target].userId;
        WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userId refresh:NO];
        if (userInfo) {
            name = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
            portrait = userInfo.portrait;
        } else {
            name = [NSString stringWithFormat:@"%@<%@>", @"Người dùng", userId];
        }
        [self.portraitImageView sd_setImageWithURL:[NSURL URLWithString:[portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                           context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    }
    
    if ([conversation.target isEqualToString:@"FireRobot"] && [name isEqualToString:@"小火"]) {
        name = @"LAVA Quản lý";
    }
    
    self.asoucNameLabel.text = name;
}

- (void)setMessage:(WFCCMessage *)message {
    _message = message;
    if (message) {
        self.digestLabel.text = [message.content digest:message];
    }
}
- (void)setMessages:(NSArray<WFCCMessage *> *)messages {
    _messages = messages;
    if (messages.count) {
        self.digestLabel.text = [NSString stringWithFormat:@"[Chuyển tiếp từng tin] %ld tin nhắn", messages.count];
    }
}
@end
