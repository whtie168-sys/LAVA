//
//  AllTopMessagePopupView.h
//  WildFireChat
//
//  Created by Rubyuer on 4/26/24.
//  Copyright © 2024 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TopMessageClickBlock)(NSInteger type);
typedef void(^TopMessageGongGaoDelBlock)(NSInteger tag);

@interface AllTopMessagePopupView : UIView

- (void)showWithResult:(NSArray<MessageTopList *> *)results;

//@property (nonatomic, weak) UIViewController *superVc;

@property (nonatomic, copy) TopMessageClickBlock clickBlock;
@property (nonatomic, copy) TopMessageGongGaoDelBlock gonggaoDelBlock;

@end




@interface AllTopMessageCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) MessageTopList *topList;

@property (weak, nonatomic) IBOutlet UIButton *coaeoxRemoveBtn;
@end

NS_ASSUME_NONNULL_END
