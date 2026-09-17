//
//  LaGroupMemberVC.m
//  WildFireChat
//
//  Created by Ruby on 1/4/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaGroupMemberVC.h"
#import "LaContactsTVCell.h"

#import "LaMemberInfoVC.h"
#import "LaFriendInfoVC.h"

@interface LaGroupMemberVC ()<UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong)NSMutableArray<WFCCGroupMember *> *memberList;

@property (nonatomic, strong) NSMutableArray<WFCCGroupMember *> *searchList;
@property (nonatomic, strong)  UISearchController       *searchController;

@property (nonatomic, strong) WFCCGroupInfo *groupInfo;

@end

@implementation LaGroupMemberVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 11, *)) { // https://www.jianshu.com/p/2378ca588efd
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"GroupChatMember");
    
    _memberList = NSMutableArray.new;
    _searchList = NSMutableArray.new;
    
    _memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:_groupId forceUpdate:YES].mutableCopy;
    _groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:_groupId refresh:YES];
    
    __weak typeof(self)ws = self;
    [[NSNotificationCenter defaultCenter] addObserverForName:kGroupMemberUpdated object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification * _Nonnull note) {
        if ([ws.groupId isEqualToString:note.object]) {
            ws.groupInfo = [[WFCCIMService sharedWFCIMService] getGroupInfo:ws.groupId refresh:NO];
            ws.memberList = [[WFCCIMService sharedWFCIMService] getGroupMembers:ws.groupId forceUpdate:NO].mutableCopy;
            [ws.tableView reloadData];
        }
    }];
    
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.tableView registerNib:[UINib nibWithNibName:@"LaContactsTVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"LaContactsTVCell"];
    
    
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
    // 这句话可以解决 self.tableView.tableHeaderView = _searchController.searchBar 导致的搜索栏下滑灰色的问题
    self.tableView.backgroundView = UIView.new;
    
    self.definesPresentationContext = YES;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active) {
        return _searchList.count;
    }
    return _memberList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LaContactsTVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LaContactsTVCell" forIndexPath:indexPath];
    WFCCGroupMember *groupMember = nil;
    if (_searchController.active) {
        groupMember = _searchList[indexPath.row];
    }else {
        groupMember = _memberList[indexPath.row];
    }
    [cell setUserId:groupMember.memberId groupId:_groupId];
    [cell showMember];
    //显示群主
    if ([_groupInfo.owner isEqualToString:groupMember.memberId]) {
        [cell showGroupOwn];
    } else {
        //群管理员
        if (groupMember.type == Member_Type_Manager) {
            [cell showGroupManager];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCGroupMember *groupMember = nil;
    if (_searchController.active) {
        groupMember = _searchList[indexPath.row];
    }else {
        groupMember = _memberList[indexPath.row];
    }
    
    
//    BOOL isShowMute = NO;
//    if ([self isGroupManager:groupMember.memberId]) { // 如果该用户为管理员  不能将管理员禁言
//
//    }
    
    BOOL isMyFriend = [WFCCIMService.sharedWFCIMService isMyFriend:groupMember.memberId]; // 与本人是否是好友关系
    
    //群聊是否设置了允许普通成员发起临时会话：群管理设置不允许发起临时会话时:群主/管理员可以对群员发起会话,群员可以对群主/管理员发起会话(但不能对普通成员发起会话)
    BOOL roleAllow = NO;
    
    //对方是群主/群管理
    if (groupMember.type == Member_Type_Owner || groupMember.type == Member_Type_Manager) {
        roleAllow = YES;
    }
    //我自己是群主/管理员
    WFCCGroupMember *gm = [[WFCCIMService sharedWFCIMService] getGroupMember:self.groupId memberId:[WFCCNetworkService sharedInstance].userId];
    if (gm.type == Member_Type_Owner || gm.type == Member_Type_Manager) {
        roleAllow = YES;
    }
    
    
    if (isMyFriend && roleAllow) { // 是好友关系
        LaMemberInfoVC *vc = LaMemberInfoVC.new;
        vc.groupId = _groupId;
        vc.userId = groupMember.memberId;
        [self.navigationController pushViewController:vc animated:YES];
    }else { // 本人或者 非好友关系
        LaFriendInfoVC *vc = LaFriendInfoVC.new;
        vc.groupId = _groupId;
        vc.userId = groupMember.memberId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
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

        [self.searchList removeAllObjects];
        if (searchString.length > 0) {
            QOEUAPinyinUtility *pu = [[QOEUAPinyinUtility alloc] init];
            BOOL isChinese = [pu isChinese:searchString];
            
            for (WFCCGroupMember *model in _memberList) {
                WFCCUserInfo *userInfo = [[WFCCIMService sharedWFCIMService] getUserInfo:model.memberId inGroup:_groupId refresh:NO];
                
                if ([userInfo.friendAlias.lowercaseString containsString:searchString.lowercaseString] ||
                    [userInfo.groupAlias.lowercaseString containsString:searchString.lowercaseString] ||
                    [userInfo.displayName.lowercaseString containsString:searchString.lowercaseString]) {
                    [self.searchList addObject:model];
                }else if(!isChinese) {
                    if([pu isMatch:userInfo.friendAlias ofPinYin:searchString] ||
                       [pu isMatch:userInfo.groupAlias ofPinYin:searchString] ||
                       [pu isMatch:userInfo.displayName ofPinYin:searchString]) {
                        [self.searchList addObject:model];
                    }
                }
                
            }
        }
    }
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
