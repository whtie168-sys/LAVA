//
//  LaAppearanceVC.m
//  WildFireChat
//
//  Created by Rubyuer on 8/15/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaAppearanceVC.h"
#import "LaChatBackgroundSetVC.h"

@interface LaAppearanceVC ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    float _ceoxsoAlpha;
    NSInteger _ceoxsoBgColorIndex;
    
    BOOL _isChinese;
}
@property (weak, nonatomic) IBOutlet UISwitch *ceoxsoStatusSw;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoStatusL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoStatusDescL;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoBgV;

@property (weak, nonatomic) IBOutlet UIView *ceoxsoChatBgV;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoBgImgV;
@property (weak, nonatomic) IBOutlet UIImageView *ceoxsoBubbleColorImgV;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoTextAL;
@property (weak, nonatomic) IBOutlet UILabel *ceoxsoTextBL;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoBubbleColorFL;

@property (nonatomic, assign) NSInteger ceoxsoBubbleColorIndex; // kAppearanceBubbleColor 气泡颜色的索引
@property (weak, nonatomic) IBOutlet UICollectionView *ceoxsoCV;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *ceoxsoLayout;

@property (weak, nonatomic) IBOutlet UILabel *ceoxsoChatBgFL;
@property (nonatomic, assign) NSInteger ceoxsoChatBgImgIndex; // kAppearanceChatBackgroundImg 聊天背景图片索引
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoChatBgABtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoChatBgBBtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoChatBgCBtn;
@property (weak, nonatomic) IBOutlet UIButton *ceoxsoChatBgDBtn;

@end

@implementation LaAppearanceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"Appearance");
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self itemImage:@"ceoxsoBack" action:@selector(ceoxsoBack)]];
    _isChinese = [CommonHelper.main isChinese];
    
    _ceoxsoBgColorIndex = -1;
    
    _ceoxsoChatBgV.layer.cornerRadius = 15.0;
    _ceoxsoChatBgV.layer.borderWidth = 0.67;
    _ceoxsoChatBgV.layer.borderColor = RGBA(0xF6F6F6).CGColor;
    
    _ceoxsoStatusSw.on = ![NSUserDefaults.standardUserDefaults boolForKey:kAppearanceStatus];
    _ceoxsoBgV.hidden = _ceoxsoStatusSw.on;
    if (!_ceoxsoStatusSw.on) {
        [self ceoxsoSaveItem];
    }
    
    self.ceoxsoChatBgImgIndex = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceChatBackgroundImg];
    
    self.ceoxsoBubbleColorIndex = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceBubbleColor];
    _ceoxsoLayout.sectionInset = UIEdgeInsetsMake(0.0, 20.0, 0.0, 20.0);
    _ceoxsoLayout.itemSize = CGSizeMake(40.0, 40.0);
    _ceoxsoLayout.minimumInteritemSpacing = ( WIDTH-40.0-40*7.0-0.1)/6.0;
    _ceoxsoLayout.minimumLineSpacing = 0.0;
    _ceoxsoCV.delegate = self;
    _ceoxsoCV.dataSource = self;
    [_ceoxsoCV registerNib:[UINib nibWithNibName:@"LaBubbleColorCVCell" bundle:nil] forCellWithReuseIdentifier:@"LaBubbleColorCVCell"];
    
    _ceoxsoAlpha = [NSUserDefaults.standardUserDefaults floatForKey:kAppearanceChatBackgroundImgAlpha];
    _ceoxsoBgColorIndex = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceChatBackgroundColor];
    _ceoxsoBgImgV.backgroundColor = [ChatBgImgColors[_ceoxsoBgColorIndex] alpha:_ceoxsoAlpha];
    
    if (_isChinese) {
    }else {
        _ceoxsoStatusL.text = @"Chế độ tinh khiết";
        _ceoxsoStatusDescL.text = @"Mở không hiển thị hiệu ứng";
        _ceoxsoTextAL.text = @"Phong cách chat";
        _ceoxsoTextBL.text = @"Trò chuyện phong cách";
        _ceoxsoBubbleColorFL.text = @"Đối thoại màu bong bóng";
        _ceoxsoChatBgFL.text = @"Trò chuyện nền tảng";
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self ceoxsoBack];
}

- (void)ceoxsoBack {
    if ([self ceoxsoDataIsUpdate] == NO) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese?@"温馨提示":@"Nhắc nhở") message:(_isChinese?@"您已修改设置，是否保存后返回？":@"Bạn có chắc muốn lưu lại thay đổi?") preferredStyle:UIAlertControllerStyleAlert];
    WS(weakself)
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:(_isChinese?@"暂不":@"Không") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [weakself.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:(_isChinese?@"保存并返回":@"Lưu") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself ceoxsoSaved];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (BOOL)ceoxsoDataIsUpdate {
    NSInteger ceoxsoBubbleColor = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceBubbleColor];
    NSInteger ceoxsoChatBgImg = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceChatBackgroundImg];
    float ceoxsoAlpha = [NSUserDefaults.standardUserDefaults floatForKey:kAppearanceChatBackgroundImgAlpha];
    NSInteger ceoxsoBgColor = [NSUserDefaults.standardUserDefaults integerForKey:kAppearanceChatBackgroundColor];
    if (ceoxsoBubbleColor == self.ceoxsoBubbleColorIndex && ceoxsoChatBgImg == self.ceoxsoChatBgImgIndex && ceoxsoAlpha == _ceoxsoAlpha && ceoxsoBgColor == _ceoxsoBgColorIndex) {
        return NO;
    }
    return YES;
}

- (void)ceoxsoSave {
    if ([self ceoxsoDataIsUpdate] == NO) {
        [self.view makeToast:(_isChinese?@"您没有修改设置，不需要保存...":@"Bạn không thay đổi thiết lập, không cần phải lưu...") duration:1.0 position:CSToastPositionCenter];
        return;
    }
    if (_ceoxsoBgColorIndex == -1) {
        [self.view makeToast:(_isChinese?@"请设置聊天背景参数":@"Hãy thiết lập thông số nền trò chuyện") duration:1.0 position:CSToastPositionCenter];
        return;
    }
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese?@"您确定要保存吗？":@"Bạn có chắc bạn muốn lưu nó?") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakself ceoxsoSaved];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)ceoxsoSaved {
    [NSUserDefaults.standardUserDefaults setInteger:self.ceoxsoBubbleColorIndex forKey:kAppearanceBubbleColor];
    [NSUserDefaults.standardUserDefaults setInteger:self.ceoxsoChatBgImgIndex forKey:kAppearanceChatBackgroundImg];
    [NSUserDefaults.standardUserDefaults setFloat:_ceoxsoAlpha forKey:kAppearanceChatBackgroundImgAlpha];
    [NSUserDefaults.standardUserDefaults setInteger:_ceoxsoBgColorIndex forKey:kAppearanceChatBackgroundColor];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    [self.view makeToast:LLLLLL(@"SaveSuccessfully") duration:1.0 position:CSToastPositionCenter];
    WS(weakself)
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakself.navigationController popViewControllerAnimated:YES];
    });
}



- (IBAction)ceoxsoStatus:(UISwitch *)sender { // 纯净模式开关
    _ceoxsoBgV.hidden = sender.on;
    if (!sender.on) {
        [self ceoxsoSaveItem];
    }else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    [NSUserDefaults.standardUserDefaults setBool:!sender.on forKey:kAppearanceStatus];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (void)ceoxsoSaveItem {
    UIButton *ceoxsoSaveBtn = [self itemTitle:LLLLLL(@"Save") action:@selector(ceoxsoSave)];
    [ceoxsoSaveBtn setTitleColor:MAINCOLOR forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:ceoxsoSaveBtn];
}

- (IBAction)ceoxsoChatBgMore:(UIButton *)sender { // 设置聊天背景
    if (_ceoxsoChatBgImgIndex <= 0) {
        [self.view makeToast:(_isChinese?@"请先选择背景图片":@"Hãy chọn ảnh nền trước") duration:1.0 position:CSToastPositionCenter];
        return;
    }
    LaChatBackgroundSetVC *vc = LaChatBackgroundSetVC.new;
    vc.ceoxsoBubbleColorIndex = _ceoxsoBubbleColorIndex;
    vc.ceoxsoChatBgImgIndex = _ceoxsoChatBgImgIndex;
    vc.ceoxsoAlpha = _ceoxsoAlpha;
    vc.ceoxsoBgColorIndex = _ceoxsoBgColorIndex;
    WS(weakself)
    [vc setChatBackgroundSet:^(float ceoxsoAlpha, NSInteger ceoxsoBgColorIndex) {
        self->_ceoxsoAlpha = ceoxsoAlpha;
        self->_ceoxsoBgColorIndex = ceoxsoBgColorIndex;
        weakself.ceoxsoBgImgV.backgroundColor = [ChatBgImgColors[ceoxsoBgColorIndex] alpha:ceoxsoAlpha];
    }];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - 聊天背景图片

- (void)setCeoxsoChatBgImgIndex:(NSInteger)ceoxsoChatBgImgIndex {
    _ceoxsoChatBgImgIndex = ceoxsoChatBgImgIndex;
    for (UIButton *ceoxsoChatBgBtn in @[_ceoxsoChatBgABtn, _ceoxsoChatBgBBtn, _ceoxsoChatBgCBtn, _ceoxsoChatBgDBtn]) {
        ceoxsoChatBgBtn.selected = (_ceoxsoChatBgImgIndex == ceoxsoChatBgBtn.tag);
    }
    if (_ceoxsoChatBgImgIndex <= 0) {
        return;
    }
    _ceoxsoBgImgV.image = IMAGENAME((UNString(@"erovaeChatBgImg%ld", _ceoxsoChatBgImgIndex)));
}

- (IBAction)ceoxsoChatBg:(UIButton *)sender { // 聊天背景图片->切换
    if (_ceoxsoChatBgImgIndex == sender.tag) {
        return;
    }
    self.ceoxsoChatBgImgIndex = sender.tag;
//    [NSUserDefaults.standardUserDefaults setInteger:self.ceoxsoChatBgImgIndex forKey:kAppearanceChatBackgroundImg];
//    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark - UICollectionViewDelegate, UICollectionViewDataSource

- (void)setCeoxsoBubbleColorIndex:(NSInteger)ceoxsoBubbleColorIndex {
    _ceoxsoBubbleColorIndex = ceoxsoBubbleColorIndex;
    [_ceoxsoCV reloadData];
    if (_ceoxsoBubbleColorIndex < 0) {
        return;
    }
    _ceoxsoBubbleColorImgV.image = IMAGENAME((UNString(@"sent_msg_background%ld", _ceoxsoBubbleColorIndex)));
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return BubbleColors.count;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    LaBubbleColorCVCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"LaBubbleColorCVCell" forIndexPath:indexPath];
    cell.erovaeBgV.backgroundColor = BubbleColors[indexPath.row];
    cell.erovaeSelectV.hidden = (indexPath.row != (_ceoxsoBubbleColorIndex - 1));
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_ceoxsoBubbleColorIndex == indexPath.row + 1) {
        return;
    }
    self.ceoxsoBubbleColorIndex = indexPath.row + 1;
//    [NSUserDefaults.standardUserDefaults setInteger:self.ceoxsoBubbleColorIndex forKey:kAppearanceBubbleColor];
//    [NSUserDefaults.standardUserDefaults synchronize];
}

@end




@interface LaBubbleColorCVCell ()

@end

@implementation LaBubbleColorCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _erovaeSelectV.hidden = YES;
    _erovaeBgV.layer.cornerRadius = 15.0;
}

@end
