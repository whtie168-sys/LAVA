//
//  LaDeviceVC.h
//  WildFireChat
//
//  Created by Ruby on 2/1/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import "LaMainVC.h"

NS_ASSUME_NONNULL_BEGIN

@interface LaDeviceVC : LaMainVC

@end


@interface LaDeviceTVCell : UITableViewCell

@property (nonatomic, strong) DeviceHistory *model;

@end
NS_ASSUME_NONNULL_END
