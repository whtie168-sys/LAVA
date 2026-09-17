//
//  LaCallosDetailsVC.m
//  WildFireChat
//
//  Created by Ruby on 11/6/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaCallosDetailsVC.h"
#import "LaContactsHeaderView.h"
#if WFCU_SUPPORT_VOIP
#import <Chat86AVEngineKit/Chat86AVEngineKit.h>
#endif

#import "LaMessageVC.h"


@interface LaCallosDetailsVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *asoucNameLabel;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray<NSArray<AddAudioModel *> *>            *dataList;
@property (nonatomic, strong) NSMutableArray<NSString *>            *dateDatas;

@property (nonatomic, strong) WFCCUserInfo *targetUserInfo;
@property (nonatomic, strong) WFCCConversation *conversation;

@end

@implementation LaCallosDetailsVC


- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"Details");
    
    _iconView.layer.cornerRadius = 25.0;
    
    if (_dataSource.count) {
        AddAudioModel *target = _dataSource.firstObject;
        
        _targetUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:target.jsonObject.targetId refresh:NO];
        _conversation = [WFCCConversation conversationWithType:Single_Type target:_targetUserInfo.userId line:0];
        
        [_iconView sd_setImageWithURL:URL(_targetUserInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"]];
        _asoucNameLabel.text = _targetUserInfo.friendAlias.length > 0 ? _targetUserInfo.friendAlias : _targetUserInfo.displayName;
    }else {
        [self.navigationController popViewControllerAnimated:YES];
    }
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 50.0;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.backgroundColor = UIColor.groupTableViewBackgroundColor;
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, WIDTH, 0.01)];
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, WIDTH, 0.01)];
    [_tableView registerNib:[UINib nibWithNibName:@"LaCallosRecordCVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"LaCallosRecordCVCell"];
    [_tableView registerNib:[UINib nibWithNibName:@"LaContactsHeaderView" bundle:NSBundle.mainBundle] forHeaderFooterViewReuseIdentifier:@"LaContactsHeaderView"];
}

- (void)setDataSource:(NSMutableArray<AddAudioModel *> *)dataSource {
    _dataSource = dataSource;
    [self dealWithData];
}

- (void)dealWithData {
    [self filterObjectArray];
    [_tableView reloadData];
}


- (IBAction)userAct:(UIButton *)sender {
    if (sender.tag == 0) {
        LaMessageVC *mvc = LaMessageVC.new;
        mvc.conversation = _conversation;
        [self.navigationController pushViewController:mvc animated:YES];
    }else if (sender.tag == 1) {
#if WFCU_SUPPORT_VOIP
        RADCOVideoVC *videoVC = [[RADCOVideoVC alloc] initWithTargets:@[_targetUserInfo.userId] conversation:_conversation audioOnly:NO];
        [[Chat86AVEngineKit sharedEngineKit] presentViewController:videoVC];
#endif
    }else {
#if WFCU_SUPPORT_VOIP
        RADCOVideoVC *videoVC = [[RADCOVideoVC alloc] initWithTargets:@[_targetUserInfo.userId] conversation:_conversation audioOnly:YES];
        [[Chat86AVEngineKit sharedEngineKit] presentViewController:videoVC];
#endif
    }
}



#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataList.count;
}
//table 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataList.count <= 0) {
        return 0;
    }
    return self.dataList[section].count;
}
//返回单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaCallosRecordCVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaCallosRecordCVCell" forIndexPath:indexPath];
    cell.audioModel = _dataList[indexPath.section][indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LLLLLL(@"Delete");
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        WS(weakself)
        AddAudioModel *model = _dataList[indexPath.section][indexPath.row];
        [QWERConfigManager.globalManager.appServiceProvider deleteAudioHistory:@{@"ids":@[model.id]} success:^(NSDictionary * _Nonnull dict) {
            [weakself.dataSource removeObject:model];
            [weakself dealWithData];
            if (weakself.callosDeleteSuccessBlock) {
                weakself.callosDeleteSuccessBlock();
            }
        } error:^(int errCode, NSString * _Nonnull message) {
            
        }];
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
//    return 0.01;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
//    return nil;
//}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    //    if (self.dataList.count == 0) {
    //        return 0.01;
    //    }
    return 25.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // view上设置背景色无效。 请使用方法 willDisplayHeaderView
    LaContactsHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LaContactsHeaderView"];
    view.oxaicsgoeTitleLabel.textColor = RGBA(0x777777);
    view.oxaicsgoeTitleLabel.font = PINGFANG_M(11.0);
    view.oxaicsgoeTitleLabel.text = self.dateDatas[section];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = RGBA(0xF6F6F6);
}


- (NSMutableArray<NSArray<AddAudioModel *> *> *)dataList {
    if (!_dataList) {
        _dataList = NSMutableArray.new;
    }return _dataList;
}
- (NSMutableArray<NSString *> *)dateDatas {
    if (!_dateDatas) {
        _dateDatas = NSMutableArray.new;
    }return _dateDatas;
}


- (void)filterObjectArray {
    [self.dataList removeAllObjects];
    [self.dateDatas removeAllObjects];
    
    for (AddAudioModel *target in self.dataSource) {
        BOOL isHaved = NO; // date 中是否存在
        NSString *createdTime = [UNString(@"%lld", target.createdTime) timeIntervalDateFormat:@"yyyy-MM-dd"];
        for (NSString *targetDate in self.dateDatas) {
            if ([createdTime isEqualToString:targetDate]) {
                isHaved = YES;
                break;
            }
        }
        if (isHaved == NO) {
            [self.dateDatas addObject:createdTime];
        }
    }
    
    for (NSString *targetDate in self.dateDatas) {
        NSMutableArray *results = NSMutableArray.new;
        for (AddAudioModel *target in self.dataSource) {
            NSString *createdTime = [UNString(@"%lld", target.createdTime) timeIntervalDateFormat:@"yyyy-MM-dd"];
            if ([createdTime isEqualToString:targetDate]) {
                [results addObject:target];
            }
        }
        [self.dataList addObject:results];
    }
}




@end

@interface LaCallosRecordCVCell ()

@property (weak, nonatomic) IBOutlet UIImageView *typeView;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *arrowView;

@end

@implementation LaCallosRecordCVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setAudioModel:(AddAudioModel *)audioModel {
    _audioModel = audioModel;

    if (audioModel.jsonObject.callType == 0) { // 语音
        NSString *image = (audioModel.jsonObject.status == 0 ? @"cseoaixgoVoiceN" : @"cseoaixgoVoiceS");
        _typeView.image = [UIImage imageNamed:image];
    }else { // 视频  status 状态 0 已取消(包括对方挂断)。1 未接听
        NSString *image = (audioModel.jsonObject.status == 0 ? @"cseoaixgoVideoN" : @"cseoaixgoVideoS");
        _typeView.image = [UIImage imageNamed:image];
    }
    
    
    if (audioModel.jsonObject.time > 0) { // 已接听状态
        long sec = audioModel.jsonObject.time;
        if (sec < 60 * 60) {
            _descLabel.text = [NSString stringWithFormat:@"%@ %02ld:%02ld",LLLLLL(@"CallDuration"), sec/60, sec%60];
        } else {
            _descLabel.text = [NSString stringWithFormat:@"%@ %02ld:%02ld:%02ld",LLLLLL(@"CallDuration"), sec/60/60, (sec/60)%60, sec%60];
        }
        _descLabel.textColor = RGBA(0x9D9D9D);
    }else {
        _descLabel.text = (audioModel.jsonObject.status == 0 ? LLLLLL(@"Cancelled") : LLLLLL(@"Unanswered"));
        _descLabel.textColor = (audioModel.jsonObject.status == 0 ? RGBA(0x9D9D9D) : RGBA(0xEB0022));
    }
    
    _dateLabel.text = [UNString(@"%lld", audioModel.createdTime) timeIntervalDateFormat:@"HH:mm"];
    
    NSString *arrowImg = @"";
    if (audioModel.jsonObject.call_out_in == 0) { // 0 呼出。 1 呼入
        arrowImg = (audioModel.jsonObject.status == 0 ? @"cseoaixgoTopGray" : @"cseoaixgoTopRed");
    }else {
        arrowImg = (audioModel.jsonObject.status == 0 ? @"cseoaixgoBottomGray" : @"cseoaixgoBottomRed");
    }
    _arrowView.image = [UIImage imageNamed:arrowImg];
}

@end
