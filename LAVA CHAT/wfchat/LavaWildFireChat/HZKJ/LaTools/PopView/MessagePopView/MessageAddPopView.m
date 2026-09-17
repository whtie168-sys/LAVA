//
//  MessageAddPopView.m
//  LAVA
//
//  Created by Rubyuer on 10/10/23.
//

#import "MessageAddPopView.h"

@interface MessageAddPopView ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *top;
@property (weak, nonatomic) IBOutlet UIView *bgView;

@property (weak, nonatomic) IBOutlet UILabel *addPopAL;
@property (weak, nonatomic) IBOutlet UIButton *addPopABtn;
@property (weak, nonatomic) IBOutlet UIButton *addPopBBtn;
@property (weak, nonatomic) IBOutlet UIButton *addPopCBtn;

@end

@implementation MessageAddPopView

- (instancetype)init {
    self = [super init];
    if (self) {
        self = [[[NSBundle mainBundle] loadNibNamed:@"MessageAddPopView" owner:self options:nil] lastObject];
        self.frame = ShareAppDelegate.window.frame;
        if ([CommonHelper.main isChinese]) {
            
        }else {
            _addPopAL.text = @"Thêm bạn bè/Nhóm";
//            [_addPopABtn setTitle:@"Thêm bạn bè/group" forState:UIControlStateNormal];
            [_addPopBBtn setTitle:@"Tạo nhóm" forState:UIControlStateNormal];
        }
        [_addPopCBtn setTitle:LLLLLL(@"Scanning") forState:UIControlStateNormal];
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close)]];
    }
    return self;
}

- (void)show {
    [ShareAppDelegate.window addSubview:self];
}

- (IBAction)act:(UIButton *)sender {
    if (_typeBlock) {
        _typeBlock(sender.tag);
    }
    [self removeFromSuperview];
}

- (void)close {
    [self removeFromSuperview];
}

@end
