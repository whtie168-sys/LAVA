//
//  SelectLaGroupVC.m
//  WUHOIBDK
//
//  Created by Ruby on 11/13/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import "SelectLaGroupVC.h"
#import "SelectLaTableVCell.h"

@interface SelectLaGroupVC ()<UITableViewDataSource, UITableViewDelegate, UISearchControllerDelegate, UISearchResultsUpdating>

@property (nonatomic, strong)NSMutableArray<WFCCGroupInfo *> *groups;

@property (nonatomic, strong) NSMutableArray<WFCCGroupInfo *> *searchList;
@property (nonatomic, strong)  UISearchController       *searchController;
@property UIScrollView *headV;
@property NSMutableArray *selectGroups;
@end

@implementation SelectLaGroupVC

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationController.navigationBar.shadowImage = UIImage.new;
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
    [self refreshList];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (@available(iOS 11, *)) { // https://www.jianshu.com/p/2378ca588efd
        self.navigationItem.hidesSearchBarWhenScrolling = YES;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = LLLLLL(@"SelectGroupChat");
    [self setRightNavi];

    
    _groups = NSMutableArray.new;
    _searchList = NSMutableArray.new;
    _selectGroups = NSMutableArray.new;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = UIColor.whiteColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"SelectLaTableVCell" bundle:NSBundle.mainBundle] forCellReuseIdentifier:@"SelectLaTableVCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onGroupInfoUpdated:) name:kGroupInfoUpdated object:nil];
    
    
    
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
}

- (void)refreshList {
    [self.groups removeAllObjects];
//    NSArray *groupIds = [WFCCIMService.sharedWFCIMService getFavGroups];
    
    WS(weakself) // 获取当前用户的所有群组，注意这个方法的代价比较大，不建议高频使用
    [WFCCIMService.sharedWFCIMService getMyGroups:^(NSArray<NSString *> *groupIds) {
        dispatch_async(dispatch_get_main_queue(), ^{
            for (NSInteger i = (groupIds.count - 1); i >= 0; i --) {
                WFCCGroupInfo *groupInfo = [WFCCIMService.sharedWFCIMService getGroupInfo:groupIds[i] refresh:YES];
                if (groupInfo) {
                    groupInfo.target = groupIds[i];
                    [self.groups addObject:groupInfo];
                }
            }
            [weakself.tableView reloadData];
        });
    } error:^(int error_code) {
    }];
}
- (void)onGroupInfoUpdated:(NSNotification *)notification {
    NSArray<WFCCGroupInfo *> *groupInfoList = notification.userInfo[@"groupInfoList"];
    for (int i = 0; i < self.groups.count; ++i) {
        for (WFCCGroupInfo *groupInfo in groupInfoList) {
            if([self.groups[i].target isEqualToString:groupInfo.target]) {
                self.groups[i] = groupInfo;
                [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:i inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
        }
    }
}

- (void)freshSelet {
    for (UIView *v in self.headV.subviews) {
        [v removeFromSuperview];
    }
    
    for (int i = 0; i < self.selectGroups.count; i++) {
        WFCCGroupInfo *groupInfo = self.selectGroups[i];
        UIImageView *portraitImgView = [[UIImageView alloc] initWithFrame:CGRectMake(18+58*i, 15, 40, 40)];
        portraitImgView.clipsToBounds = YES;
        portraitImgView.layer.cornerRadius = 20;
        [portraitImgView sd_setImageWithURL:URL(groupInfo.portrait) placeholderImage:[UIImage imageNamed:@"groupIcon"] options:SDWebImageScaleDownLargeImages
                                         context:@{SDWebImageContextImageForceDecodePolicy : @(SDImageForceDecodePolicyNever), SDWebImageContextStoreCacheType : @(SDImageCacheTypeDisk)}];
        [self.headV addSubview:portraitImgView];
    }
    [self.headV setContentSize:CGSizeMake(18+58*_selectGroups.count, 0)];
    
    [self setRightNavi];
}

- (void)setRightNavi {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[NSString stringWithFormat:@"%@(%lu)",LLLLLL(@"AlertButton"),(unsigned long)_selectGroups.count] style:UIBarButtonItemStyleDone target:self action:@selector(sendAct)];
}

- (void)sendAct {
    if (self.selectGroups.count == 0) {
        [self.view makeToast:LLLLLL(@"SelectGroupChat")];
        return;
    }
    [SVProgressHUD show];
    if (self.message) {
        for (int i = 0; i < self.selectGroups.count;i++) {
            WFCCGroupInfo *group = self.selectGroups[i];
            WFCCConversation *conversation = [[WFCCConversation alloc] init];
            conversation.type = Group_Type;
            conversation.target = group.target;
            conversation.line = 0;
            
            [[WFCCIMService sharedWFCIMService] send:conversation content:self.message.content success:^(long long messageUid, long long timestamp) {

            } error:^(int error_code) {

            }];
            [NSThread sleepForTimeInterval:0.1];
            if (i+1 == self.selectGroups.count) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:LLLLLL(@"ForwardSuccess")];
            }
        }
        
    } else {
        int total = 0;
        for (int i = 0; i<self.messages.count;i++) {
            WFCCMessage *msg = self.messages[i];
            for (int j = 0; j < self.selectGroups.count; j++) {
                WFCCGroupInfo *group = self.selectGroups[j];
                WFCCConversation *conversation = [[WFCCConversation alloc] init];
                conversation.type = Group_Type;
                conversation.target = group.target;
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
            
            if (total == self.selectGroups.count*self.messages.count) {
                [SVProgressHUD dismiss];
                [SVProgressHUD showSuccessWithStatus:LLLLLL(@"ForwardSuccess")];
            }
        }
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_searchController.active) {
        return _searchList.count;
    }
    return self.groups.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectLaTableVCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SelectLaTableVCell" forIndexPath:indexPath];
    if (_searchController.active) {
        cell.groupInfo = _searchList[indexPath.row];
    }else {
        cell.groupInfo = self.groups[indexPath.row];
    }
    [cell isselectImg:NO];
    for (WFCCGroupInfo *group in self.selectGroups) {
        if ([group.target isEqualToString:cell.groupInfo.target]) {
            [cell isselectImg:YES];
            break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    WFCCGroupInfo *groupInfo = (_searchController.active ? _searchList[indexPath.row] : _groups[indexPath.row]);
    
    BOOL isselect = NO;
    int i = 0;
    for (WFCCGroupInfo *group in self.selectGroups) {
        if ([group.target isEqualToString:groupInfo.target]) {
            [self.selectGroups removeObjectAtIndex:i];
            isselect = YES;
            break;
        }
        i++;
    }
    if (!isselect) {
        [self.selectGroups addObject:groupInfo];
    }
    [self freshSelet];
    [tableView reloadData];
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 66.0;
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
            
            for (WFCCGroupInfo *model in self.groups) {
                if ([model.displayName.lowercaseString containsString:searchString.lowercaseString]) {
                    [self.searchList addObject:model];
                } else if(!isChinese) {
                    if ([pu isMatch:model.displayName ofPinYin:searchString]) {
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

