//
//  LaCallosVC.m
//  WildFireChat
//
//  Created by Ruby on 11/6/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "LaCallosVC.h"
#import "LaCallosTVCell.h"

#import "LaCallosDetailsVC.h"
#import "LaMackcallVC.h"

@interface LaCallosVC ()<UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchResultsUpdating>
{
    NSInteger _chooseType;
    
    NSInteger _currentSection;
    
    BOOL _isChinese;
}
@property (nonatomic, weak) UIButton *aButton;
@property (nonatomic, weak) UIButton *bButton;
@property (nonatomic, weak) UIView *lineView;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray            *dataSource;
@property (nonatomic, strong) NSMutableArray<AddAudioModel *>            *dataList;

@property (nonatomic, strong) NSMutableArray<AddAudioModel *> *searchList;
@property (nonatomic, strong)  UISearchController       *searchController;

@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) LaCallosDetailsVC *callosVC;


@property (weak, nonatomic) IBOutlet UIView *bottomView; // 左上角的编辑 ---> 批量删除
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *allSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (nonatomic, assign) BOOL isNormalState; // 是否正常状态  也就是非编辑

@property (nonatomic, assign) NSInteger selectNum; // 编辑 -> 选择的数量

@end

@implementation LaCallosVC

- (void)updateADFLanguage:(NSNotification *)noti {
    _isChinese = [CommonHelper.main isChinese];
    
    [_allSelectButton setTitle:LLLLLL(@"Alls") forState:UIControlStateNormal];
    
    _titleLabel.text = LLLLLL(@"Message");
    [self.searchController.searchBar setPlaceholder:LLLLLL(@"Search")];
    [_aButton setTitle:LLLLLL(@"All") forState:UIControlStateNormal];
    [_bButton setTitle:LLLLLL(@"Unanswered") forState:UIControlStateNormal];
    if (!_isNormalState) { // 编辑状态下
        self.selectNum = self.selectNum;
        self.isNormalState = self.isNormalState;
    }
    if (noti != nil) {
        [_tableView reloadData];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self updateADFLanguage:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateADFLanguage:) name:kLanguageNoti object:nil];
    
    self.navigationItem.titleView = [self setNaviView];
    self.isNormalState = YES;
    
    _selectNum = 0;
    _chooseType = 0;
    _currentSection = -1;
    _dataList = NSMutableArray.new;
    _searchList = NSMutableArray.new;
    _dataSource = NSArray.new;
    
    [self requestData:nil];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.rowHeight = 74.0;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectZero];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [_tableView registerNib:[UINib nibWithNibName:@"LaCallosTVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"LaCallosTVCell"];
    
    
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    if (@available(iOS 13, *)) {
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
        UIImage* searchBarBg = [UIImage imageWithColor:RGBA(0xF6F6F6) size:CGSizeMake(self.view.frame.size.width - 15 * 2, 36) cornerRadius:10];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    } else {
        [self.searchController.searchBar setValue:LLLLLL(@"Cancel") forKey:@"_cancelButtonText"];
    }
    if (@available(iOS 9.1, *)) {
        self.searchController.obscuresBackgroundDuringPresentation = NO;
    }
    [self.searchController.searchBar setPlaceholder:LLLLLL(@"Search")];
    
    _searchController.searchBar.backgroundImage = UIImage.new;
    _searchController.searchBar.backgroundColor = UIColor.whiteColor;
    self.tableView.tableHeaderView = [self tableHeaderView:LLLLLL(@"Call") searchBar:_searchController.searchBar];
    self.tableView.tableHeaderView.backgroundColor = UIColor.whiteColor;
    
    // 这句话可以解决 self.tableView.tableHeaderView = _searchController.searchBar 导致的搜索栏下滑灰色的问题
    self.tableView.backgroundView = UIView.new;
    
    self.definesPresentationContext = YES;
    
    
    NSArray *saveAudioData = [NSUserDefaults.standardUserDefaults objectForKey:UNString(@"%@AudioHistory", [WFCCNetworkService sharedInstance].userId)];
    if (saveAudioData.count) {
        NSArray *datas = [AddAudioModel mj_objectArrayWithKeyValuesArray:saveAudioData];
        self.dataSource = [datas sortedArrayUsingComparator:^NSComparisonResult(AddAudioModel  * obj1, AddAudioModel  * obj2) {
            return obj1.createdTime <= obj2.createdTime;
        }];
        [self filterData];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData:) name:kRefreshCallHistory object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestData:) name:kUserInfoUpdated object:nil];
}

- (void)cseoaixgoCall {
    LaMackcallVC *vc = LaMackcallVC.new;
    vc.hidesBottomBarWhenPushed = YES;
    vc.targetId = [WFCCNetworkService sharedInstance].userId;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)requestData:(NSNotification *)notification {
    NSInteger dataFlag = 0;
    if (notification != nil) {
        dataFlag = [notification.userInfo[@"DATAFLAG"] integerValue];
    }
    
    WS(weakself)
    NSString *userId = WFCCNetworkService.sharedInstance.userId;
    [QWERConfigManager.globalManager.appServiceProvider queryAudioHistory:@{@"userId":userId, @"type":@"0"} success:^(NSDictionary * _Nonnull dict) {
        NSArray *datas = dict[@"result"];
        [[NSUserDefaults standardUserDefaults] setObject:datas forKey:UNString(@"%@AudioHistory", userId)];
        [[NSUserDefaults standardUserDefaults] synchronize];
        

        weakself.dataSource = [[AddAudioModel mj_objectArrayWithKeyValuesArray:datas] sortedArrayUsingComparator:^NSComparisonResult(AddAudioModel  * obj1, AddAudioModel  * obj2) {
            return obj1.createdTime <= obj2.createdTime;
        }];
        [weakself filterData];
        
        if (dataFlag == 100) {
            if (weakself.callosVC != nil && self->_currentSection != -1) {
                weakself.callosVC.dataSource = [self getTargetData];
            }
        }
    } error:^(int errCode, NSString * _Nonnull message) {
        
    }];
}
- (void)filterData {
    if (_chooseType == 0) {
        self.dataList = self.dataSource.mutableCopy;
    }else {
        self.dataList = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"jsonObject.status = 1"]].mutableCopy;
    }
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}
//table 返回的行数
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active) {
        return _searchList.count;
    }
    return _dataList.count;
}
//返回单元格内容
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaCallosTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaCallosTVCell" forIndexPath:indexPath];
    cell.separatorInset = UIEdgeInsetsMake(0, 80.0, 0, 0);
    if (_searchController.active) {
        cell.audioModel = _searchList[indexPath.row];
    }else {
        AddAudioModel *model = _dataList[indexPath.row];
        cell.audioModel = model;
        
        if (self.isNormalState) {
            cell.stateButton.hidden = YES;
            cell.iconLeft.constant = 20.0;
            model.isSelect = NO;
        }else {
            cell.stateButton.hidden = NO;
            cell.iconLeft.constant = 49.0;
            model.isSelect = model.isSelect;
        }
        cell.stateButton.selected = model.isSelect;
    }
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isNormalState) {
        _currentSection = indexPath.row;
        
        _callosVC = LaCallosDetailsVC.new;
        _callosVC.hidesBottomBarWhenPushed = YES;
        _callosVC.dataSource = [self getTargetData];
        WS(weakself)
        [_callosVC setCallosDeleteSuccessBlock:^{
            [weakself requestData:nil];
        }];
        [self.navigationController pushViewController:_callosVC animated:YES];
        return;
    }
    
    AddAudioModel *model = _dataList[indexPath.row];
    model.isSelect = !model.isSelect;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    if (model.isSelect) {
        self.selectNum += 1;
    }else {
        self.selectNum -= 1;
    }
}
- (NSMutableArray *)getTargetData {
    AddAudioModel *model = _dataList[_currentSection];
    NSMutableArray *results = NSMutableArray.new;
    for (AddAudioModel *result in _dataList) {
        if ([result.jsonObject.targetId isEqualToString:model.jsonObject.targetId]) {
            [results addObject:result];
        }
    }
    
    return [results sortedArrayUsingComparator:^NSComparisonResult(AddAudioModel  * obj1, AddAudioModel  * obj2) {
        return obj1.createdTime <= obj2.createdTime;
    }].mutableCopy;
}


- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.isNormalState;
}
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return LLLLLL(@"Delete");
}
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.isNormalState) {
        if (editingStyle == UITableViewCellEditingStyleDelete) {
            WS(weakself)
            // QWERConfigManager.globalManager.appServiceProvider
            [AppService.sharedAppService deleteAudioHistory:@{@"ids":@[_dataList[indexPath.row].id]} success:^(NSDictionary * _Nonnull dict) {
                [weakself requestData:nil];
            } error:^(int errCode, NSString * _Nonnull message) {
            }];
            [self.dataList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
    _titleLabel.hidden = YES;
}
- (void)didPresentSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = YES;
    self.extendedLayoutIncludesOpaqueBars = YES;
    
    CGRect topBgViewFrame = _topBgView.frame;
    topBgViewFrame.size.height = _searchController.searchBar.frame.size.height;
    _topBgView.frame = topBgViewFrame;
}

- (void)willDismissSearchController:(UISearchController *)searchController {
    self.tabBarController.tabBar.hidden = NO;
    self.extendedLayoutIncludesOpaqueBars = NO;
}
- (void)didDismissSearchController:(UISearchController *)searchController {
    _titleLabel.hidden = NO;
    
    CGRect topBgViewFrame = _topBgView.frame;
    topBgViewFrame.size.height = 106.0;
    _topBgView.frame = topBgViewFrame;
    [self.tableView reloadData];
}

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    if (searchController.active) {
        NSString *searchString = [self.searchController.searchBar text];
        // 1. 获取当前的输入模式
        if (@available(iOS 13.0, *)) {
            UITextInputMode *currentInputMode = searchController.searchBar.searchTextField.textInputMode;
            NSString *keyboardLanguage = currentInputMode.primaryLanguage;
            // 2. 判断是否是中文键盘（可能是 zh-Hans、zh-Hant 等）
            BOOL isChineseKeyboard = [keyboardLanguage hasPrefix:@"zh"];

            // 3. 获取 markedTextRange
            UITextRange *markedRange = searchController.searchBar.searchTextField.markedTextRange;
            // 4. 只有当【使用中文键盘】且【没有拼音未上屏】时才触发搜索
            if (isChineseKeyboard && markedRange != nil) {
                return;
            }
        } else {
            // Fallback on earlier versions
        }
        [self.searchList removeAllObjects];
        if (searchString.length > 0) {
            QOEUAPinyinUtility *pu = [[QOEUAPinyinUtility alloc] init];
            BOOL isChinese = [pu isChinese:searchString];
            
            for (AddAudioModel *model in self.dataList) {
                WFCCUserInfo *targetUserInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:model.jsonObject.targetId refresh:NO];
                
                if ([targetUserInfo.displayName.lowercaseString containsString:searchString.lowercaseString] || [targetUserInfo.friendAlias.lowercaseString containsString:searchString.lowercaseString]) {
                    [self.searchList addObject:model];
                } else if(!isChinese) {
                    if ([pu isMatch:targetUserInfo.displayName ofPinYin:searchString] || [pu isMatch:targetUserInfo.friendAlias ofPinYin:searchString]) {
                        [self.searchList addObject:model];
                    }
                }
            }
        }
    }
    [self.tableView reloadData];
}



- (void)callType:(UIButton *)sender {
    if (sender.tag == _chooseType) {
        return;
    }
    _chooseType = sender.tag;
    WS(weakself)
    [UIView animateWithDuration:0.5 animations:^{
        weakself.lineView.center = CGPointMake(sender.center.x, sender.center.y + 16.0);
    } completion:^(BOOL finished) {
        if (self->_chooseType == 0) {
            weakself.aButton.titleLabel.font = PINGFANG_M(18.0)
            [weakself.aButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            
            weakself.bButton.titleLabel.font = PINGFANG_M(14.0)
            [weakself.bButton setTitleColor:RGBA(0x888888) forState:UIControlStateNormal];
        }else {
            weakself.bButton.titleLabel.font = PINGFANG_M(18.0)
            [weakself.bButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
            
            weakself.aButton.titleLabel.font = PINGFANG_M(14.0)
            [weakself.aButton setTitleColor:RGBA(0x888888) forState:UIControlStateNormal];
        }
        
        [weakself filterData];
    }];
}

- (UIView *)setNaviView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0/*WIDTH*0.44*/, 44.0)];
    view.backgroundColor = UIColor.clearColor;
    
    UIButton *aButton = [UIButton buttonWithType:UIButtonTypeCustom];
    aButton.frame = CGRectMake(0.0, 0.0, 85.0, view.frame.size.height);
    [aButton setTitle:LLLLLL(@"All") forState:UIControlStateNormal];
    [aButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    aButton.titleLabel.font = PINGFANG_M(18.0)
    aButton.backgroundColor = UIColor.whiteColor;
    aButton.tag = 0;
    [aButton addTarget:self action:@selector(callType:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:aButton];
    _aButton = aButton;
    
    UIButton *bButton = [UIButton buttonWithType:UIButtonTypeCustom];
    bButton.frame = CGRectMake(85.0, 0.0, 115.0, view.frame.size.height);
    [bButton setTitle:LLLLLL(@"Unanswered") forState:UIControlStateNormal];
    [bButton setTitleColor:RGBA(0x888888) forState:UIControlStateNormal];
    bButton.titleLabel.font = PINGFANG_M(14.0)
    bButton.backgroundColor = UIColor.whiteColor;
    bButton.tag = 1;
    [bButton addTarget:self action:@selector(callType:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:bButton];
    _bButton = bButton;
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 20.0, 3.0)];
    lineView.center = CGPointMake(aButton.center.x, aButton.center.y + 16.0);
    lineView.backgroundColor = UIColor.blackColor;
    lineView.layer.cornerRadius = 1.5;
    [view addSubview:lineView];
    _lineView = lineView;
    return view;
}


//  filter 0 所有   1 未接
- (NSMutableArray<NSArray<AddAudioModel *> *> *)filterObjectArray { // AddAudioModel
    NSMutableArray<NSString *> *targetIds = NSMutableArray.new;
    NSArray *filterData = nil;
    if (_chooseType == 0) {
        filterData = self.dataSource;
    }else {
        filterData = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"jsonObject.status = %ld",_chooseType]];
    }
    filterData = [filterData sortedArrayUsingComparator:^NSComparisonResult(AddAudioModel  * obj1, AddAudioModel  * obj2) {
        return obj1.createdTime <= obj2.createdTime;
    }];
    for (AddAudioModel *target in filterData) {
        BOOL isHaved = NO; // targetIds中是否存在
        for (NSString *targetId in targetIds) {
            if ([target.jsonObject.targetId isEqualToString:targetId]) {
                isHaved = YES;
                break;
            }
        }
        if (isHaved == NO) {
            [targetIds addObject:target.jsonObject.targetId];
        }
    }
    
    //初始化一个数组resultsArray用来存放最终的数据
    NSMutableArray *resultsArray = [[NSMutableArray alloc] initWithCapacity:targetIds.count];
    
    for (NSString *targetId in targetIds) {
        NSMutableArray *results = NSMutableArray.new;
        for (AddAudioModel *target in filterData) {
            if ([target.jsonObject.targetId isEqualToString:targetId]) {
                [results addObject:target];
            }
        }
        
        [resultsArray addObject:results];
    }
    
    return resultsArray;
}

- (UIView *)tableHeaderView:(NSString *)title searchBar:(UISearchBar *)searchBar {
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, WIDTH, 106.0)];
    bgView.backgroundColor = UIColor.whiteColor;
    _topBgView = bgView;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, 12.0, WIDTH - 40.0, 35.0)];
    titleLabel.backgroundColor = UIColor.clearColor;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    titleLabel.textColor = RGBA(0x222222);
    titleLabel.font = PINGFANG_M(23.0);
    titleLabel.text = title;
    [bgView addSubview:titleLabel];
    _titleLabel = titleLabel;
    
    UIView *bg2View = [[UIView alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY(titleLabel.frame)+3.0, WIDTH, searchBar.frame.size.height)];
    bg2View.backgroundColor = UIColor.clearColor;
    [bgView addSubview:bg2View];
    
    [bg2View addSubview:searchBar];
    
    return bgView;
}



#pragma mark - 左上角的编辑 ---> 批量删除

- (void)setIsNormalState:(BOOL)isNormalState {
    _isNormalState = isNormalState;
    
    if (_isNormalState) { // 非编辑
        self.tabBarController.tabBar.hidden = NO;
        self.extendedLayoutIncludesOpaqueBars = NO;
        
        self.navigationItem.titleView.hidden = NO;
        
        self.navigationItem.leftBarButtonItem = nil;
        UIButton *leftItem = [self itemImage:@"oxgcseoaiEdit" action:@selector(editStart)];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItem];
        
        self.navigationItem.rightBarButtonItem = nil;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[self itemImage:@"cseoaixgoCall" action:@selector(cseoaixgoCall)]];
        
        _searchController.searchBar.userInteractionEnabled = YES;
        
        _bottomView.hidden = YES;
        _bottomViewHeight.constant = 0.0;
        _bottomViewBottom.constant = 0.0;
    }else {
        self.tabBarController.tabBar.hidden = YES;
        self.extendedLayoutIncludesOpaqueBars = YES;
        
        self.navigationItem.titleView.hidden = YES;
        
        self.navigationItem.leftBarButtonItem = nil;
        
        self.navigationItem.rightBarButtonItem = nil;
        UIButton *righttem = [self itemTitle:LLLLLL(@"Ok") action:@selector(editFinish)];
        righttem.titleLabel.font = PINGFANG_M(17);
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:righttem];
        
        _searchController.searchBar.userInteractionEnabled = NO;
        
        _bottomView.hidden = NO;
        _bottomViewHeight.constant = 50.0;
        _bottomViewBottom.constant = -49.0;
    }
    self.selectNum = 0;
    _allSelectButton.selected = NO;
    _deleteButton.selected = NO;
}
// 点击编辑按钮、开始
- (void)editStart {
    self.isNormalState = NO;
    [self.tableView reloadData];
}
- (void)editFinish { // 点击完成按钮、恢复普通状态
    self.isNormalState = YES;
    [self.tableView reloadData];
}

- (void)setSelectNum:(NSInteger)selectNum {
    _selectNum = selectNum;
    
    if (_selectNum <= 0) {
        _titleLabel.text = LLLLLL(@"Call");
        _allSelectButton.selected = NO;
        _deleteButton.selected = NO;
        _deleteButton.userInteractionEnabled = NO;
    }else {
        if (_isChinese) {
            _titleLabel.text = UNString(@"已选择%ld条",_selectNum);
        }else {
            _titleLabel.text = UNString(@"Đã chọn %ld mục",_selectNum);
        }
        _deleteButton.selected = YES;
        _deleteButton.userInteractionEnabled = YES;
        if (_selectNum == _dataList.count) {
            _allSelectButton.selected = YES;
        }else {
            _allSelectButton.selected = NO;
        }
    }
}

- (IBAction)allSelect:(UIButton *)sender { // 全选按钮
    if (_dataList.count <= 0) {
        return;
    }
    sender.selected = !sender.selected;
    
    BOOL selected = NO;
    if (self.selectNum == _dataList.count) { // 已经被全选了、实现全部置空
        selected = NO;
        self.selectNum = 0;
    }else if (self.selectNum >= 0) { // 未被选择或者有部分被选择，那么点全选按钮后，实现全选
        selected = YES;
        self.selectNum = _dataList.count;
    }
    for (AddAudioModel *model in _dataList) {
        model.isSelect = selected;
    }
    [self.tableView reloadData];
}

- (IBAction)delete:(UIButton *)sender { // 删除按钮
    if (self.selectNum <= 0) {
        return;
    }
    
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle:(_isChinese?UNString(@"确定要删除%ld条通话记录吗？", self.selectNum):UNString(@"Xác nhận muốn xóa lịch sử %ld cuộc hội thoại?", self.selectNum)) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:LLLLLL(@"Cancel") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    WS(weakself)
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:LLLLLL(@"AlertButton") style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        NSMutableArray *ids = NSMutableArray.new;
        for (AddAudioModel *model in weakself.dataList) {
            if (model.isSelect) {
                [ids addObject:model.id];
            }
        }
        if (ids.count <= 0) {
            return;
        }
        
        __block MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:weakself.view animated:YES];
        hud.label.text = LLLLLL(@"Deleting");
        [hud showAnimated:YES];
        
        [AppService.sharedAppService deleteAudioHistory:@{@"ids":ids} success:^(NSDictionary * _Nonnull dict) {
            [hud hideAnimated:YES];
            [weakself requestData:nil];
            weakself.selectNum -= ids.count;
        } error:^(int errCode, NSString * _Nonnull message) {
            [hud hideAnimated:YES];
            [weakself.view makeToast:message duration:1.0 position:CSToastPositionCenter];
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
