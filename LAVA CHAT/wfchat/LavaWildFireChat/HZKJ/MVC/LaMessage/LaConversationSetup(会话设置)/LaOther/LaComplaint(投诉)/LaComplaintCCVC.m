//
//  LaComplaintCCVC.m
//  LAVA
//
//  Created by Rubyuer on 10/17/23.
//

#import "LaComplaintCCVC.h"

@interface LaComplaintCCVC ()

@property (weak, nonatomic) IBOutlet UIButton *oxaicsgoeOkButton;

@property (weak, nonatomic) IBOutlet UILabel *submitSuccessL;
@property (weak, nonatomic) IBOutlet UILabel *submitSuccessDescL;

@end

@implementation LaComplaintCCVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.hidesBackButton = YES;
    
    ViewRadius(_oxaicsgoeOkButton, 20.0);
    
    if ([CommonHelper.main isChinese]) {
        
    }else {
        _submitSuccessL.text = @"Gửi thành công";
        _submitSuccessDescL.text = @"Cảm ơn sự hỗ trợ của bạn, chúng tôi sẽ xử lý trong vòng 24 giờ";
        [_oxaicsgoeOkButton setTitle:LLLLLL(@"OK") forState:UIControlStateNormal];
    }
}

- (IBAction)oxaicsgoeOk:(UIButton *)sender {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
