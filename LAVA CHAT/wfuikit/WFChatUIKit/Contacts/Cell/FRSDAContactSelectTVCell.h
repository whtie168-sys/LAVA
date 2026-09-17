//
//  ContactSelectTableViewCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/10/25.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FRSDAContactSelectTVCell : UITableViewCell
@property(nonatomic, assign)BOOL multiSelect;
//@property(nonatomic, assign)BOOL checked;
@property(nonatomic, assign) NSInteger checked;
@property(nonatomic, assign)BOOL disabled;
@property(nonatomic, strong)UILabel *asoucNameLabel;
- (void)showAsoucFriendUid:(NSString *)asoucFriendUid;
@end
