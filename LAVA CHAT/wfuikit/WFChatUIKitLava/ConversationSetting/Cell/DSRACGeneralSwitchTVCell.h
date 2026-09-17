//
//  SwitchTableViewCell.h
//  WildFireChat
//
//  Created by heavyrain lee on 27/12/2017.
//  Copyright © 2017 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DSRACGeneralSwitchTVCell : UITableViewCell
@property(nonatomic, assign)BOOL on;
@property(nonatomic, assign)int type;
@property(nonatomic, strong)void (^onSwitch)(BOOL value, int type, void (^handleBlock)(BOOL success));

@property(nonatomic, strong)UISwitch *valueSwitch;
@end
