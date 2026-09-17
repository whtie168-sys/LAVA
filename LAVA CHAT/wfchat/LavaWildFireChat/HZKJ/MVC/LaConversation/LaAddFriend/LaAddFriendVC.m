//
//  LaAddFriendVC.m
//  LAVA
//
//  Created by Rubyuer on 10/10/23.
//

#import "LaAddFriendVC.h"
#import <ContactsUI/ContactsUI.h>

#import "LaSearchFriendVC.h"


@interface LaAddFriendVC ()<CNContactPickerDelegate>
{
    NSInteger _contactIndex;
    
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UIButton *searchFBtn;
@property (weak, nonatomic) IBOutlet UIButton *phoneCBtn;
@property (weak, nonatomic) IBOutlet UIButton *qrCodeBtn;
@property (weak, nonatomic) IBOutlet UIButton *InviteBtn;

@end

@implementation LaAddFriendVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    if (_isChinese) {
        self.navigationItem.title = @"添加好友";
    }else {
        self.navigationItem.title = @"Thêm bạn bè";
        [_searchFBtn setTitle:@"Tìm kiếm bạn bè/Nhóm" forState:UIControlStateNormal];
        [_phoneCBtn setTitle:@"Số điện thoại người liên hệ" forState:UIControlStateNormal];
        [_qrCodeBtn setTitle:@"Quét mã QR" forState:UIControlStateNormal];
        [_InviteBtn setTitle:@"Mời bạn" forState:UIControlStateNormal];
    }
    
    _contactIndex = 0;
}

- (IBAction)oxgcseoaiAct:(UIButton *)sender {
    if (sender.tag == 0) { // 搜索朋友
        LaSearchFriendVC *vc = LaSearchFriendVC.new;
        [self.navigationController pushViewController:vc animated:YES];
    }else if (sender.tag == 1) { // 手机联系人
        _contactIndex = 0;
        CNContactPickerViewController *pickerVC = CNContactPickerViewController.new;
        pickerVC.delegate = self;
        [self presentViewController:pickerVC animated:YES completion:nil];
    }else if (sender.tag == 2) { // 扫描二维码
//        #if __is_target_environment(simulator) // 当前设备为模拟器
//                [SVProgressHUD showErrorWithStatus:@"该设备不支持打开相机扫描二维码"];
//                [SVProgressHUD dismissWithDelay:1.0];
//            return;
//        #else // 当前设备为真机
//                LaScanQrVC *vc = LaScanQrVC.new;
//                [self.navigationController pushViewController:vc animated:NO];
        if (gQrCodeDelegate) { // 走的delegate方法
            [gQrCodeDelegate scanQrCode:self.navigationController];
        }     
//        #endif
    }else if (sender.tag == 3) { // 邀请好友
        _contactIndex = 1;
        CNContactPickerViewController *pickerVC = CNContactPickerViewController.new;
//        pickerVC.displayedPropertyKeys = @[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey];
//        pickerVC.
        pickerVC.delegate = self;
        [self presentViewController:pickerVC animated:YES completion:nil];
    }
}

//- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContact:(CNContact *)contact {
//    for (CNLabeledValue *value in contact.phoneNumbers) {
//        CNPhoneNumber *number = (CNPhoneNumber *)value.value;
//        NSLog(@"number==A=%@",number.stringValue);
//    }
//}

- (void)contactPicker:(CNContactPickerViewController *)picker didSelectContactProperty:(CNContactProperty *)contactProperty {
// 注意：这里和displayedPropertyKeys属性设置相对应；只有 CNPhoneNumber 类型，如果添加别的类型，需要加类型判断，否则可能crash；例如：通讯录中的日期、邮箱...
    id value = contactProperty.value;
    if (![value isKindOfClass:CNPhoneNumber.class]) {
        [SVProgressHUD showErrorWithStatus:(_isChinese?@"请选择电话类型":@"Hãy chọn loại điện thoại")];
        return;
    }
    CNPhoneNumber *phoneNumber = (CNPhoneNumber *)value;

    NSString *phone = phoneNumber.stringValue;
    if ([phone containsString:@"+86"]) {
        phone = [phone componentsSeparatedByString:@"+86"].lastObject;
    }
    phone = [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    phone = [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    if (_contactIndex == 0) {
        LaSearchFriendVC *vc = LaSearchFriendVC.new;
        vc.phoneString = phone;
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        if (CommonHelper.main.iosPath.length > 0) {
            [self openUrl:phone];
        }else {
            WS(weakself)
            [CommonHelper.main updateAppSuccess:^(BOOL isUpdate) {
                if (isUpdate) {
                    return;
                }
                [weakself openUrl:phone];
            }];
        }
    }
}
- (void)openUrl:(NSString *)phone {
    NSString *sms = @"";
    if (_isChinese) {
        sms = [NSString stringWithFormat:@"sms:%@&body=嗨  我正在使用Chat聊天，加进来跟我一起聊天吧！点击链接下载APP: %@",phone, CommonHelper.main.iosPath];
    }else {
        sms = [NSString stringWithFormat:@"sms:%@&body=Tôi đang sử dụng ứng dụng chat LAVA, nhấp vào liên kết để tải ứng dụng về máy để cùng trò chuyện: %@",phone, CommonHelper.main.iosPath];
    }
    NSString* msg = [sms stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
   [[UIApplication sharedApplication] openURL:[NSURL URLWithString:msg] options:@{} completionHandler:^(BOOL success) {
   }];
}

@end
