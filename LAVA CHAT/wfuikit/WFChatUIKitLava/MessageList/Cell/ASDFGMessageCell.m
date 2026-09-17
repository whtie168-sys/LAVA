//
//  MessageCell.m
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/1.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "ASDFGMessageCell.h"
#import "QWERUtilities.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "ZCCCircleProgressView.h"
#import "QWERConfigManager.h"
#import "QWERImage.h"

#define Portrait_Size 40
#define SelectView_Size 20
#define Name_Label_Height  14
#define Name_Label_Padding  6
#define Name_Client_Padding  2
#define Portrait_Padding_Left 16
#define Portrait_Padding_Right 16
#define Portrait_Padding_Buttom 4

#define Client_Arad_Buttom_Padding 8

#define Client_Bubble_Top_Padding  6
#define Client_Bubble_Bottom_Padding  4

#define Bubble_Padding_Arraw 16
#define Bubble_Padding_Another_Side 8

#define MESSAGE_BASE_CELL_QUOTE_SIZE 14


@interface ASDFGMessageCell ()
@property (nonatomic, strong)UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, strong)UIImageView *failureView;
@property (nonatomic, strong)UIImageView *maskView;

@property (nonatomic, strong)ZCCCircleProgressView *receiptView;

@property (nonatomic, strong)UIImageView *selectView;
@end

@implementation ASDFGMessageCell
+ (CGFloat)clientAreaWidth {
  return [ASDFGMessageCell bubbleWidth] - Bubble_Padding_Arraw - Bubble_Padding_Another_Side;
}

+ (CGFloat)bubbleWidth {
//    return ([UIScreen mainScreen].bounds.size.width - Portrait_Size - Portrait_Padding_Left - Portrait_Padding_Right) * 0.7; // 0509注释了
    return ([UIScreen mainScreen].bounds.size.width - Portrait_Size * 2.0 - Portrait_Padding_Left * 2.0 - Portrait_Padding_Right);
}

+ (CGSize)sizeForCell:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
  CGFloat height = [super hightForHeaderArea:msgModel];
  CGFloat portraitSize = Portrait_Size;
  CGFloat asoucNameLabelHeight = Name_Label_Height + Name_Client_Padding;
  CGFloat clientAreaWidth = [self clientAreaWidth];
  
  CGSize clientArea = [self sizeForClientArea:msgModel withViewWidth:clientAreaWidth];
  CGFloat nameAndClientHeight = clientArea.height;
  if (msgModel.showasoucNameLabel) {
    nameAndClientHeight += asoucNameLabelHeight;
  }
    
    nameAndClientHeight += Client_Bubble_Top_Padding;
    nameAndClientHeight += Client_Bubble_Bottom_Padding;
    
  if (portraitSize + Portrait_Padding_Buttom > nameAndClientHeight) {
    height += portraitSize + Portrait_Padding_Buttom;
  } else {
    height += nameAndClientHeight;
  }
  height += Client_Arad_Buttom_Padding;   //buttom padding
    
  height += [self sizeForQuoteArea:msgModel withViewWidth:clientAreaWidth].height;
    
  return CGSizeMake(width, height);
}

+ (CGSize)sizeForClientArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
  return CGSizeZero;
}

+ (CGSize)sizeForQuoteArea:(QWERTMessageModel *)msgModel withViewWidth:(CGFloat)width {
    if ([msgModel.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)msgModel.message.content;
        if (txtContent.quoteInfo) {
            CGFloat quoteWidth = width - Portrait_Size - Portrait_Padding_Right - Portrait_Size - Portrait_Padding_Left - 8;
            NSString *quoteTxt = [NSString stringWithFormat:@"%@:%@", txtContent.quoteInfo.userDisplayName, txtContent.quoteInfo.messageDigest];
            CGSize size = [QWERUtilities getTextDrawingSize:quoteTxt font:[UIFont systemFontOfSize:MESSAGE_BASE_CELL_QUOTE_SIZE] constrainedSize:CGSizeMake(quoteWidth, 44)];
            size.height += 12;
            size.width = width;
            return size;
        }
    }
    return CGSizeZero;
}

- (void)updateStatus {
    if (self.model.message.direction == MessageDirection_Send) {
        if (self.model.message.status == Message_Status_Sending) {
            CGRect frame = self.asoucBubbleView.frame;
            frame.origin.x -= 24;
            frame.origin.y = frame.origin.y + frame.size.height - 24;
            frame.size.width = 20;
            frame.size.height = 20;
            self.activityIndicatorView.hidden = NO;
            self.activityIndicatorView.frame = frame;
            [self.activityIndicatorView startAnimating];
        } else {
            [_activityIndicatorView stopAnimating];
            _activityIndicatorView.hidden = YES;
            [self updateReceiptView];
        }
        
        if (self.model.message.status == Message_Status_Send_Failure) {
            CGRect frame = self.asoucBubbleView.frame;
            frame.origin.x -= 24;
            frame.origin.y = frame.origin.y + frame.size.height - 24;
            frame.size.width = 20;
            frame.size.height = 20;
            self.failureView.frame = frame;
            self.failureView.hidden = NO;
        } else {
            _failureView.hidden = YES;
        }
    } else {
        [_activityIndicatorView stopAnimating];
        _activityIndicatorView.hidden = YES;
        _failureView.hidden = YES;
    }
}

-(void)onStatusChanged:(NSNotification *)notification {
    if(self.model.message.messageId == [notification.object longLongValue]) {
        WFCCMessageStatus newStatus = (WFCCMessageStatus)[[notification.userInfo objectForKey:@"status"] integerValue];
        self.model.message.status = newStatus;
        [self updateStatus];
    }
}
  
- (void)onUserInfoUpdated:(NSNotification *)notification {
    if (self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive) {
        return;
    }
    
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (WFCCUserInfo *userInfo in userInfoList) {
        if([userInfo.userId isEqualToString:self.model.message.fromUser]) {
            if (self.model.message.conversation.type == Group_Type) {
                WFCCUserInfo *reloadUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:userInfo.userId inGroup:self.model.message.conversation.target refresh:NO];
                [self updateUserInfo:reloadUserInfo];
            } else {
                [self updateUserInfo:userInfo];
            }
          
            break;
        }
    }
}

- (void)updateChannelInfo:(WFCCChannelInfo *)channelInfo {
  if(self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive && [self.model.message.conversation.target isEqualToString:channelInfo.channelId]) {
    [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[channelInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
      if(self.model.showasoucNameLabel) {
          self.asoucNameLabel.text = channelInfo.name;
      }
  }
}

- (void)updateUserInfo:(WFCCUserInfo *)userInfo {
  if([userInfo.userId isEqualToString:self.model.message.fromUser]) {
    [self.trewqPortraitView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                                       context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
      if(self.model.showasoucNameLabel) {
          NSString *nameStr = nil;
          if (userInfo.friendAlias.length) {
              nameStr = userInfo.friendAlias;
          } else if(userInfo.groupAlias.length) {
              if(userInfo.displayName.length > 0) {
                  nameStr = [userInfo.groupAlias stringByAppendingFormat:@"(%@)", userInfo.displayName];
              } else {
                  nameStr = userInfo.groupAlias;
              }
          } else if(userInfo.displayName.length > 0) {
              nameStr = userInfo.displayName;
          } else {
              nameStr = [NSString stringWithFormat:@"%@<%@>", @"用户", self.model.message.fromUser];
          }
          self.asoucNameLabel.text = nameStr;
      }
  }
}

- (void)setModel:(QWERTMessageModel *)model {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onStatusChanged:) name:kSendingMessageStatusUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
  
  [super setModel:model];

  CGFloat selectViewOffset = model.selecting ? SelectView_Size + Portrait_Padding_Right : 0;
  if (model.message.direction == MessageDirection_Send) {
    CGFloat top = [ASDFGMessageCellBase hightForHeaderArea:model];
    CGRect frame = self.frame;
    self.trewqPortraitView.frame = CGRectMake(frame.size.width - Portrait_Size - Portrait_Padding_Right - selectViewOffset, top, Portrait_Size, Portrait_Size);
    if (model.showasoucNameLabel) {
      self.asoucNameLabel.frame = CGRectMake(frame.size.width - Portrait_Size - Portrait_Padding_Right - Name_Label_Padding - 200 - selectViewOffset, top, 200, Name_Label_Height);
      self.asoucNameLabel.hidden = NO;
      self.asoucNameLabel.textAlignment = NSTextAlignmentRight;
    } else {
      self.asoucNameLabel.hidden = YES;
    }

      
      CGSize size = [self.class sizeForClientArea:model withViewWidth:[ASDFGMessageCell clientAreaWidth]];
      if ([model.message.content isKindOfClass:NSClassFromString(@"ESIXAnnouncementMessageContent")]) { //
          self.asoucBubbleView.image = [UIImage imageNamed:@"sent_msg_background_blue"];
      }else {
          self.asoucBubbleView.image = [UIImage imageNamed:@"sent_msg_background0"];
          if ([NSUserDefaults.standardUserDefaults boolForKey:@"AppearanceStatus"] == NO) { // NO  纯净模式
              self.asoucBubbleView.image = [UIImage imageNamed:@"sent_msg_background0"];
          }else { // 0815新增
              NSInteger bubbleColorIndex = [NSUserDefaults.standardUserDefaults integerForKey:@"AppearanceBubbleColor"];
              self.asoucBubbleView.image = [UIImage imageNamed:[NSString stringWithFormat:@"sent_msg_background%ld",bubbleColorIndex]];
          }
      }
      
      self.asoucBubbleView.frame = CGRectMake(frame.size.width - Portrait_Size - Portrait_Padding_Right - Name_Label_Padding - size.width - Bubble_Padding_Arraw - Bubble_Padding_Another_Side - selectViewOffset, top + Name_Client_Padding, size.width + Bubble_Padding_Arraw + Bubble_Padding_Another_Side, size.height + Client_Bubble_Top_Padding + Client_Bubble_Bottom_Padding);
    self.asoucContentArea.frame = CGRectMake(Bubble_Padding_Another_Side, Client_Bubble_Top_Padding, size.width, size.height);
      
      UIImage *image = self.asoucBubbleView.image;
      self.asoucBubbleView.image = [self.asoucBubbleView.image
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.95, image.size.width * 0.2,image.size.height * 0.1, image.size.width * 0.05)];
      
      [self updateReceiptView];
  } else {
    CGFloat top = [ASDFGMessageCellBase hightForHeaderArea:model];
    self.trewqPortraitView.frame = CGRectMake(Portrait_Padding_Left, top, Portrait_Size, Portrait_Size);
    if (model.showasoucNameLabel) {
      self.asoucNameLabel.frame = CGRectMake(Portrait_Padding_Left + Portrait_Size + Name_Label_Padding, top, 200, Name_Label_Height);
      self.asoucNameLabel.hidden = NO;
      self.asoucNameLabel.textAlignment = NSTextAlignmentLeft;
      top +=  Name_Label_Height + Name_Client_Padding;
    } else {
      self.asoucNameLabel.hidden = YES;
    }
      
      
      
      NSString *bubbleImageName = @"received_msg_background";
      if (@available(iOS 13.0, *)) {
          if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
              bubbleImageName = @"chat_from_bg_normal_dark";
          }
      }
      
    CGSize size = [self.class sizeForClientArea:model withViewWidth:[ASDFGMessageCell clientAreaWidth]];
//      self.asoucBubbleView.image = [QWERImage imageNamed:bubbleImageName];
      self.asoucBubbleView.image = [UIImage imageNamed:bubbleImageName];
      self.asoucBubbleView.frame = CGRectMake(Portrait_Padding_Left + Portrait_Size + Name_Label_Padding, top, size.width + Bubble_Padding_Arraw + Bubble_Padding_Another_Side, size.height + Client_Bubble_Top_Padding + Client_Bubble_Bottom_Padding);
    self.asoucContentArea.frame = CGRectMake(Bubble_Padding_Arraw, Client_Bubble_Top_Padding, size.width, size.height);
//      self.asoucBubbleView.backgroundColor = RGBCOLOR(255.0, 242.0, 219.0);
      
      UIImage *image = self.asoucBubbleView.image;
      CGFloat leftProtection = image.size.width * 0.8;
      CGFloat rightProtection = image.size.width * 0.2;

      if (self.asoucBubbleView.frame.size.width < image.size.width) {
          leftProtection = 17;
          rightProtection = 12;
      }
      self.asoucBubbleView.image = [self.asoucBubbleView.image
                                         resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height * 0.8, leftProtection,
                                                                                      image.size.height * 0.2, rightProtection)];
      
      self.receiptView.hidden = YES;
      self.asoucUnreadButton.hidden = YES;
  }
    
    if (model.selecting) {
        self.selectView.hidden = NO;
        if (model.selected) {
            self.selectView.image = [QWERImage imageNamed:@"multi_selected"];
        } else {
            self.selectView.image = [QWERImage imageNamed:@"multi_unselected"];
        }
        CGFloat top = [ASDFGMessageCellBase hightForHeaderArea:model];
        CGRect frame = self.selectView.frame;
        frame.origin.y = top;
        self.selectView.frame = frame;
    } else {
        self.selectView.hidden = YES;
    }
    
    NSString *groupId = nil;
    if (self.model.message.conversation.type == Group_Type) {
        groupId = self.model.message.conversation.target;
    }
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:model.message.fromUser inGroup:groupId refresh:NO];
  if(userInfo.userId.length == 0) {
    userInfo = [[WFCCUserInfo alloc] init];
    userInfo.userId = model.message.fromUser;
  }
  
    if (self.model.message.conversation.type == Channel_Type && self.model.message.direction == MessageDirection_Receive) {
        WFCCChannelInfo *channelInfo = [[WFCCIMService sharedWFCIMService] getChannelInfo:self.model.message.conversation.target refresh:NO];
        [self updateChannelInfo:channelInfo];
    } else {
        [self updateUserInfo:userInfo];
    }
    
  
  [self setMaskImage:self.asoucBubbleView.image];
  [self updateStatus];
    
    if (model.highlighted) {
        UIColor *bkColor = self.backgroundColor;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            self.backgroundColor = [UIColor grayColor];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.backgroundColor = bkColor;
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    self.backgroundColor = [UIColor grayColor];
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        self.backgroundColor = bkColor;
                    });
                });
            });
        });
        model.highlighted = NO;
    }
    
    self.asoucQuoteContainer.hidden = YES;
    if ([model.message.content isKindOfClass:[WFCCTextMessageContent class]]) {
        WFCCTextMessageContent *txtContent = (WFCCTextMessageContent *)model.message.content;
        if (txtContent.quoteInfo) {
            if (!self.asoucQuoteLabel) {
                self.asoucQuoteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
                self.asoucQuoteLabel.font = [UIFont systemFontOfSize:MESSAGE_BASE_CELL_QUOTE_SIZE];
                self.asoucQuoteLabel.numberOfLines = 0;
                self.asoucQuoteLabel.layer.cornerRadius = 3.f;
                self.asoucQuoteLabel.layer.masksToBounds = YES;
                self.asoucQuoteLabel.userInteractionEnabled = YES;
                self.asoucQuoteLabel.textColor = [UIColor grayColor];
                [self.asoucQuoteLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onasoucQuoteLabelTaped:)]];
                
                self.asoucQuoteContainer = [[UIView alloc] initWithFrame:CGRectZero];
                self.asoucQuoteContainer.backgroundColor = [UIColor colorWithRed:0.85 green:0.85 blue:0.85 alpha:1.f];
                self.asoucQuoteContainer.layer.cornerRadius = 3.f;
                self.asoucQuoteContainer.layer.masksToBounds = YES;
                [self.asoucQuoteContainer addSubview:self.asoucQuoteLabel];
                [self.contentView addSubview:self.asoucQuoteContainer];
            }
            CGSize size = [self.class sizeForQuoteArea:model withViewWidth:[ASDFGMessageCell clientAreaWidth]];
            
            CGRect frame;
            if (model.message.direction == MessageDirection_Send) {
                frame = CGRectMake(self.frame.size.width - Portrait_Size - Portrait_Padding_Right - Name_Label_Padding - size.width - Bubble_Padding_Another_Side - selectViewOffset, self.asoucBubbleView.frame.origin.y + self.asoucBubbleView.frame.size.height + 4, size.width, size.height-4);
            } else {
                frame = CGRectMake(Portrait_Padding_Left + Portrait_Size + Name_Label_Padding + Bubble_Padding_Arraw, self.asoucBubbleView.frame.origin.y + self.asoucBubbleView.frame.size.height + 4, size.width, size.height-4);
            }
            self.asoucQuoteContainer.frame = frame;
            frame = self.asoucQuoteContainer.bounds;
            frame.size.height -= 8;
            frame.size.width -= 8;
            frame.origin.x += 4;
            frame.origin.y += 4;
            self.asoucQuoteLabel.frame = frame;
            
            self.asoucQuoteContainer.hidden = NO;
            self.asoucQuoteLabel.text = [NSString stringWithFormat:@"%@:%@", txtContent.quoteInfo.userDisplayName, txtContent.quoteInfo.messageDigest];
        }
    }
}

- (void)updateReceiptView {
    // 是否支持已送达报告和已阅读报告
//    NSLog(@"isReceiptEnabled======%d",[[WFCCIMService sharedWFCIMService] isReceiptEnabled]);
    QWERTMessageModel *model = self.model;
    if (model.message.direction == MessageDirection_Send) {
        if([model.message.content.class getContentFlags] == WFCCPersistFlag_PERSIST_AND_COUNT && (model.message.status == Message_Status_Sent || model.message.status == Message_Status_Readed) && [[WFCCIMService sharedWFCIMService] isReceiptEnabled] && [[WFCCIMService sharedWFCIMService] isUserEnableReceipt] && ![model.message.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
            if (model.message.conversation.type == Single_Type) {
                if (model.message.serverTime <= [[model.readDict objectForKey:model.message.conversation.target] longLongValue]) {
                    [self.receiptView setProgress:1 subProgress:1];
                    self.asoucUnreadButton.selected = YES;
                } else if (model.message.serverTime <= [[model.deliveryDict objectForKey:model.message.conversation.target] longLongValue]) {
                    [self.receiptView setProgress:0 subProgress:1];
                    self.asoucUnreadButton.selected = NO;
                } else {
                    [self.receiptView setProgress:0 subProgress:0];
                    self.asoucUnreadButton.selected = NO;
                }
                if([model.message.conversation.target isEqualToString:[QWERConfigManager globalManager].fileTransferId]) {
                    self.receiptView.hidden = YES;
                    self.asoucUnreadButton.hidden = YES;
                } else {
                    self.receiptView.hidden = NO;
                    self.asoucUnreadButton.hidden = NO;
                }
            } else if(model.message.conversation.type == SecretChat_Type) {
                WFCCSecretChatInfo *secretChatInfo = [[WFCCIMService sharedWFCIMService] getSecretChatInfo:model.message.conversation.target];
                if(secretChatInfo.targetId.length) {
                    if (model.message.serverTime <= [[model.readDict objectForKey:secretChatInfo.userId] longLongValue]) {
                        [self.receiptView setProgress:1 subProgress:1];
                        self.asoucUnreadButton.selected = YES;
                    } else if (model.message.serverTime <= [[model.deliveryDict objectForKey:secretChatInfo.userId] longLongValue]) {
                        [self.receiptView setProgress:0 subProgress:1];
                        self.asoucUnreadButton.selected = NO;
                    } else {
                        [self.receiptView setProgress:0 subProgress:0];
                        self.asoucUnreadButton.selected = NO;
                    }
                    self.receiptView.hidden = NO;
                    self.asoucUnreadButton.hidden = NO;
                } else {
                    self.receiptView.hidden = YES;
                    self.asoucUnreadButton.hidden = YES;
                }
            } else if(model.message.conversation.type == Group_Type) {
                long long messageTS = model.message.serverTime;
                
                WFCCGroupInfo *groupInfo = nil;
                if (model.deliveryRate == -1) {
                    __block int delieveriedCount = 0;

                    [model.deliveryDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj longLongValue] >= messageTS) {
                            delieveriedCount++;
                        }
                    }];
                    groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                    model.deliveryRate = (float)delieveriedCount/(groupInfo.memberCount - 1);
                }
                if (model.readRate == -1) {
                    __block int readedCount = 0;

                    [model.readDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSNumber * _Nonnull obj, BOOL * _Nonnull stop) {
                        if ([obj longLongValue] >= messageTS) {
                            readedCount++;
                        }
                    }];
                    if (!groupInfo) {
                        groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:model.message.conversation.target refresh:NO];
                    }
                    
                    model.readRate = (float)readedCount/(groupInfo.memberCount - 1);
                }
              
                
                if (model.deliveryRate < model.readRate) {
                    model.deliveryRate = model.readRate;
                }
                self.asoucUnreadButton.selected = (model.readRate > 0);
                [self.receiptView setProgress:model.readRate subProgress:model.deliveryRate];
                self.receiptView.hidden = NO;
                self.asoucUnreadButton.hidden = NO;
            } else {
                self.receiptView.hidden = YES;
                self.asoucUnreadButton.hidden = YES;
            }
        } else {
            self.receiptView.hidden = YES;
            self.asoucUnreadButton.hidden = YES;
        }
        
        if (self.asoucUnreadButton.hidden == NO) { // 1124新增 asoucUnreadButton 1124新增
//            self.asoucUnreadButton.frame = CGRectMake(self.asoucBubbleView.frame.origin.x-31.0, (self.frame.size.height - 20)/2.0, 31, 20);
            self.asoucUnreadButton.frame = CGRectMake(self.asoucBubbleView.frame.origin.x-31.0, CGRectGetMidY(self.asoucBubbleView.frame)-10.0, 31, 20);
        }

        self.receiptView.hidden = YES; // 强制隐藏
//        if (self.receiptView.hidden == NO) {
//            self.receiptView.frame = CGRectMake(self.asoucBubbleView.frame.origin.x - 20, self.frame.size.height - 24 , 14, 14);
//        }
    }
}

- (void)onasoucQuoteLabelTaped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapasoucQuoteLabel:withModel:)]) {
        [self.delegate didTapasoucQuoteLabel:self withModel:self.model];
    }
}
// 点击已读未读的圈圈
- (void)onTapReceiptView:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTapReceiptView:withModel:)] && self.model.message.conversation.type == Group_Type) {
        [self.delegate didTapReceiptView:self withModel:self.model];
    }
}
- (void)setMaskImage:(UIImage *)maskImage{
    if (_maskView == nil) {
        _maskView = [[UIImageView alloc] initWithImage:maskImage];
        
        _maskView.frame = self.asoucBubbleView.bounds;
        self.asoucBubbleView.layer.mask = _maskView.layer;
        self.asoucBubbleView.layer.masksToBounds = YES;
    } else {
        _maskView.image = maskImage;
        _maskView.frame = self.asoucBubbleView.bounds;
    }
}

- (ZCCCircleProgressView *)receiptView {
    if (!_receiptView) {
        _receiptView = [[ZCCCircleProgressView alloc] initWithFrame:CGRectMake(0, 0, 14, 14)];
        _receiptView.hidden = YES;
        _receiptView.userInteractionEnabled = YES;
        [_receiptView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReceiptView:)]];
        [self.contentView addSubview:_receiptView];
    }
    return _receiptView;
}

- (UIImageView *)trewqPortraitView {
  if (!_trewqPortraitView) {
      _trewqPortraitView = [[UIImageView alloc] init];
      _trewqPortraitView.clipsToBounds = YES;
      _trewqPortraitView.layer.cornerRadius = 20.0;
      [_trewqPortraitView setImage:[QWERImage imageNamed:@"PersonalChat"]];
    
      [_trewqPortraitView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapPortrait:)]];
      [_trewqPortraitView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPressPortrait:)]];
      
      _trewqPortraitView.userInteractionEnabled=YES;
    
      [self.contentView addSubview:_trewqPortraitView];
    }return _trewqPortraitView;
}
- (UIButton *)asoucUnreadButton {
    if (!_asoucUnreadButton) {
        _asoucUnreadButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _asoucUnreadButton.backgroundColor = UIColor.clearColor;
//        _asoucUnreadButton.userInteractionEnabled = NO;
        _asoucUnreadButton.hidden = YES;
        [_asoucUnreadButton setImage:[QWERImage imageNamed:@"oxgcseoaiUnread"] forState:UIControlStateNormal];
        [_asoucUnreadButton setImage:[QWERImage imageNamed:@"oxgcseoaiRead"] forState:UIControlStateSelected];
        [_asoucUnreadButton addTarget:self action:@selector(onTapReceiptView:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_asoucUnreadButton];
    }return _asoucUnreadButton;
}

- (void)didTapPortrait:(id)sender {
  [self.delegate didTapMessagePortrait:self withModel:self.model];
}

- (void)didLongPressPortrait:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self.delegate didLongPressMessagePortrait:self withModel:self.model];
    }
}

- (UILabel *)asoucNameLabel {
  if (!_asoucNameLabel) {
    _asoucNameLabel = [[UILabel alloc] init];
    _asoucNameLabel.font = [UIFont systemFontOfSize:Name_Label_Height-2];
    _asoucNameLabel.textColor = [UIColor grayColor];
    [self.contentView addSubview:_asoucNameLabel];
  }
  return _asoucNameLabel;
}

- (UIView *)asoucContentArea {
  if (!_asoucContentArea) {
    _asoucContentArea = [[UIView alloc] init];
    [self.asoucBubbleView addSubview:_asoucContentArea];
  }
  return _asoucContentArea;
}
- (UIImageView *)asoucBubbleView {
    if (!_asoucBubbleView) {
        _asoucBubbleView = [[UIImageView alloc] init];
        [self.contentView addSubview:_asoucBubbleView];
        [_asoucBubbleView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPressed:)]];
        
        UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onDoubleTaped:)];
        doubleTapGesture.numberOfTapsRequired = 2;
        doubleTapGesture.numberOfTouchesRequired = 1;
        [_asoucBubbleView addGestureRecognizer:doubleTapGesture];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTaped:)];
        [_asoucBubbleView addGestureRecognizer:tap];
        [tap requireGestureRecognizerToFail:doubleTapGesture];
        tap.cancelsTouchesInView = NO;
        [_asoucBubbleView setUserInteractionEnabled:YES];
    }
    return _asoucBubbleView;
}
//- (void)onDoubleTaped:(UITapGestureRecognizer *)tap {
//
//}
- (UIActivityIndicatorView *)activityIndicatorView {
    if (!_activityIndicatorView) {
        _activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_activityIndicatorView];
    }
    return _activityIndicatorView;
}
- (UIImageView *)failureView {
    if (!_failureView) {
        _failureView = [[UIImageView alloc] init];
        _failureView.image = [QWERImage imageNamed:@"failure"];
        [_failureView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onResend:)]];
        [_failureView setUserInteractionEnabled:YES];
        [self.contentView addSubview:_failureView];
    }
    return _failureView;
}

- (UIImageView *)selectView {
    if(!_selectView) {
        CGFloat top = [ASDFGMessageCellBase hightForHeaderArea:self.model];
        CGRect frame = self.frame;
        frame = CGRectMake(frame.size.width - SelectView_Size - Portrait_Padding_Right, top, SelectView_Size, SelectView_Size);
        
        _selectView = [[UIImageView alloc] initWithFrame:frame];
        _selectView.image = [QWERImage imageNamed:@"multi_unselected"];
        UIGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelect:)];
        [_selectView addGestureRecognizer:tap];
        _selectView.userInteractionEnabled = YES;
        [self.contentView addSubview:_selectView];
    }
    return _selectView;
}

- (void)onSelect:(id)sender {
    self.model.selected = !self.model.selected;
    if (self.model.selected) {
        self.selectView.image = [QWERImage imageNamed:@"multi_selected"];
    } else {
        self.selectView.image = [QWERImage imageNamed:@"multi_unselected"];
    }
}

- (void)onResend:(id)sender {
    [self.delegate didTapResendBtn:self.model];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.trewqPortraitView sd_cancelCurrentImageLoad];
    self.trewqPortraitView.image = nil;
}
@end
