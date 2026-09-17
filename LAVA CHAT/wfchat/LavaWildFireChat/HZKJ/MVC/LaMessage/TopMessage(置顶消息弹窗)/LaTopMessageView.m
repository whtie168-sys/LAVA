//
//  LaTopMessageView.m
//  WildFireChat
//
//  Created by Rubyuer on 4/26/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaTopMessageView.h"
#import "LaAnnouncementMessageContent.h"


@interface LaTopMessageView ()

@property (weak, nonatomic) IBOutlet UIView *coaeoxAView;
@property (weak, nonatomic) IBOutlet UIView *coaeoxBView;

@property (weak, nonatomic) IBOutlet UIImageView *coaeoxImgView;
@property (weak, nonatomic) IBOutlet UILabel *coaeoxTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *coaeoxArrowView;

@end

@implementation LaTopMessageView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [NSBundle.mainBundle loadNibNamed:@"LaTopMessageView" owner:self options:nil].lastObject;
        self.frame = CGRectMake(0.0, 0.0, WIDTH, 60.0);
        self.userInteractionEnabled = YES;
        
        _coaeoxAView.layer.cornerRadius = 10.0;
        _coaeoxBView.layer.cornerRadius = 10.0;
        
        [_coaeoxRemoveBtn setTitle:@"" forState:UIControlStateNormal];
    }
    return self;
}

- (void)reloadView:(NSArray<MessageTopList *> *)results {
    self.coaeoxBView.hidden = (results.count == 1);
    
    BOOL isChinese = [CommonHelper.main isChinese];
    MessageTopList *topList = results.firstObject;
    if (topList.content.type == 2000) { 
//        _coaeoxRemoveBtn.hidden = YES;
//        _coaeoxArrowView.hidden = NO;
        
        _coaeoxImgView.image = IMAGENAME(@"coaeoxGG");
        _coaeoxTitleLabel.text = topList.content.searchableContent;
        [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateNormal];
        [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateSelected];
        return;
    }
    
    WFCCUserInfo *sender = [WFCCIMService.sharedWFCIMService getUserInfo:topList.fromUser refresh:NO];
    if (topList.content.type == 1) { // 文本消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), topList.content.searchableContent];
    }else if (topList.content.type == 1001) { // 公告消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxGG");
        _coaeoxTitleLabel.text = topList.content.searchableContent;
    }else if (topList.content.type == 5) { // 文件消息
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@] %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (isChinese ? @"文件" : @"tài liệu"), topList.content.searchableContent];
    }else if (topList.content.type == 3) { // 图片
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@] %@",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (isChinese ? @"图片" : @"hình ảnh"),topList.content.searchableContent];
    } else if (topList.content.type == 6) { // 视频
        _coaeoxImgView.image = IMAGENAME(@"coaeoxXX");
        _coaeoxTitleLabel.text = [NSString stringWithFormat:@"%@: [%@]",(sender.friendAlias.length ? sender.friendAlias : sender.displayName), (isChinese ? @"视频" : @"băng hình")];
    }
    _coaeoxRemoveBtn.hidden = NO;
    _coaeoxArrowView.hidden = YES;
    WFCCMessage *msg = [[WFCCIMService sharedWFCIMService] getMessageByUid:topList.messageUid];

    if (results.count == 1) {
        if (msg.status == Message_Status_Unread && topList.content.type == 3) {
            [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"PinnedImageLook")) forState:UIControlStateNormal];
            [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"PinnedImageLook")) forState:UIControlStateSelected];
        } else {
            [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"Remove")) forState:UIControlStateNormal];
            [_coaeoxRemoveBtn setTitle:UNString(@"  %@  ", LLLLLL(@"Unpinned")) forState:UIControlStateSelected];
        }
    }else {
        if (msg.status == Message_Status_Unread && topList.content.type == 3) {
            [_coaeoxRemoveBtn setTitle:UNString(@" %@", LLLLLL(@"PinnedImageLook")) forState:UIControlStateNormal];
        } else {
            [_coaeoxRemoveBtn setTitle:@"" forState:UIControlStateNormal];
        }
    }
}

@end
