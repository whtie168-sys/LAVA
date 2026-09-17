//
//  LaAnnouncementTopView.h
//  WildFireChat
//
//  Created by Ruby on 1/17/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaAnnouncementTopView : UIView

@property (weak, nonatomic) IBOutlet UILabel *contentLabel;

// type 0 知道了   1 点击整个view
@property(nonatomic, copy) void (^popAnnouncementViewBlock)(NSInteger type);

@end

NS_ASSUME_NONNULL_END
