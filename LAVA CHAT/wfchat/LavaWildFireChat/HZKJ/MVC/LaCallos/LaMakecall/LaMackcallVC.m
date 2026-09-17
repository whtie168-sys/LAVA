//
//  LaMackcallVC.m
//  WildFireChat
//
//  Created by Ruby on 12/1/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaMackcallVC.h"
#import "LaContactsHeaderView.h"



@interface LaMackcallVC ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *oxgcseoaiTableView;
@property (nonatomic, strong) NSMutableArray<NSArray<WFCCUserInfo *> *> *dataArray;
@property (nonatomic, strong) NSMutableArray<NSString *> *sectionTitles;

@end

@implementation LaMackcallVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"NewCall");
    
    NSArray *results = [[WFCCIMService.sharedWFCIMService getUserInfos:[WFCCIMService.sharedWFCIMService getMyFriendList:YES] inGroup:@""] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"userId != %@",_targetId]];
    self.dataArray = [self sortObjectsAccordingToInitialWith:results];
    
    _oxgcseoaiTableView.delegate = self;
    _oxgcseoaiTableView.dataSource = self;
    _oxgcseoaiTableView.rowHeight = 60.0;
    _oxgcseoaiTableView.backgroundColor = UIColor.whiteColor;
    _oxgcseoaiTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_oxgcseoaiTableView registerNib:[UINib nibWithNibName:@"LaMackcallTVCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"LaMackcallTVCell"];
    [_oxgcseoaiTableView registerNib:[UINib nibWithNibName:@"LaContactsHeaderView" bundle:NSBundle.mainBundle] forHeaderFooterViewReuseIdentifier:@"LaContactsHeaderView"];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataArray.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.dataArray.count <= 0) {
        return 0;
    }
    return _dataArray[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaMackcallTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaMackcallTVCell" forIndexPath:indexPath];
    cell.userInfo = _dataArray[indexPath.section][indexPath.row];
    if (_dataArray[indexPath.section].count == indexPath.row + 1) { // 每个分区最后一个row
        cell.lineView.hidden = YES;
    }else {
        cell.lineView.hidden = NO;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (_dataArray.count <= 0) {
        return 0.01;
    }
    return 25.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    LaContactsHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"LaContactsHeaderView"];
    view.oxaicsgoeTitleLabel.text = _sectionTitles[section];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
//    view.backgroundColor = UIColor.groupTableViewBackgroundColor;
}

- (NSMutableArray<NSArray<WFCCUserInfo *> *> *)dataArray {
    if (!_dataArray) {
        _dataArray = NSMutableArray.new;
    }return _dataArray;
}

- (NSMutableArray<NSString *> *)sectionTitles {
    if (!_sectionTitles) {
        _sectionTitles = NSMutableArray.new;
    }return _sectionTitles;
}


// 按首字母分组排序数组
- (NSMutableArray *)sortObjectsAccordingToInitialWith:(NSArray *)arrar {
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSArray *section_titles = [collation sectionTitles];
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];

    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }

    //将每个名字分到某个section下
    for (WFCCUserInfo *personModel in arrar) {
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = 0;
        if (personModel.friendAlias.length) {
            sectionNumber = [collation sectionForObject:personModel collationStringSelector:@selector(friendAlias)];
        }else {
            sectionNumber = [collation sectionForObject:personModel collationStringSelector:@selector(displayName)];
        }
        //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:personModel];
    }

    //对每个section中的数组按照name属性排序
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *personArrayForSection = newSectionsArray[index];
        NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:@selector(displayName)];
        newSectionsArray[index] = sortedPersonArrayForSection;
    }

    //删除空的数组
    NSMutableArray *finalArr = [NSMutableArray new];
    [self.sectionTitles removeAllObjects];
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        if (((NSMutableArray *)(newSectionsArray[index])).count != 0) {
            [finalArr addObject:newSectionsArray[index]];
            [self.sectionTitles addObject:section_titles[index]];
        }
    }
    return finalArr;
}

@end


@implementation LaMackcallTVCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _iconView.layer.cornerRadius = 20.0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setUserInfo:(WFCCUserInfo *)userInfo {
    _userInfo = userInfo;

    [_iconView sd_setImageWithURL:URL(_userInfo.portrait) placeholderImage:[QWERImage imageNamed:@"PersonalChat"] options:SDWebImageScaleDownLargeImages
                          context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
    _asoucNameLabel.text = _userInfo.friendAlias.length > 0 ? _userInfo.friendAlias : _userInfo.displayName;
}

- (IBAction)video_voice_btn:(UIButton *)sender {
#if WFCU_SUPPORT_VOIP
    WFCCConversation *conversation = [WFCCConversation conversationWithType:Single_Type target:_userInfo.userId line:0];
    
    RADCOVideoVC *videoVC = [[RADCOVideoVC alloc] initWithTargets:@[_userInfo.userId] conversation:conversation audioOnly:(sender.tag == 0 ? NO : YES)];
    [[Chat86AVEngineKit sharedEngineKit] presentViewController:videoVC];
#endif
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.iconView sd_cancelCurrentImageLoad];
    self.iconView.image = nil;
}

@end
