//
//  RWADCGroupMemberTVCell.h
//  WFChat UIKit
//
//  Created by WF Chat on 2017/9/18.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RWADCGroupMemberTVCell : UITableViewCell
@property (nonatomic, assign)BOOL isSelectable;
@property (nonatomic, assign)BOOL isSelected;
@property (nonatomic, strong)UIImageView *trewqPortraitView;
@property (nonatomic, strong)UILabel *groupNameView;
@property (nonatomic, strong)UIImageView *selectView;
@end
