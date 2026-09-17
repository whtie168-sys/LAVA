//
//  LaDeviceVC.m
//  WildFireChat
//
//  Created by Ruby on 2/1/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaDeviceVC.h"

#import "LaDeviceDetailsVC.h"

@interface LaDeviceVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *descL;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<DeviceHistory *>    *dataList;

@end

@implementation LaDeviceVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"Equipment");
    if ([CommonHelper.main isChinese]) {
    }else {
        _descL.text = @"Trang này hiển thị tất cả các thiết bị bạn đã đăng nhập. Vui lòng chú ý các thiết bị lạ có bị người khác đăng nhập qua. Coi chừng bị đánh cắp!";
    }
    [self requestData];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 130.0;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_tableView registerNib:[UINib nibWithNibName:@"LaDeviceTVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"LaDeviceTVCell"];
}

- (void)requestData {
    [self.dataList removeAllObjects];
    __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = LLLLLL(@"OperationInProgress");
    [hud showAnimated:YES];
    WS(weakself)
    [AppService.sharedAppService requestUrl:@"/device_history" params:@{} success:^(NSDictionary * _Nonnull dict) {
        [hud hideAnimated:YES];
        NSArray *datas = dict[@"result"];
        
        weakself.dataList = [[DeviceHistory mj_objectArrayWithKeyValuesArray:datas] sortedArrayUsingComparator:^NSComparisonResult(DeviceHistory  * obj1, DeviceHistory  * obj2) {
            return obj1.lastLogin <= obj2.lastLogin;
        }].mutableCopy;
        [weakself.tableView reloadData];
    } error:^(int errCode, NSString * _Nonnull message) {
        [hud hideAnimated:YES];
        [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataList.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaDeviceTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaDeviceTVCell" forIndexPath:indexPath];
    cell.model = _dataList[indexPath.section];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LaDeviceDetailsVC *vc = LaDeviceDetailsVC.new;
    vc.model = _dataList[indexPath.section];
    [self.navigationController pushViewController:vc animated:YES];
}




- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WS(weakself)
        // QWERConfigManager.globalManager.appServiceProvider
        [AppService.sharedAppService requestUrl:@"/delete_device_history" params:@{@"deviceId":_dataList[indexPath.section].id} success:^(NSDictionary * _Nonnull dict) {
        } error:^(int errCode, NSString * _Nonnull message) {
        }];
        [weakself.dataList removeObjectAtIndex:indexPath.section];
        [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 10.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, WIDTH, 10.0)];
    view.backgroundColor = UIColor.groupTableViewBackgroundColor;
    return view;
}


- (NSMutableArray<DeviceHistory *> *)dataList {
    if (!_dataList) {
        _dataList = NSMutableArray.new;
    }return _dataList;
}

@end









@interface LaDeviceTVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *deviceImgView;
@property (weak, nonatomic) IBOutlet UILabel *deviceasoucNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *isCurrentDeviceLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastLoginTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;

@property (weak, nonatomic) IBOutlet UILabel *lastLoginTimeL;
@property (weak, nonatomic) IBOutlet UILabel *ipL;
@end

@implementation LaDeviceTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _isCurrentDeviceLabel.text = LLLLLL(@"CurrentDevice");
    _lastLoginTimeL.text = LLLLLL(@"LastOnlineTime");
    _ipL.text = LLLLLL(@"IPAddress");
}

- (void)setModel:(DeviceHistory *)model {
    _model = model;
    
    _deviceasoucNameLabel.text = _model.type;
    _isCurrentDeviceLabel.hidden = ![_model.type isEqualToString:UIDevice.currentDevice.name];
 
    _lastLoginTimeLabel.text = [UNString(@"%lld", _model.lastLogin) timeIntervalDateFormat:@"dd-MM-yyyy HH:mm:ss"];
    _ipLabel.text = _model.ip;
    
    if ([_model.type.lowercaseString containsString:@"Mac".lowercaseString]) {
        _deviceImgView.image = IMAGENAME(@"device1");
    }else if ([_model.type.lowercaseString containsString:@"iPad".lowercaseString]) {
        _deviceImgView.image = IMAGENAME(@"device2");
    }else {
        _deviceImgView.image = IMAGENAME(@"device0");
    }
}


@end
