//
//  LaCallosTVCell.h
//  WildFireChat
//
//  Created by Ruby on 11/6/23.
//  Copyright © 2023 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaCallosTVCell : UITableViewCell

@property (nonatomic, strong) AddAudioModel *audioModel;

@property (weak, nonatomic) IBOutlet UIButton *stateButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *iconLeft;

@end

NS_ASSUME_NONNULL_END
