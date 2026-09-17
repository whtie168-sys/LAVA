//
//  LaTopMessageView.h
//  WildFireChat
//
//  Created by Rubyuer on 4/26/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface LaTopMessageView : UIView

- (void)reloadView:(NSArray<MessageTopList *> *)results;

@property (weak, nonatomic) IBOutlet UIButton *coaeoxRemoveBtn;

@end

NS_ASSUME_NONNULL_END
