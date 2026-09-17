//
//  SelectLaContactVC.m
//  WildFireChat
//
//  Created by wtb on 2025/4/23.
//  Copyright © 2025 WildFireChat. All rights reserved.
//

#import "SelectLaContactVC.h"
#import "SelectLaTableVCell.h"

@interface SelectLaContactVC ()<UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong)  UISearchController       *searchController;
@property UIScrollView *headV;

@property(nonatomic, strong) NSMutableDictionary *resultDic;
@property (nonatomic, strong)NSMutableArray<WFCCUserInfo *> *dataArray;
@property (nonatomic, strong)NSMutableArray<WFCCUserInfo *> *selectedContacts;

@property(nonatomic, strong)UIActivityIndicatorView *activityIndicator;

@property (nonatomic, strong) NSMutableArray<WFCCUserInfo *> *searchList;

@property (nonatomic, strong)NSArray *candidateUsers;

@property(nonatomic, strong) NSDictionary *allFriendSectionDic;
@property(nonatomic, strong) NSArray *allKeys;


@property(nonatomic, assign)BOOL sorting;
@property(nonatomic, assign)BOOL needSort;

@property (nonatomic, strong) UIView *topBgView;
@property (nonatomic, strong) UILabel *titleLabel;
@end

static NSMutableDictionary *hanziStringDict = nil;
static NSString *wfcstar = @"☆";

@implementation SelectLaContactVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.dataArray = [[NSMutableArray alloc] init];
    [self loadContact:NO];
}

- (void)loadContact:(BOOL)forceLoadFromRemote {
    [self.dataArray removeAllObjects];
    NSArray *userIdList;
    if (self.candidateUsers.count) {
        userIdList = self.candidateUsers;
    } else {
        userIdList = [[WFCCIMService sharedWFCIMService] getMyFriendList:forceLoadFromRemote];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wfc_uikit_had_pc_session"]) {
            if (![userIdList containsObject:[QWERConfigManager globalManager].fileTransferId]) {
                NSMutableArray *ma = [userIdList mutableCopy];
                [ma addObject:[QWERConfigManager globalManager].fileTransferId];
                userIdList = [ma copy];
            }
        }
    }
    self.dataArray = [[[WFCCIMService sharedWFCIMService] getUserInfos:userIdList inGroup:self.groupId] mutableCopy];
//    for (WFCCUserInfo *userinfo in self.dataArray) {
//        NSLog(@"toJsonObj===%@",userinfo.toJsonObj);
//    }
    self.needSort = YES;
}

- (void)setNeedSort:(BOOL)needSort {
    _needSort = needSort;
    if (needSort && !self.sorting) {
        _needSort = NO;
        NSArray *safeDataArray = [self.dataArray copy]; // 创建副本防止修改
        NSArray *safeSearchArray = [self.searchList copy]; // 创建副本防止修改
        if (self.searchController.active) {
            [self sortAndRefreshWithList:safeSearchArray];
        } else {
            [self sortAndRefreshWithList:safeDataArray];
        }
    }
}

- (void)sortAndRefreshWithList:(NSArray *)friendList {
    self.sorting = YES;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.resultDic = [SelectLaContactVC sortedArrayWithPinYinDic:friendList];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.allFriendSectionDic = self.resultDic[@"infoDic"];
            self.allKeys = self.resultDic[@"allKeys"];
            
            [self.tableView reloadData];
            self.sorting = NO;
            if (self.needSort) {
                self.needSort = self.needSort;
            }
            [self.activityIndicator stopAnimating];
            self.activityIndicator.hidden = YES;
        });
    });
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = CGPointMake(self.view.bounds.size.width/2, self.view.bounds.size.height/2);
        [self.view addSubview:_activityIndicator];
        [_activityIndicator startAnimating];
        [self.view bringSubviewToFront:_activityIndicator];
    }
    return _activityIndicator;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 11, *)) { // https://www.jianshu.com/p/2378ca588efd
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"SelectFriend");
    [self setRightNavi];

    
    _searchList = NSMutableArray.new;
    _selectedContacts = NSMutableArray.new;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectLaTableVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"SelectLaTableVCell"];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.delegate = self;
    self.searchController.dimsBackgroundDuringPresentation = YES;
    
    if (@available(iOS 13, *)) {
        self.searchController.searchBar.searchBarStyle = UISearchBarStyleDefault;
        UIImage* searchBarBg = [UIImage imageWithColor:RGBA(0xF6F6F6) size:CGSizeMake(WIDTH - 15 * 2, 36) cornerRadius:10];
        [self.searchController.searchBar setSearchFieldBackgroundImage:searchBarBg forState:UIControlStateNormal];
    } else {
        [self.searchController.searchBar setValue:LLLLLL(@"Cancel") forKey:@"_cancelButtonText"];
    }
    if (@available(iOS 9.1, *)) {
        self.searchController.obscuresBackgroundDuringPresentation = NO;
    }
    [self.searchController.searchBar setPlaceholder:LLLLLL(@"Search")];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = _searchController;
        _searchController.hidesNavigationBarDuringPresentation = YES;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    } else {
        _searchController.searchBar.backgroundImage = UIImage.new;
        _searchController.searchBar.backgroundColor = UIColor.whiteColor;

        self.tableView.tableHeaderView = _searchController.searchBar;
        self.tableView.tableHeaderView.backgroundColor = UIColor.whiteColor;
    }
    
    self.headV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 70)];
    self.tableView.tableHeaderView = _headV;
    // 这句话可以解决 self.tableView.tableHeaderView = _searchController.searchBar 导致的搜索栏下滑灰色的问题
    self.tableView.backgroundView = UIView.new;
    
    self.definesPresentationContext = YES;
    [self.view bringSubviewToFront:self.activityIndicator];
}

- (void)freshSelet {
    for (UIView *v in self.headV.subviews) {
        [v removeFromSuperview];
    }
    
    for (int i = 0; i < self.selectedContacts.count; i++) {
        WFCCUserInfo *groupInfo = self.selectedContacts[i];
        UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18+58*i, 15, 40, 40)];
        portraitImgView.clipsToBounds = YES;
        portraitImgView.layer.cornerRadius = 20;
        [portraitImgView sd_setImageWithURL:URL(groupInfo.portrait) placeholderImage:[UIImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                         context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        [self.headV addSubview:portraitImgView];
    }
    [self.headV setContentSize:CGSizeMake(18+58*_selectedContacts.count, 0)];
    
    [self setRightNavi];
}

- (void)setRightNavi {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@(%lu)",LLLLLL(@"AlertButton"),(unsigned long)_selectedContacts.count] style:UIBarButtonItemStyleDone target:self action:@selector(sendAct)];
}

- (void)sendAct {
    if (self.selectedContacts.count == 0) {
        [self.view makeToast:LLLLLL(@"SelectFriend")];
        return;
    }
    [SVProgressHUD show];
    if (self.message) {
        for (int i = 0; i < self.selectedContacts.count;i++) {
            WFCCUserInfo *userInfo = self.selectedContacts[i];
            WFCCConversation *conversation = [[WFCCConversation alloc] init];
            conversation.type = Single_Type;
            conversation.target = userInfo.userId;
            conversation.line = 0;
            
            [[WFCCIMService sharedWFCIMService] send:conversation content:self.message.content success:^(long long messageUid, long long timestamp) {

            } error:^(int error_code) {

            }];
            [NSThread sleepForTimeInterval:0.1];
            if (i+1 == self.selectedContacts.count) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:LLLLLL(@"ForwardSuccess")];
            }
        }
        
    } else {
        int total = 0;
        for (int i = 0; i<self.messages.count;i++) {
            WFCCMessage *msg = self.messages[i];
            for (int j = 0; j < self.selectedContacts.count; j++) {
                WFCCUserInfo *userInfo = self.selectedContacts[j];
                WFCCConversation *conversation = [[WFCCConversation alloc] init];
                conversation.type = Single_Type;
                conversation.target = userInfo.userId;
                conversation.line = 0;
                
                [[WFCCIMService sharedWFCIMService] send:conversation content:msg.content success:^(long long messageUid, long long timestamp) {

                } error:^(int error_code) {
                    dispatch_async(dispatch_get_main_queue(), ^{

                    });
                }];
                [NSThread sleepForTimeInterval:0.1];
                total = (i+1)*(j+1);
            }
            
            [NSThread sleepForTimeInterval:0.1];
            
            if (total == self.selectedContacts.count*self.messages.count) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:LLLLLL(@"ForwardSuccess")];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.allKeys.count;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.allKeys.count == 0) {
        return 0;
    }
    NSArray *dataSource;
    dataSource = self.allFriendSectionDic[self.allKeys[section]];
    return dataSource.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 18.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.allKeys.count == 0) {
        return nil;
    }
    NSString *title;
    title = self.allKeys[section];
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 18)];
    view.backgroundColor = [UIColor colorWithHexString:@"#F6F6F6"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(18, 0, self.view.frame.size.width, 18)];
    label.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:12];
    label.textColor = [UIColor colorWithHexString:@"#2C2C2C"];
    label.textAlignment = NSTextAlignmentLeft;
    if ([title isEqualToString:wfcstar]) {
        title = LLLLLL(@"StarFriends");
    }
    label.text = [NSString stringWithFormat:@"%@", title];
    [view addSubview:label];
    return view;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {    
    NSArray *dataSource;
    dataSource = self.allFriendSectionDic[self.allKeys[indexPath.section]];

    SelectLaTableVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectLaTableVCell" forIndexPath:indexPath];
    WFCCUserInfo *userInfo = dataSource[indexPath.row];
    [cell setUseInfo:userInfo];
    [cell isselectImg:NO];
    for (WFCCUserInfo *user in self.selectedContacts) {
        if ([user.userId isEqualToString:userInfo.userId]) {
            [cell isselectImg:YES];
            break;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *dataSource;
    dataSource = self.allFriendSectionDic[self.allKeys[indexPath.section]];
    WFCCUserInfo *userInfo = dataSource[indexPath.row];
    
    BOOL isselect = NO;
    int i = 0;
    for (WFCCUserInfo *user in self.selectedContacts) {
        if ([user.userId isEqualToString:userInfo.userId]) {
            [self.selectedContacts removeObjectAtIndex:i];
            isselect = YES;
            break;
        }
        i++;
    }
    if (!isselect) {
        [self.selectedContacts addObject:userInfo];
    }
    [self freshSelet];
    [tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (@available(iOS 11.0, *)) {
        if (self.searchController.active) {
            return self.allKeys;
        }
        NSMutableArray *indexs = [self.allKeys mutableCopy];
        [indexs insertObject:@"" atIndex:0];
        return indexs;
    } else {
        return nil;
    }
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if (self.searchController.active) {
        [self.searchController.searchBar resignFirstResponder];
    }
}

#pragma mark - UISearchControllerDelegate

- (void)willPresentSearchController:(UISearchController *)searchController {
}
- (void)didPresentSearchController:(UISearchController *)searchController {
}
- (void)willDismissSearchController:(UISearchController *)searchController {
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

        if (self.searchList!= nil) {
            [self.searchList removeAllObjects];
            if(searchString.length) {
                QOEUAPinyinUtility *pu = [[QOEUAPinyinUtility alloc] init];
                BOOL isChinese = [pu isChinese:searchString];
                for (WFCCUserInfo *friend in self.dataArray) {
                    if ([friend.displayName.lowercaseString containsString:searchString.lowercaseString] || [friend.friendAlias.lowercaseString containsString:searchString.lowercaseString]) {
                        [self.searchList addObject:friend];
                    } else if(!isChinese) {
                        if([pu isMatch:friend.displayName ofPinYin:searchString] || [pu isMatch:friend.friendAlias ofPinYin:searchString]) {
                            [self.searchList addObject:friend];
                        }
                    }
                }
            }
        }
        self.needSort = YES;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (NSMutableDictionary *)sortedArrayWithPinYinDic:(NSArray *)userList {
    if (!userList)
        return nil;
    NSArray *_keys = @[wfcstar,
                       @"A",
                       @"B",
                       @"C",
                       @"D",
                       @"E",
                       @"F",
                       @"G",
                       @"H",
                       @"I",
                       @"J",
                       @"K",
                       @"L",
                       @"M",
                       @"N",
                       @"O",
                       @"P",
                       @"Q",
                       @"R",
                       @"S",
                       @"T",
                       @"U",
                       @"V",
                       @"W",
                       @"X",
                       @"Y",
                       @"Z",
                       @"#"];
    
    NSMutableDictionary *infoDic = [NSMutableDictionary new];
    NSMutableArray *_tempOtherArr = [NSMutableArray new];
    BOOL isReturn = NO;
    NSMutableDictionary *firstLetterDict = [[NSMutableDictionary alloc] init];
    
    NSArray<NSString *> *favUsers = [[WFCCIMService sharedWFCIMService] getFavUsers];
    
    NSMutableArray *favArrays = [[NSMutableArray alloc] init];
    for (NSString *favUser in favUsers) {
        for (WFCCUserInfo *userInfo in userList) {
            if ([userInfo.userId isEqualToString:favUser]) {
                [favArrays addObject:userInfo];
                break;
            }
        }
        
    }
    if (favArrays.count) {
        [infoDic setObject:favArrays forKey:wfcstar];
    }
    
    
    for (NSString *key in _keys) {
        if ([key isEqualToString:wfcstar]) {
            continue;
        }
        if ([_tempOtherArr count]) {
            isReturn = YES;
        }
        NSMutableArray *tempArr = [NSMutableArray new];
        for (id user in userList) {
            NSString *firstLetter;

            WFCCUserInfo *userInfo = (WFCCUserInfo*)user;
            NSString *userName = userInfo.displayName;
            if (userInfo.groupAlias.length) {
                userName = userInfo.groupAlias;
            }
            if (userInfo.friendAlias.length) {
                userName = userInfo.friendAlias;
            }
            if (userName.length == 0) {
                userInfo.displayName = [NSString stringWithFormat:@"<%@>", userInfo.userId];
                userName = userInfo.displayName;
            }
            
            firstLetter = [firstLetterDict objectForKey:userName];
            if (!firstLetter) {
                firstLetter = [self getFirstUpperLetter:userName];
                [firstLetterDict setObject:firstLetter forKey:userName];
            }
            
            
            if ([firstLetter isEqualToString:key]) {
                [tempArr addObject:user];
            }
            
            if (isReturn)
                continue;
            char c = [firstLetter characterAtIndex:0];
            if (isalpha(c) == 0) {
                [_tempOtherArr addObject:user];
            }
        }
        if (![tempArr count])
            continue;
        [infoDic setObject:tempArr forKey:key];
    }
    if ([_tempOtherArr count])
        [infoDic setObject:_tempOtherArr forKey:@"#"];
    
    NSArray *keys = [[infoDic allKeys]
                     sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                         
                         return [obj1 compare:obj2 options:NSNumericSearch];
                     }];
    NSMutableArray *allKeys = [[NSMutableArray alloc] initWithArray:keys];
    if ([allKeys containsObject:@"#"]) {
        [allKeys removeObject:@"#"];
        [allKeys insertObject:@"#" atIndex:allKeys.count];
    }
    if ([allKeys containsObject:wfcstar]) {
        [allKeys removeObject:wfcstar];
        [allKeys insertObject:wfcstar atIndex:0];
    }
    NSMutableDictionary *resultDic = [NSMutableDictionary new];
    [resultDic setObject:infoDic forKey:@"infoDic"];
    [resultDic setObject:allKeys forKey:@"allKeys"];
    [infoDic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        NSMutableArray *_tempOtherArr = (NSMutableArray *)obj;
        [_tempOtherArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            WFCCUserInfo *user1 = (WFCCUserInfo *)obj1;
            WFCCUserInfo *user2 = (WFCCUserInfo *)obj2;
            NSString *user1Pinyin = [SelectLaContactVC hanZiToPinYinWithString:user1.displayName];
            NSString *user2Pinyin = [SelectLaContactVC hanZiToPinYinWithString:user2.displayName];
            return [user1Pinyin compare:user2Pinyin];
        }];
    }];
    return resultDic;
}

+ (NSString *)getFirstUpperLetter:(NSString *)hanzi {
    NSString *pinyin = [self hanZiToPinYinWithString:hanzi];
    NSString *firstUpperLetter = [[pinyin substringToIndex:1] uppercaseString];
    if ([firstUpperLetter compare:@"A"] != NSOrderedAscending &&
        [firstUpperLetter compare:@"Z"] != NSOrderedDescending) {
        return firstUpperLetter;
    } else {
        return @"#";
    }
}

+ (NSString *)hanZiToPinYinWithString:(NSString *)hanZi {
    if (!hanZi) {
        return nil;
    }
    if (!hanziStringDict) {
        hanziStringDict = [[NSMutableDictionary alloc] init];
    }
    
    NSString *pinYinResult = [hanziStringDict objectForKey:hanZi];
    if (pinYinResult) {
        return pinYinResult;
    }
    pinYinResult = [NSString string];
    for (int j = 0; j < hanZi.length; j++) {
        NSString *singlePinyinLetter = nil;
        if ([self isChinese:[hanZi substringWithRange:NSMakeRange(j, 1)]]) {
            singlePinyinLetter = [[NSString
                                   stringWithFormat:@"%c", pinyinFirstLetter([hanZi characterAtIndex:j])]
                                  uppercaseString];
        }else{
            singlePinyinLetter = [hanZi substringWithRange:NSMakeRange(j, 1)];
        }
        
        pinYinResult = [pinYinResult stringByAppendingString:singlePinyinLetter];
    }
    [hanziStringDict setObject:pinYinResult forKey:hanZi];
    return pinYinResult;
}

+ (BOOL)isChinese:(NSString *)text
{
    NSString *match = @"(^[\u4e00-\u9fa5]+$)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF matches %@", match];
    return [predicate evaluateWithObject:text];
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

@end
