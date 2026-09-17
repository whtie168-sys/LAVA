//
//  RWADCBlackListVC.m
//  WFChatUIKit
//
//  Created by Heavyrain.Lee on 2019/7/31.
//  Copyright © 2019 Wildfire Chat. All rights reserved.
//

#import "RWADCBlackListVC.h"
#import <LavaWFChatClient/WFCChatClient.h>
#import <SDWebImage/SDWebImage.h>
#import "QWERImage.h"

@interface RWADCBlackListVC () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong)  UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataArr;
@end

@implementation RWADCBlackListVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = WFCString(@"Blacklist");
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    if (@available(iOS 15, *)) {
        self.tableView.sectionHeaderTopPadding = 0;
    }
    self.dataArr = [[[WFCCIMService sharedWFCIMService] getBlackList:YES] mutableCopy];
    [self.tableView reloadData];
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [_tableView registerClass:WFCUBlackListTableViewCell.class forCellReuseIdentifier:@"WFCUBlackListTableViewCell"];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60.0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSString *userId = [self.dataArr objectAtIndex:indexPath.row];
        __weak typeof(self) ws = self;
        [[WFCCIMService sharedWFCIMService] setBlackList:userId isBlackListed:NO success:^{
            [ws.dataArr removeObject:userId];
            [ws.tableView reloadData];
        } error:^(int error_code) {
            
        }];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Xóa";
}
#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCUBlackListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WFCUBlackListTableViewCell" forIndexPath:indexPath];
    
    WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:[self.dataArr objectAtIndex:indexPath.row] refresh:NO];
    
    [cell.iconView sd_setImageWithURL:[NSURL URLWithString:[userInfo.portrait stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                              context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    cell.asoucNameLabel.text = (userInfo.friendAlias.length > 0 ? userInfo.friendAlias : userInfo.displayName);
    return cell;
}

@end


@interface WFCUBlackListTableViewCell ()



@end

@implementation WFCUBlackListTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];

}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        [self.contentView addSubview:self.iconView];
        [self.contentView addSubview:self.asoucNameLabel];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(70.0, 59.5, UIScreen.mainScreen.bounds.size.width-70.0, 0.5)];
        lineView.backgroundColor = RGBCOLOR(224, 224, 224);
        [self.contentView addSubview:lineView];
    }
    return self;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] initWithFrame:CGRectMake(20.0,10.0, 40.0, 40.0)];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.layer.cornerRadius = 20.0;
        _iconView.layer.masksToBounds = YES;
    }return _iconView;
}

- (UILabel *)asoucNameLabel {
    if (!_asoucNameLabel) {
        _asoucNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(70.0, 15.0, UIScreen.mainScreen.bounds.size.width - 80.0, 30.0)];
        _asoucNameLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:15.0];
        _asoucNameLabel.textAlignment = NSTextAlignmentLeft;
        _asoucNameLabel.textColor = UIColor.blackColor;
    }return _asoucNameLabel;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView sd_cancelCurrentImageLoad];
    self.iconView.image = nil;
}
@end
