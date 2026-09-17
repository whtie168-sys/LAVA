//
//  RADCOConferenceCVLayout.h
//  WFChatUIKit
//
//  Created by Rain on 2022/9/21.
//  Copyright © 2022 Wildfirechat. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface RADCOConferenceCVLayout : UICollectionViewLayout
- (CGPoint)getOffsetOfItems:(NSArray<NSIndexPath *> *)items;
- (NSMutableArray<NSIndexPath *> *)itemsInPage:(int)page;
@property(nonatomic, assign)BOOL audioOnly;
@end

NS_ASSUME_NONNULL_END
