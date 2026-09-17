//
//  LaGroupAnnouncementVC.m
//  WildFireChat
//
//  Created by Ruby on 11/29/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaGroupAnnouncementVC.h"

@interface LaGroupAnnouncementVC ()<UITextViewDelegate>
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *nullView;
@property (weak, nonatomic) IBOutlet UILabel *noGGL;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *ownerLabel;


@property (weak, nonatomic) IBOutlet UIView *contentBgView;
//@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewLeft;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeight;

@end

@implementation LaGroupAnnouncementVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self initAnnouncementData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"GroupAnnouncement");
    _isChinese = [CommonHelper.main isChinese];
    
    if (_isCanPost) {
        if (_type == Member_Type_Manager || _type == Member_Type_Owner) {
            UIButton *item = [self itemTitle:LLLLLL(@"Clear") action:@selector(clearAll)];
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:item];
        }
    }else {
        _postButton.hidden = YES;
        _textViewTop.constant = 0.0;
        _textViewLeft.constant = 0.0;
        _contentBgView.backgroundColor = UIColor.clearColor;
    }
    
    _scrollView.hidden = YES;
    _nullView.hidden = YES;
    _postButton.layer.cornerRadius = 20.0;
    _iconView.layer.cornerRadius = 25.0;
    _ownerLabel.layer.cornerRadius = 14.0;
    _ownerLabel.layer.masksToBounds = YES;
    _contentBgView.layer.cornerRadius = 20.0;
    
    if (_type == Member_Type_Owner) {
        _ownerLabel.text = UNString(@"   %@   ", LLLLLL(@"Owner"));
    }else if (_type == Member_Type_Manager) {
        _ownerLabel.text = [NSString stringWithFormat:@"   %@   ",LLLLLL(@"Manager")];
    }else {
        _ownerLabel.text = @"";
        _ownerLabel.hidden = YES;
    }
    
    _textView.delegate = self;
    _textView.editable = NO;
    _textView.dataDetectorTypes = UIDataDetectorTypeAll;
    
    if (_isChinese) {
        
    }else {
        _noGGL.text = @"Không có thông báo...";
        [_postButton setTitle:@"Chỉnh sửa thông báo" forState:UIControlStateNormal];
    }
}

- (IBAction)post:(UIButton *)sender {
    __block BOOL isManager = NO;
    __block WFCCGroupMember *myM;

    WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:(_announcement != nil ? _announcement.groupId : _groupId) refresh:YES];
    if ([groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        isManager = YES;
    }else {
        NSArray<WFCCGroupMember *> *groupMembers = [[WFCCIMService sharedWFCIMService] getGroupMembers:(_announcement != nil ? _announcement.groupId : _groupId) forceUpdate:NO];
        [groupMembers enumerateObjectsUsingBlock:^(WFCCGroupMember * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
                myM = obj;
                if (obj.type == Member_Type_Manager || obj.type == Member_Type_Owner) {
                    isManager = YES;
                }
                *stop = YES;
            }
        }];
    }
    
    if (!isManager) {
        [self.view makeToast:(_isChinese?@"仅群主和管理员可发布公告":@"Chỉ chủ nhóm và quản trị viên mới có thể đưa ra thông báo") duration:1.2 position:CSToastPositionCenter];
        return;
    }
    WFCCGroupMember *myQx = [WFCCGroupMember mj_objectWithKeyValues:myM.extra];
    if (![myQx.pushNotice isEqualToString:@"1"] && ![groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        [self.view makeToast:LLLLLL(@"GroupAccessManagerInsufficientPermissions") duration:1 position:CSToastPositionCenter];
        return;
    }
    LaEditAnnouncementVC *vc = LaEditAnnouncementVC.new;
    vc.groupId = (_announcement != nil ? _announcement.groupId : _groupId);
    vc.announcementText = (_announcement != nil ? _announcement.text : @"");
    WS(weakself)
    [vc setEditAnnouncementBlock:^(TREWQGroupAnnouncement * _Nonnull announcement) {
        weakself.announcement = announcement;
        [weakself initAnnouncementData];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)initAnnouncementData {
    if (self.announcement.author.length && self.announcement.text.length) { // 存在群公告
        _scrollView.hidden = NO;
        _nullView.hidden = YES;
        
        WFCCUserInfo *author = [[WFCCIMService sharedWFCIMService] getUserInfo:_announcement.author refresh:NO];
        
        [_iconView sd_setImageWithURL:URL(author.portrait) placeholderImage: [QWERImage imageNamed:@"PersonalChat"]];
        _asoucNameLabel.text = (author.friendAlias.length > 0 ? author.friendAlias : author.displayName);
        _dateLabel.text = [UNString(@"%ld", _announcement.timestamp) timeIntervalDateFormat:@"yyyy-MM-dd HH:mm"];
        
//        _contentLabel.text = _announcement.text;
        _textView.text = _announcement.text;
        
        CGSize size = [QWERUtilities getTextDrawingSize:_announcement.text font:[UIFont pingFangSCWithWeight:FontWeightStyleMedium size:14.0] constrainedSize:CGSizeMake(WIDTH-64.0, 8000)];
        _textViewHeight.constant = size.height + 20.0;
    }else {
        _scrollView.hidden = YES;
        _nullView.hidden = NO;
    }
}

- (void)clearAll {
    WFCCGroupInfo *groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:(_announcement != nil ? _announcement.groupId : _groupId) refresh:YES];
    if (![[self getMyself].pushNotice isEqualToString:@"1"] && ![groupInfo.owner isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
        [self.view makeToast:LLLLLL(@"GroupAccessManagerInsufficientPermissions") duration:1 position:CSToastPositionCenter];
        return;
    }
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese?@"您确定要清空群公告吗？":@"Bạn có chắc chắn muốn xóa thông báo?") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [weakself deleteAnnouncement];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
- (void)deleteAnnouncement {
    WS(weakself)
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Deleting");
    [hud showAnimated:YES];

    [AppService.sharedAppService requestUrl:@"/delete_group_announcement" params:@{@"groupId":(_announcement != nil ? _announcement.groupId : _groupId)} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        if (weakself.deleteAnnouncementBlock) {
            weakself.deleteAnnouncementBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction {
    NSString *resultStr = [textView.text substringWithRange:characterRange];
    
    if ([URL.scheme containsString:@"http"]) { // url
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:resultStr message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        WS(weakself)
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *openAction = [UIAlertAction actionWithTitle:LLLLLL(@"OpenTheLink") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            RWADCBrowserVC *bvc = [[RWADCBrowserVC alloc] init];
            bvc.url = resultStr;
            [weakself.navigationController pushViewController:bvc animated:YES];
        }];
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:LLLLLL(@"Copy") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = resultStr;
            [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
            [SVProgressHUD dismissWithDelay:1.0];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:openAction];
        [alertController addAction:copyAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }else if ([URL.scheme isEqualToString:@"tel"]) { // 电话
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:LLLLLL(@"PhoneNumberHint"), resultStr] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *callAction = [UIAlertAction actionWithTitle:LLLLLL(@"Calls") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [UIApplication.sharedApplication openURL:URL(UNString(@"telprompt:%@", resultStr)) options:@{} completionHandler:nil];
        }];
        UIAlertAction *copyAction = [UIAlertAction actionWithTitle:LLLLLL(@"CopyNumber") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = resultStr;
            [SVProgressHUD showSuccessWithStatus:LLLLLL(@"CopySuccessfully")];
            [SVProgressHUD dismissWithDelay:1.0];
        }];
        
        [alertController addAction:cancelAction];
        [alertController addAction:callAction];
        [alertController addAction:copyAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    return NO;
}
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    return NO;
}


//获取自己的权限
- (WFCCGroupMember *)getMyself {
    NSArray<WFCCGroupMember *> *groupMembers = [[WFCCIMService sharedWFCIMService] getGroupMembers:(_announcement != nil ? _announcement.groupId : _groupId) forceUpdate:NO];
    for (WFCCGroupMember *obj in groupMembers) {
        if ([obj.memberId isEqualToString:[WFCCNetworkService sharedInstance].userId]) {
            WFCCGroupMember *mem = [WFCCGroupMember mj_objectWithKeyValues:obj.extra];
            obj.controlOther = mem.controlOther;
            obj.modifyGroupInfo = mem.modifyGroupInfo;
            obj.pushNotice = mem.pushNotice;
            obj.renewRequest = mem.renewRequest;
            return obj;
        }
    }
    return nil;
}

@end



@interface LaEditAnnouncementVC ()<UITextViewDelegate>
{
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIView *textBgView;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;

@property (weak, nonatomic) IBOutlet UIButton *postButton;

@property (weak, nonatomic) IBOutlet UIView *notiBgView;
@property (weak, nonatomic) IBOutlet UISwitch *notiSW;


@property (weak, nonatomic) IBOutlet UILabel *notiAllMemberL;
@property (weak, nonatomic) IBOutlet UILabel *notiAllMemberDescL;

@end

@implementation LaEditAnnouncementVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    self.navigationItem.title = (_isChinese?@"发布新公告":@"Chỉnh sửa thông báo mới");
    
    _textBgView.layer.cornerRadius = 20.0;
    [_textBgView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
    _postButton.layer.cornerRadius = 20.0;
    
    _textView.delegate = self;
    
    UILabel *placeHolderLabel = [[UILabel alloc] init];
    placeHolderLabel.text = (_isChinese?@"请输入公告内容...":@"Nhập nội dung thông báo ....");
    placeHolderLabel.numberOfLines = 0;
    placeHolderLabel.textColor = UIColor.lightGrayColor;
    [placeHolderLabel sizeToFit];
    placeHolderLabel.font = PINGFANG_R(14.0);
    [_textView addSubview:placeHolderLabel];
    [_textView setValue:placeHolderLabel forKey:@"_placeholderLabel"];
    
    if (_announcementText.length) {
        if (_announcementText.length >= 1000) {
            _announcementText = [_announcementText substringToIndex:1000];
        }
        _numLabel.text = UNString(@"%ld", _announcementText.length);
        _textView.text = _announcementText;
    }
    if (_isChinese) {
        
    }else {
        _notiAllMemberL.text = @"Thông báo đến toàn bộ thành viên";
        _notiAllMemberDescL.text = @"Thông báo tới tất cả thành viên nhóm, ngay cả khi đối phương đã bật Không làm phiền";
        [_postButton setTitle:@"Xác nhận phát" forState:UIControlStateNormal];
    }
}

- (IBAction)post:(UIButton *)sender {
    [self.view endEditing:YES];
    if (_textView.text.length <= 0) {
        [SVProgressHUD showErrorWithStatus:(_isChinese?@"请输入公告内容...":@"Nhập nội dung thông báo...")];
        [SVProgressHUD dismissWithDelay:1.0];
        return;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"Loading");
    [hud showAnimated:YES];
    WS(weakself)
    [[QWERConfigManager globalManager].appServiceProvider updateGroup:_groupId
                                                         announcement:self.textView.text
                                                               isNoti:(_notiSW.isOn ? 1 : 0)
                                                              success:^(long timestamp) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LLLLLL(@"SaveSuccessfully");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            
            TREWQGroupAnnouncement *announcement = TREWQGroupAnnouncement.new;
            announcement.groupId = weakself.groupId;
            announcement.author = WFCCNetworkService.sharedInstance.userId;
            announcement.text = weakself.textView.text;
            announcement.timestamp = timestamp;
            if (weakself.editAnnouncementBlock) {
                weakself.editAnnouncementBlock(announcement);
            }
            [NSNotificationCenter.defaultCenter postNotificationName:kGroup_Announcement_Update object:announcement];
            [self.navigationController popViewControllerAnimated:YES];
        });
    } error:^(int error_code) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = LLLLLL(@"SaveFailure");
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
        });
    }];
}



- (IBAction)noti:(UISwitch *)sender {
    [self.view endEditing:YES];
}


- (void)clearText {
    _textView.text = @"";
}

- (void)textViewDidChange:(UITextView *)textView {
    if (textView.text.length >= 1000) {
        textView.text = [textView.text substringToIndex:1000];
    }
    _numLabel.text = UNString(@"%ld", textView.text.length);
}
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
//    if ([text isEqualToString:@"\n"]) {
//        [self.view endEditing:YES];
//        return NO;
//    }
    NSInteger length = textView.text.length - range.length + text.length;
    if (length <= 1000) {
        return YES;
    }
    return NO;
}


- (void)close {
    [self.view endEditing:YES];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
}
@end
