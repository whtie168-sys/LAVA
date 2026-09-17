//
//  LaNewFriendVC.m
//  WildFireChat
//
//  Created by Rubyuer on 11/2/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaNewFriendVC.h"
#import "LaContactsHeaderView.h"
#import "LaNewsFriendTVCell.h"

#import "LaNewsFriendInfoVC.h"


@interface LaNewFriendVC ()<UITableViewDataSource, UITableViewDelegate>
{
    BOOL _isChinese;
}
@property (nonatomic, strong)  UITableView              *tableView;
@property (nonatomic, strong) NSMutableArray<NSArray<WFCCFriendRequest *> *>            *dataList;
@property (nonatomic, strong) NSMutableArray *sectionTitles;

@property (weak, nonatomic) IBOutlet UIView *nullView;
@property (weak, nonatomic) IBOutlet UILabel *noDataL;
@property (weak, nonatomic) IBOutlet UILabel *nullL;

@end

@implementation LaNewFriendVC


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[WFCCIMService sharedWFCIMService] clearUnreadFriendRequestStatus];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _isChinese = [CommonHelper.main isChinese];
    
    self.navigationItem.title = LLLLLL(@"NewFriend");
    self.view.backgroundColor = UIColor.whiteColor;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:LLLLLL(@"Clear") style:UIBarButtonItemStyleDone target:self action:@selector(onClearBarBtn:)];
    
    _nullL.text = (_isChinese?@"暂无数据":@"Không có dữ liệu");
    
    _nullView.hidden = YES;
    _dataList = NSMutableArray.new;
    _sectionTitles = NSMutableArray.new;
    
    //初始化数据源
    [[WFCCIMService sharedWFCIMService] loadFriendRequestFromRemote];
    [self getRequestData];
    
    //设置代理
    _tableView.delegate   = self;
    _tableView.dataSource = self;
    _tableView.allowsSelection = YES;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone; 
    [_tableView registerNib:[UINib nibWithNibName:@"LaNewsFriendTVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"LaNewsFriendTVCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"LaContactsHeaderView" bundle:NSBundle.mainBundle] forHeaderFooterViewReuseIdentifier:@"LaContactsHeaderView"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserInfoUpdated:) name:kUserInfoUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onFriendRequestUpdated:) name:kFriendRequestUpdated object:nil];
    
    [[WFCCIMService sharedWFCIMService] clearUnreadFriendRequestStatus];
}
//0 未处理。1 已同意。2 已拒绝
//@[@"待处理", @"已过期", @"已处理"]
- (void)getRequestData {
    [_dataList removeAllObjects];
    [_sectionTitles removeAllObjects];
    
    NSMutableArray *aaa = NSMutableArray.new;
    NSMutableArray *bbb = NSMutableArray.new;
    NSMutableArray *ccc = NSMutableArray.new;
    for (WFCCFriendRequest *request in [[WFCCIMService sharedWFCIMService] getIncommingFriendRequest])
        if (request.status == 0) {
            BOOL expired = NO;
            if (NSDate.date.timeIntervalSince1970*1000 - request.timestamp > 7 * 24 * 60 * 60 * 1000) {
                expired = YES;
            }
            if (expired) {
                [bbb addObject:request];
            }else {
                [aaa addObject:request];
            }
        }else if (request.status == 1) {
            [ccc addObject:request];
        }else if (request.status == 2) {
            [ccc addObject:request];
        }
    if (aaa.count) {
        [_dataList addObject:aaa];
        [_sectionTitles addObject:(_isChinese?@"待处理":@"Đợi xử lý")];
    }
    if (bbb.count) {
        [_dataList addObject:bbb];
        [_sectionTitles addObject:LLLLLL(@"Expired")];
    }
    if (ccc.count) {
        [_dataList addObject:ccc];
        [_sectionTitles addObject:(_isChinese?@"已处理":@"Đã được xử lý")];
    }
    _nullView.hidden = _dataList.count;
    [_tableView reloadData];
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataList.count;
}
//table 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_dataList.count <= 0) {
        return 0;
    }
    return _dataList[section].count;
}
//返回单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaNewsFriendTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaNewsFriendTVCell" forIndexPath:indexPath];
    cell.friendRequest = self.dataList[indexPath.section][indexPath.row];
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCFriendRequest *request = self.dataList[indexPath.section][indexPath.row];
    if (request.status == 0) {
        BOOL expired = NO;
        if (NSDate.date.timeIntervalSince1970*1000 - request.timestamp > 7 * 24 * 60 * 60 * 1000) {
            expired = YES;
        }
        if (!expired) {
            LaNewsFriendInfoVC *vc = LaNewsFriendInfoVC.new;
            vc.request = self.dataList[indexPath.section][indexPath.row];
            WS(weakself)
            [vc setSuccessBlock:^{
                [weakself getRequestData];
            }];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WFCCFriendRequest *request = self.dataList[indexPath.section][indexPath.row];
        [[WFCCIMService sharedWFCIMService] deleteFriendRequest:request.target direction:request.direction];
        
        [self getRequestData];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 72.0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (self.dataList.count == 0) {
        return 0.01;
    }
    return 32.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
// view上设置背景色无效。 请使用方法 willDisplayHeaderView
    LaContactsHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LaContactsHeaderView"];
    view.oxaicsgoeTitleLabel.textColor = RGBA(0x919191);
    view.oxaicsgoeTitleLabel.font = PINGFANG_M(14.0);
    view.oxaicsgoeTitleLabel.text = _sectionTitles[section];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = UIColor.whiteColor;
}





- (void)onUserInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCUserInfo *> *userInfoList = notification.userInfo[@"userInfoList"];
    for (NSInteger i = 0; i < _dataList.count; i ++) {
        NSArray *datas = _dataList[i];
        for (NSInteger j = 0; j < datas.count; j ++) {
            WFCCFriendRequest *request = datas[j];
            
            for (WFCCUserInfo *userInfo in userInfoList) {
                if([userInfo.userId isEqualToString:request.target]) {
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:j inSection:i]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
        }
    }
}

- (void)onFriendRequestUpdated:(NSNotification *)notification {
    [self getRequestData];
}

- (void)onAddBarBtn:(UIBarButtonItem *)sender {
    UIViewController *addFriendVC = [[ATERWAddFriendVC alloc] init];
    addFriendVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addFriendVC animated:YES];
}

- (void)onClearBarBtn:(UIBarButtonItem *)sender {
    if (_dataList.count <= 0) {
        return;
    }
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese?@"您确定要清除数据吗？":@"Anh chắc là anh muốn xóa dữ liệu chứ?") message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[WFCCIMService sharedWFCIMService] clearFriendRequest:1 beforeTime:0];
        
        [weakself getRequestData];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _tableView        = nil;
    _dataList         = nil;
}

@end
